// This file is a step by step guide on how to implement the wheel in
// your game. For each step please read the comments and find the
// needed variables in your game.
//
// See html docs part of the Steering Wheel SDK package for method
// usages, parameters and return values.
//
// NOTE: Whatever is in brackets (<...>) is the type of local
// variables that you need to retrieve from your game.
// NOTE: This file can't compile. Therefore it hasn't been tested and
// there may be some errors.
// NOTE: To make the programming part of the file shorter in order not
// to scare you off, a bunch of comments have been placed at the end
// of the file.

/*
The Logitech Steering Wheel SDK, including all accompanying
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiWheel.h"
#include "LogiControllerInput.h"

using namespace LogitechSteeringWheel;
using namespace LogitechControllerInput;

//------------------------------------------------------------------------
// Global variables
//------------------------------------------------------------------------

Wheel* g_wheel;
ControllerInput* g_controllerInput;


INT_PTR CALLBACK MainDlgProc( HWND hDlg,
                             UINT msg,
                             WPARAM wParam,
                             LPARAM lParam )
{
    // variable declarations. Call them whatever you like, and declare
    // them as whatever type is needed.

    // the index number is always 0 for the first enumerated wheel,
    //and always 1 for the second wheel.
    int index;

    // normalized value between between 0 and 1 for each
    // wheel/joystick
    float speedParam[2] = {0.0f, 0.0f};
    // velocity of the car in meters/second;
    int velocity;
    // physics engine force acting sideways on the left front wheel
    int forceLeftWheelAmplitude;
    // physics engine force acting sideways on the right front wheel
    int forceRightWheelAmplitude;
    // forceLeftWheelAmplitude + forceRightWheelAmplitude
    int frontWheelVectorForceAmplitude;
    int forceDirection; // left or right
    // scaled frontWheelVectorForceAmplitude to adapt to physics
    // engine ouput values range
    int constantForceAmplitude;
    // Keep a history of the time of frontal or vertical collision
    float timeAtCollision = 0;
    int currentSurfaceType;
    int currentSurfaceMaxMagnitude;
    int currentSurfacePeriod;

    // Position of the steering wheel
    int wheelPosition;

    // use variable to figure out when a new wheel gets connected
    static BOOL wasConnected_[2] = {FALSE, FALSE};

    switch( msg )
    {
    case WM_INITDIALOG:
        g_controllerInput = new ControllerInput(hDlg, TRUE); // TRUE means that XInput devices will be ignored
        g_wheel = new Wheel(g_controllerInput);

        // See comment #1 at the end of this file
        g_wheel->GenerateNonLinearValues(0, -40);
        g_wheel->GenerateNonLinearValues(1, 80);

        ControllerPropertiesData propertiesData;
        ZeroMemory(&propertiesData, sizeof(propertiesData));
        propertiesData.forceEnable = TRUE;
        propertiesData.overallGain = 100;
        propertiesData.springGain = 100;
        propertiesData.damperGain = 100;
        propertiesData.combinePedals = FALSE;
        propertiesData.wheelRange = 900;

        // We simply set our preferred setting for the game. The Steering Wheel SDK will take care of attempting to set it
        // whenever necessary.
        g_wheel->SetPreferredControllerProperties(index, propertiesData);

        ...

        return TRUE;

    case WM_ACTIVATE:
        ...

    case WM_TIMER:

        // Update the input device every timer message.
        g_controllerInput->Update();
        g_wheel->Update();

        for (index = 0; index < LG_MAX_CONTROLLERS; index++)
        {
            if (g_wheel->IsConnected(index))
            {
                g_wheel->PlayLeds(index, <currentRPM>, <rpmFirstLedTurnsOn>, <rpmRedLine>);

                ControllerPropertiesData propertiesData;
                ZeroMemory(&propertiesData, sizeof(propertiesData));

                g_wheel->GetCurrentControllerProperties(index, propertiesData);

                INT gatedShifterMode = g_wheel->GetShifterMode(index); // 0 if sequential, 1 if gated, -1 if unknown (probably disconnected or Gaming Software older than 5.03)

                // Do some processing to adapt to the wheel's
                // properties. Most important is to see whether pedals
                // are combined or separate, and to see what the range
                // of the wheel is (40 to 900 degrees) and adapt the
                // game's steering to it.

                // Read wheel position with or without non-linear
                // correction.
                wheelPosition = g_wheel->GetState(index).lX; // linear
                // wheelPosition = g_wheel->GetNonLinearValue(index,
                // g_wheel->GetState(index).lX) // non-linear

                // Adapt steering wheel position to car's front wheels
                // angle.
                // IMPORTANT: See comment #2 at the end of this file.

                // Do button mappings using the following methods:
                // g_wheel->ButtonTriggered(),
                // g_wheel->ButtonIsPressed(),

                // Get velocity from physics engine
                velocity = </*velocity of car in meters/second*/>;

                // Normalized speed parameter. The parameter should
                // vary from 0 at a stop to 1 at a speed of about one
                // third of maximum speed and above.
                speedParam = min(1, velocity/20.0f);

                // See comment #3 at the end of this file
                forceLeftWheelAmplitude = </*signed amplitude of lateral force on front left wheel*/>;
                forceRightWheelAmplitude = </*signed amplitude of lateral force on front right wheel*/>;
                frontWheelVectorForceAmplitude = forceLeftWheelAmplitude + forceRightWheelAmplitude;

                // Define direction of force.
                // Direction may be wrong depending on force
                // used. Adapt to make the constant force act like a
                // centering spring.
                if (frontWheelVectorForceAmplitude < 0)
                {
                    forceDirection = 1;
                }
                else
                {
                    forceDirection = -1;
                }

                // See comment #4 at the end of this file
                // constantForceAmplitude should be between 0 and ~85%
                // Let's suppose that at maximum turn,
                // frontWheelVectorForceAmplitude reaches +/-
                // 30000. As explained in comment #4, we set things up
                // to reach max force at 2/3rds of that.
                frontWheelVectorForceAmplitude = abs(frontWheelVectorForceAmplitude);
                constantForceAmplitude = min(85, (frontWheelVectorForceAmplitude / 20000) * 85);

                // See comment #5 at the end of this file
                g_wheel->PlayConstantForce(index, forceDirection * constantForceAmplitude);

                // See comment #6 at the end of this file
                g_wheel->PlaySpringForce(index, 0, int(15.0f * speedParam), int(15.0f * speedParam));

                // Play Damper Force. Strong force at speed = 0,
                // disappears with speed.
                g_wheel->PlayDamperForce(index, int(80.0f * (1 - speedParam)));

                // See comment #7 at the end of this file
                if (</*front wheels not touching the ground*/>)
                {
                    if (!g_wheel->IsPlaying(index, LG_FORCE_CAR_AIRBORNE)
                    {
                        g_wheel->PlayCarAirborne(index);
                    }
                }
                else
                {
                    if (g_wheel->IsPlaying(index, LG_FORCE_CAR_AIRBORNE)
                    {
                        g_wheel->StopCarAirborne(index);
                    }
                }

                // See comment #8 at the end of this file
                if (</*front collision detected*/>)
                {

                    g_wheel->PlayFrontalCollisionForce(index, </*frontal collision magnitude*/>);
                }

				// See comment #9 at the end of this file
                if (</*vertical collision detected*/>)
                {
                    g_wheel->PlayFrontalCollisionForce(index, </*vertical collision magnitude*/>);
                }

                // See comment #10 at the end of this file
                currentSurfaceType = </*current surfaces type*/>;
                currentSurfaceMaxMagnitude = </*current surfaces maximum magnitude*/>;
                currentSurfacePeriod = </*current surfaces period*/>
                g_wheel->PlaySurfaceEffect(index, currentSurfaceType, (int)(currentSurfaceMaxMagnitude * speedParam), currentSurfacePeriod);

                // Play slippery road effect in case the car is on ice
                // or snow or another slippery surface
                if (</*current surface is snow or ice or another slippery surface*/>)
                {
                    // adapt the 80% to whatever you like (0 - 100) to
                    // make it more or less slippery.
                    g_wheel->PlaySlipperyRoadEffect(index, 80);
                }
            }
        }

        return TRUE;

        case WM_COMMAND:
            ...


        case WM_DESTROY:
            // Cleanup everything
            // Cleanup everything
            if (g_wheel)
            {
                delete g_wheel;
                g_wheel = NULL;
            }

            if (g_controllerInput)
            {
                delete g_controllerInput;
                g_controllerInput = NULL;
            }
            ...
            return TRUE;
    }

    return FALSE; // Message not handled
}


// Comment #1
// If the wheel feels too sensitive (difficult to drive in a straight
// line), DO NOT ADD A DEADZONE. It is the wrong solution to the
// problem.  The solution is to make the wheel less sensitive,
// especially at speed.  One way to do so is to generate non-linear
// values to make the wheel less sensitive around center position.
// If you are in the rare situation that the wheel does not feel
// sensitive enough, you can also set the coefficient to negative
// values down to -100, but this is a very rare case so be careful to
// not misuse it!

// Comment #2
// Except for extremely arcady games, the main rule when adapting the
// steering wheel's position to the car's front wheels angles is to
// create a steering response as close as possible to that of a real
// car.  This is the best way to minimize the time most people need to
// get used to driving the game and having fun. If on the other hand
// the response is completely off because for example there is a
// deadzone or the steering wheel feels way too sensitive, then most
// people will need a lot of time to learn to play the game well with
// the wheel. For more details on how to create a steering response
// that is as close as possible to that of a real car check the
// document "SteeringResponse.doc" in the "Doc" folder (it's just one
// page :).

// Comment #3
// Tie constant force into physics engine by for example retrieving
// the front wheels' lateral forces (friction) and using that value to
// update a constant force's magnitude and direction in every loop.

// Comment #4
// If the maximum possible value for frontWheelVectorForceAmplitude is
// for example 30000, make the constant force's amplitude maximum for
// a frontWheelVectorForceAmplitude value of 20000 so that two thirds
// of the maximum is enough to trigger full effect on the constant
// force.
// IMPORTANT: Do not make the constant force response too steep. A
// steeper response may make a weaker wheel like Formula Force GP feel
// better with more forces around center position but it will make
// stronger wheels with less friction like MOMO or Driving Force Pro
// unstable and difficult to drive!! Take a wheel such as Driving
// Force Pro or G25, and tweak your setting to where it's as strong as
// possible without creating instability when slightly holding the
// wheel.

// Comment #5
// Play Constant Force with our previous parameters that get updated
// for every frame. Check the direction is correct: when driving in an
// almost straight line without sliding the constant force should try
// to push the wheel back towards center. This force automatically
// gives a spring effect, side collisions, and a general feel of what
// is happening to the car (sliding, inertia, etc).

// Comment #6
// Play spring force. Non-existent for speed = 0, grows stronger with
// speed.  The previous constant force already creates a spring type
// effect, but it may feel a little too reactive or even
// unstable. Adding a soft spring force on top smoothens the constant
// force effect.
// NOTE: If the constant doesn't feel good or is unstable even after
// you tried to tweak the constant force response (and made sure it is
// not too steep), then another solution is to drop the constant force
// entirely and replace it by a spring force with variable offset. The
// amount of offset would be updated in every frame and based on the
// same frontWheelVectorForceAmplitude parameter. This should get rid
// of instability and also create side collision and sliding
// effects. However the downside is that the force will feel somewhat
// less realistic.  Depending on the type of your game (simulation or
// arcade) you may choose one solution or the other.

// Comment #7
// Play air effect. When the front wheels are in the air, you want the
// wheel to feel very loose. This a nice effect for when the car is
// jumping or when the car is upside down.

// Comment #8
// Play front collision. The constant force will only give side
// collisions. If you hit a wall straight on you need an additional
// effect.  Find out if you have a frontal collision by getting the
// event from your game somewhere or by checking the velocity
// difference between two frames.
// For example a velocity difference of 3 m/s between 2 frames would
// indicate there was a frontal collision. You could then calculate a
// normalized parameter which goes from 0 at 3 m/s speed difference to
// 1 at about 15 m/s. Then multiply that parameter by 100 for the
// magnitude of the method.

// Comment #9
// Play vertical collision. This is nice when the car lands from a
// jump or when there are sudden changes in the angle of the
// surface. A good way to implement this force is by taking the front
// wheels' vertical force and check the values each frame. If there is
// a big jump between two frames, then we know we have a vertical
// collision. The magnitude of the collision can be scaled depending
// on how big the difference in vertical force is, similar to what is
// done with the speed parameter for the frontal collision..

// Comment #10
// Play surface effects for each different surface. For example you
// could check both of your front wheels and find out what surface
// they are on.  If both wheels are on different surfaces then you
// could choose the surface that has the strongest force effect and
// set the magnitude to one half of normal magnitude used when both
// wheels are on that same surface.
// For each surface you could define a type of rumble, a maximum
// magnitude and a period. When you define a type of rumble keep in
// mind that LG_TYPE_SQUARE is much more edgy (wooden bridge,
// cobblestone) than LG_TYPE_TRIANGLE, which in turn is a little more
// noticeable than LG_TYPE_SINE (sand, dirt), which is somewhat
// smoother.
// Possible types are: LG_TYPE_SINE, LG_TYPE_SQUARE, LG_TYPE_TRIANGLE
// Good starting values could be:
//
// SURFACE              TYPE                 MAX MAGNITUDE      PERIOD
// wooden bridge        LG_TYPE_SQUARE       40                 120
// cobblestones         LG_TYPE_SQUARE       30                 100
// dirt                 LG_TYPE_SINE         40                 80
// grass                LG_TYPE_TRIANGLE     24                 40
// sand                 LG_TYPE_SINE         12                 20
//
// NOTE: be aware that those are only starting values, which may need
// to be tweaked depending on the other forces that are playing in
// your game.  Also a nice effect would be to change the period of the
// surface effects with speed.

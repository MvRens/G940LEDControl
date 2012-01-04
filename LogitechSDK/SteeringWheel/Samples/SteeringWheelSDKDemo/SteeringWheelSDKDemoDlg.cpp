// This is a sample main file for testing the wheel in a way it could be
// used in a game. It only works with the 9 first defines enabled
// (__WHEELS/_JOYSTICK to _AIRBORNE).

// The other defines show usages of the other methods of the Steering Wheel SDK

// Usage: the accelerator pedal is mapped to the fictitious speed of the
// car. If the pedal is not pressed at all, then the car is at a stop.
// In that case there is a damper that makes the wheel hard to turn, there
// is no spring effect. Surface effects are inexistent since at a stop you
//  wouldn't feel anything.
// As you start accelerating, the damper becomes loose and the spring
// force kicks in. If you start surface effects by hitting some of the
// buttons (see code below for button mapping), you will feel the surfaces
// in your wheel as long as you have some speed. You can also emulate side
// and front collisions by triggering certain buttons. Just like the
// surface effects, the collisions' magnitude is dependent on speed.

/*
The Logitech Steering Wheel SDK, including all accompanying documentation,
is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "stdafx.h"
#include "SteeringWheelSDKDemo.h"
#include "SteeringWheelSDKDemoDlg.h"
#include "LogiControllerInput.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

#ifndef TRACE
#define TRACE LOGIWHEELTRACE
#endif

#define _DEMO // does things similar to how a game would feel based on pedal and button input

// following are used for testing every functionality of the SDK
//#define _IS_CONNECTED_FRIENDLY_NAME
//#define _BUTTON_TRIGGERED_RELEASED
//#define _BUTTON_IS_PRESSED
//#define _NON_LIN_VALUES
//#define _HAS_FORCE_FEEDBACK
//#define _IS_PLAYING

//#define _SPRING // Button 0. Use wheel with separate axes to test.
//#define _DAMPER // Button 1
//#define _DIRT_ROAD // Button 2
//#define _BUMPY_ROAD // Button 3
//#define _CONSTANT // Button 4

//#define _SURFACE_EFFECT // Button 0, 1, 2, 3

//#define _AIRBORNE // Button 0
//#define _SIDE_COLLISION // Button 1, 2
//#define _FRONTAL_COLLISION // Button 3
//#define _SLIPPERY_ROAD // Button 4
//#define _SOFT_STOP // Button 5

//#define _TEST_SETTING_PROPERTIES_ON_INIT


using namespace LogitechSteeringWheel;
using namespace LogitechControllerInput;

Wheel* g_wheel;
ControllerInput* g_controllerInput;

// CSteeringWheelSDKDemoDlg dialog

CSteeringWheelSDKDemoDlg::CSteeringWheelSDKDemoDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CSteeringWheelSDKDemoDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CSteeringWheelSDKDemoDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CSteeringWheelSDKDemoDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
    ON_WM_TIMER()
    ON_WM_DESTROY()
	//}}AFX_MSG_MAP
    ON_BN_CLICKED(IDC_BUTTON_GET_WHEEL_PROPERTIES0, &CSteeringWheelSDKDemoDlg::OnBnClickedButtonGetWheelProperties0)
    ON_BN_CLICKED(IDC_BUTTON_GET_WHEEL_PROPERTIES1, &CSteeringWheelSDKDemoDlg::OnBnClickedButtonGetWheelProperties1)
    ON_BN_CLICKED(IDC_BUTTON_DEFAULTS, &CSteeringWheelSDKDemoDlg::OnBnClickedButtonDefaults)
    ON_BN_CLICKED(IDC_BUTTON_SET_PREFERRED, &CSteeringWheelSDKDemoDlg::OnBnClickedButtonSetPreferred)
    ON_BN_KILLFOCUS(IDC_BUTTON_SET_PREFERRED, &CSteeringWheelSDKDemoDlg::OnBnKillfocusButtonSetPreferred)
END_MESSAGE_MAP()


// CSteeringWheelSDKDemoDlg message handlers

BOOL CSteeringWheelSDKDemoDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

    g_controllerInput = new ControllerInput(m_hWnd, TRUE);
    g_wheel = new Wheel(g_controllerInput);

#ifdef _TEST_SETTING_PROPERTIES_ON_INIT
    ControllerPropertiesData propertiesData;
    ZeroMemory(&propertiesData, sizeof(propertiesData));
    propertiesData.forceEnable = TRUE;
    propertiesData.overallGain = 99;
    propertiesData.springGain = 98;
    propertiesData.damperGain = 97;
    propertiesData.combinePedals = TRUE;
    propertiesData.wheelRange = 199;

    g_wheel->SetPreferredControllerProperties(propertiesData);
#endif

    SetTimer(1, 1000 / 30, NULL );

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CSteeringWheelSDKDemoDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display
// while the user drags the minimized window.
HCURSOR CSteeringWheelSDKDemoDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CSteeringWheelSDKDemoDlg::OnTimer(UINT nIDEvent)
{
    UNREFERENCED_PARAMETER(nIDEvent);

    INT index_ = 0;
    FLOAT speedParam_[LogitechSteeringWheel::LG_MAX_CONTROLLERS] = {0.0f, 0.0f};
    FLOAT brakeParam_[LogitechSteeringWheel::LG_MAX_CONTROLLERS] = {0.0f, 0.0f};
    TCHAR strText_[128]; // Device state text
    TCHAR* str_;
    TCHAR deviceConnected_[128][LogitechSteeringWheel::LG_MAX_CONTROLLERS];
    TCHAR dirtRoad_[128][LogitechSteeringWheel::LG_MAX_CONTROLLERS];
    TCHAR bumpyRoad_[128][LogitechSteeringWheel::LG_MAX_CONTROLLERS];
    TCHAR slipperyRoad_[128][LogitechSteeringWheel::LG_MAX_CONTROLLERS];
    TCHAR airborne_[128][LogitechSteeringWheel::LG_MAX_CONTROLLERS];

    INT counter_ = 0;

    // Update the input device every timer message.
    g_controllerInput->Update();
    g_wheel->Update();

    // call this every frame in case a wheel gets plugged in.
    g_wheel->GenerateNonLinearValues(0, -40);
    g_wheel->GenerateNonLinearValues(1, 80);

    for (index_ = 0; index_ < LogitechSteeringWheel::LG_MAX_CONTROLLERS; index_++)
    {
        if (g_wheel->IsConnected(index_))
        {
            // Find out if axes are separate or not. If combined, or
            // if we fail, use Y axis for gas and brake.
            if (g_wheel->IsConnected(index_, LG_MANUFACTURER_LOGITECH) && g_wheel->IsConnected(index_, LG_DEVICE_TYPE_WHEEL))
            {
                ControllerPropertiesData propertiesData_;
                ZeroMemory(&propertiesData_, sizeof(propertiesData_));

                g_wheel->GetCurrentControllerProperties(index_, propertiesData_);

                // calculate normalized speed parameter. In a real
                // game the parameter could go from 0 at a stop to 1
                // at a speed of about 50 to 80 miles/hour.
                if (propertiesData_.combinePedals)
                {
                    wsprintf( deviceConnected_[index_],
                        TEXT("Steering wheel, combined pedals"));
                    speedParam_[index_] = max(((-(FLOAT)
                        (g_wheel->GetState(index_)->rglSlider[0]))
                        //(g_wheel->GetState(index_)->lY))
                        / 32767), 0);
                    brakeParam_[index_] = max((((FLOAT)
                        (g_wheel->GetState(index_)->lY))
                        / 32767), 0);
                }
                else
                {
                    wsprintf( deviceConnected_[index_],
                        TEXT("Steering wheel, separate pedals"));
                    speedParam_[index_] = ((-(FLOAT)
                        //(g_wheel->GetState(index_)->lZ))
                        (g_wheel->GetState(index_)->lY))
                        / 65535) + FLOAT(0.5);
                    brakeParam_[index_] = ((-(FLOAT)
                        (g_wheel->GetState(index_)->lRz))
                        / 65535) + FLOAT(0.5);
                }
            }
            else if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_WHEEL) && g_wheel->IsConnected(index_, LG_MANUFACTURER_MICROSOFT))
            {
                // Microsoft wheel
                wsprintf( deviceConnected_[index_],
                    TEXT("Steering wheel, combined pedals"));
                speedParam_[index_] = max(((-(FLOAT)
                    (g_wheel->GetState(index_)->lY))
                    / 32767), 0);
                brakeParam_[index_] = max((((FLOAT)
                    (g_wheel->GetState(index_)->lY))
                    / 32767), 0);
            }
            else if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_WHEEL) && g_wheel->IsConnected(index_, LG_MANUFACTURER_OTHER))
            {

                // Immersion wheel in combined mode
                if (g_wheel->GetState(index_)->lRz == 32767
                    && g_wheel->GetState(index_)->lY == 0
                    && g_wheel->GetState(index_)->rglSlider[0] != 0
                    && g_wheel->GetState(index_)->lZ== 0)
                {
                    wsprintf( deviceConnected_[index_],
                        TEXT("Steering wheel, combined pedals"));
                    speedParam_[index_] = max(((-(FLOAT)
                        (g_wheel->GetState(index_)->rglSlider[0]))
                        / 32767), 0);
                    brakeParam_[index_] = max((((FLOAT)
                        (g_wheel->GetState(index_)->rglSlider[0]))
                        / 32767), 0);
                }

                // Immersion wheel in separate mode
                else if (g_wheel->GetState(index_)->lRz == 32767
                    && g_wheel->GetState(index_)->lY != 0
                    && g_wheel->GetState(index_)->rglSlider[0] != 0
                    && g_wheel->GetState(index_)->lZ== 0)
                {
                    wsprintf( deviceConnected_[index_],
                        TEXT("Steering wheel, separate pedals"));
                    speedParam_[index_] = ((-(FLOAT)
                        (g_wheel->GetState(index_)->lY))
                        / 65535) + FLOAT(0.5);
                    // TODO: brake
                }
            }
            else if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_JOYSTICK))
            {
                wsprintf( deviceConnected_[index_],
                    TEXT("Joystick"));
                speedParam_[index_] = max(((-(FLOAT)
                    (g_wheel->GetState(index_)->rglSlider[0]))
                    / 32767), 0);
                brakeParam_[index_] = max((((FLOAT)
                    (g_wheel->GetState(index_)->rglSlider[0]))
                    / 32767), 0);
            }

            // Game pad
            else if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_GAMEPAD))
            {
                // Logitech rumble pad
                wsprintf( deviceConnected_[index_],
                    TEXT("Game pad"));
                speedParam_[index_] = max((((FLOAT)
                    (g_wheel->GetState(index_)->lY))
                    / 32767), 0);
                brakeParam_[index_] = max(((-(FLOAT)
                    (g_wheel->GetState(index_)->lY))
                    / 32767), 0);
            }
            else
            {
                wsprintf( deviceConnected_[index_],
                    TEXT("Steering wheel"));
                speedParam_[index_] = 0;
                brakeParam_[index_] = 0;
            }

#ifdef _DEMO
            g_wheel->PlayLeds(index_, speedParam_[index_], 0.1f, 1.0f);

            // Play spring force
            g_wheel->PlaySpringForce(index_,
                0,
                INT(70 * speedParam_[index_]),
                INT(70 * speedParam_[index_]));

            // Play Damper Force
            g_wheel->PlayDamperForce(index_, INT(80 *
                (1 - speedParam_[index_])));

            // check for buttons
            if (g_wheel->ButtonTriggered(index_, 0))
            {
                // Usage: PlaySideCollision(index_, magnitude,
                // direction). Direction: 90 degrees means
                // collision from the right side, 270 degrees
                // means collision from the left side.
                g_wheel->PlaySideCollisionForce(index_,
                    INT(100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 1))
            {
                g_wheel->PlaySideCollisionForce(index_,
                    INT(-100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 6))
            {
                g_wheel->PlayFrontalCollisionForce(index_,
                    INT(100 * speedParam_[index_]));
            }

            // Play Bumpy road effect
            if (g_wheel->IsPlaying(index_, LG_FORCE_BUMPY_ROAD))
            {
                g_wheel->PlayBumpyRoadEffect(index_,
                    INT(100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 3))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_BUMPY_ROAD))
                {
                    g_wheel->StopBumpyRoadEffect(index_);
                }
                else
                {
                    g_wheel->PlayBumpyRoadEffect(index_,
                        INT(60 * speedParam_[index_]));
                }
            }

            // Play Dirt road effect
            if (g_wheel->IsPlaying(index_, LG_FORCE_DIRT_ROAD))
            {
                g_wheel->PlayDirtRoadEffect(index_,
                    INT(40 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 2))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_DIRT_ROAD))
                {
                    g_wheel->StopDirtRoadEffect(index_);
                }
                else
                {
                    g_wheel->PlayDirtRoadEffect(index_,
                        INT(40 * speedParam_[index_]));
                }
            }

            // Play Slippery road effect
            if (g_wheel->ButtonTriggered(index_, 4))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_SLIPPERY_ROAD))
                {
                    g_wheel->StopSlipperyRoadEffect(index_);
                }
                else
                {
                    g_wheel->PlaySlipperyRoadEffect(index_,
                        70);
                }
            }

            // Play car in the air effect
            if (g_wheel->ButtonTriggered(index_, 5))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_CAR_AIRBORNE))
                {
                    g_wheel->StopCarAirborne(index_);

                }
                else
                {
                    g_wheel->PlayCarAirborne(index_);

                }
            }

#endif

#ifdef _IS_CONNECTED_FRIENDLY_NAME
            if (g_wheel->ButtonTriggered(index_, 0))
            {
                if (g_wheel->IsConnected(index_))
                {
                    TRACE(_T("A gaming device is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_WHEEL))
                {
                    TRACE(_T("A wheel is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_JOYSTICK))
                {
                    TRACE(_T("A joystick is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_GAMEPAD))
                {
                    TRACE(_T("A gamepad is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_WHEEL) && g_wheel->IsConnected(index_, LG_MANUFACTURER_LOGITECH))
                {
                    TRACE(_T("A Logitech wheel is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_JOYSTICK) && g_wheel->IsConnected(index_, LG_MANUFACTURER_LOGITECH))
                {
                    TRACE(_T("A Logitech joystick is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_GAMEPAD) && g_wheel->IsConnected(index_, LG_MANUFACTURER_LOGITECH))
                {
                    TRACE(_T("A Logitech gamepad is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_WHEEL) &&g_wheel->IsConnected(index_, LG_MANUFACTURER_MICROSOFT))
                {
                    TRACE(_T("A microsoft wheel is connected on index %d\n"), index_);
                }

                if (g_wheel->IsConnected(index_, LG_DEVICE_TYPE_JOYSTICK) && g_wheel->IsConnected(index_, LG_MANUFACTURER_MICROSOFT))
                {
                    TRACE(_T("A microsoft joystick is connected on index %d\n"), index_);
                }

                for (INT ii = 0; ii < LG_NUMBER_MODELS; ii++)
                {
                    if (g_wheel->IsConnected(index_, static_cast<DeviceType>(ii)))
                    {
                        TRACE(_T("A %s is connected on index %d\n"), g_wheel->GetFriendlyProductName(index_), index_);
                    }
                }
            }
#endif

#ifdef _BUTTON_TRIGGERED_RELEASED
            for (INT button_ = 0; button_ < 32; button_++)
            {
                if (g_wheel->ButtonTriggered(index_, button_))
                {
                    TRACE(_T("Button %d triggered on index %d\n"), button_, index_);
                }

                if (g_wheel->ButtonReleased(index_, button_))
                {
                    TRACE(_T("Button %d released on index %d\n"), button_, index_);
                }
            }
#endif

#ifdef _BUTTON_IS_PRESSED
            for (INT button_ = 0; button_ < 32; button_++)
            {
                if (g_wheel->ButtonIsPressed(index_, button_))
                {
                    TRACE(_T("Button %d is pressed on index %d\n"), button_, index_);
                }
            }
#endif

#ifdef _NON_LIN_VALUES
            // Show linear and non-linear wheel values on console.
            // This shows you how to use the non-linear value of
            // the wheel in order to decrease sensitivity around
            // center position.
            static INT previousValueX_[LogitechSteeringWheel::LG_MAX_CONTROLLERS] = {0, 0};

            if (g_wheel->GetState(index_)->lX != previousValueX_[index_])
            {
                TRACE(_T("Index %d: SDK value: %d, non-lin value: %d\n"),
                    index_, g_wheel->GetState(index_)->lX,
                    g_wheel->GetNonLinearValue(index_, g_wheel->GetState(index_)->lX));
            }
            previousValueX_[index_] = g_wheel->GetState(index_)->lX;
#endif

#ifdef _HAS_FORCE_FEEDBACK
            if (g_wheel->ButtonTriggered(index_, 0))
            {
                if (g_wheel->HasForceFeedback(index_))
                    TRACE(_T("Device on index %d has force feedback\n"), index_);
                else
                    TRACE(_T("Device on index %d DOES NOT have force feedback\n"), index_);
            }
#endif

#ifdef _IS_PLAYING
            if (g_wheel->ButtonTriggered(index_, 0))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_SPRING))
                {
                    TRACE(_T("Spring force is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Spring force is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_CONSTANT))
                {
                    TRACE(_T("Constant force is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Constant force is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_DAMPER))
                {
                    TRACE(_T("Damper force is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Damper force is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_DIRT_ROAD))
                {
                    TRACE(_T("Dirt road is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Dirt road is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_BUMPY_ROAD))
                {
                    TRACE(_T("Bumpy road is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Bumpy road is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_SLIPPERY_ROAD))
                {
                    TRACE(_T("Slippery road is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Slippery road is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_SURFACE_EFFECT))
                {
                    TRACE(_T("Surface effect is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Surface effect is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_SOFTSTOP))
                {
                    TRACE(_T("Soft stop is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Soft stop is NOT playing on index %d\n"), index_);
                }

                if (g_wheel->IsPlaying(index_, LG_FORCE_CAR_AIRBORNE))
                {
                    TRACE(_T("Car airborne is playing on index %d\n"), index_);
                }
                else
                {
                    TRACE(_T("Car airborne is NOT playing on index %d\n"), index_);
                }
            }
#endif

#ifdef _SPRING
            if (g_wheel->IsPlaying(index_, LG_FORCE_SPRING))
            {
                g_wheel->PlaySpringForce(index_,
                    INT(100 * (2 * (brakeParam_[index_] - 0.5f))),
                    INT(100 * speedParam_[index_]),
                    INT(100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 0))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_SPRING))
                {
                    g_wheel->StopSpringForce(index_);
                }
                else
                {
                    g_wheel->PlaySpringForce(index_,
                        INT(100 * (2 * (brakeParam_[index_] - 0.5f))),
                        INT(100 * speedParam_[index_]),
                        INT(100 * speedParam_[index_]));
                }
            }
#endif

#ifdef _DAMPER
            if (g_wheel->IsPlaying(index_, LG_FORCE_DAMPER))
            {
                g_wheel->PlayDamperForce(index_, INT(100 *
                    (speedParam_[index_] - brakeParam_[index_])));
            }

            if (g_wheel->ButtonTriggered(index_, 1))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_DAMPER))
                {
                    g_wheel->StopDamperForce(index_);
                }
                else
                {
                    g_wheel->PlayDamperForce(index_, INT(100 *
                        (speedParam_[index_] - brakeParam_[index_])));
                }
            }
#endif

#ifdef _SIDE_COLLISION
            if (g_wheel->ButtonTriggered(index_, 1))
            {
                g_wheel->PlaySideCollisionForce(index_,
                    INT(100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 2))
            {
                g_wheel->PlaySideCollisionForce(index_,
                    INT(-100 * speedParam_[index_]));
            }
#endif

#ifdef _FRONTAL_COLLISION
            if (g_wheel->ButtonTriggered(index_, 3))
            {
                g_wheel->PlayFrontalCollisionForce(index_,
                    INT(100 * speedParam_[index_]));
            }
#endif

#ifdef _DIRT_ROAD
            if (g_wheel->IsPlaying(index_, LG_FORCE_DIRT_ROAD))
            {
                g_wheel->PlayDirtRoadEffect(index_,
                    INT(100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 2))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_DIRT_ROAD))
                {
                    g_wheel->StopDirtRoadEffect(index_);
                }
                else
                {
                    g_wheel->PlayDirtRoadEffect(index_,
                        INT(100 * speedParam_[index_]));
                }
            }
#endif

#ifdef _BUMPY_ROAD
            if (g_wheel->IsPlaying(index_, LG_FORCE_BUMPY_ROAD))
            {
                g_wheel->PlayBumpyRoadEffect(index_,
                    INT(100 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 3))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_BUMPY_ROAD))
                {
                    g_wheel->StopBumpyRoadEffect(index_);
                }
                else
                {
                    g_wheel->PlayBumpyRoadEffect(index_,
                        INT(100 * speedParam_[index_]));
                }
            }
#endif

#ifdef _SLIPPERY_ROAD
            if (g_wheel->IsPlaying(index_, LG_FORCE_SLIPPERY_ROAD))
            {
                g_wheel->PlaySlipperyRoadEffect(index_,
                    INT(100 * speedParam_[index_]));
            }

            // Play Slippery road effect
            if (g_wheel->ButtonTriggered(index_, 4))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_SLIPPERY_ROAD))
                {
                    g_wheel->StopSlipperyRoadEffect(index_);
                }
                else
                {
                    g_wheel->PlaySlipperyRoadEffect(index_,
                        INT(100 * speedParam_[index_]));
                }
            }
#endif

#ifdef _AIRBORNE
            g_wheel->PlayBumpyRoadEffect(index_,
                INT(100 * speedParam_[index_]));

            g_wheel->PlayDirtRoadEffect(index_,
                INT(100 * speedParam_[index_]));

            g_wheel->PlayConstantForce(index_,
                INT(100 * (speedParam_[index_] - brakeParam_[index_])));

            g_wheel->PlayDamperForce(index_, INT(100 *
                (speedParam_[index_] - brakeParam_[index_])));

            g_wheel->PlaySpringForce(index_,
                INT(100 * (2 * (brakeParam_[index_] - 0.5f))),
                INT(100 * speedParam_[index_]),
                INT(100 * speedParam_[index_]));

            g_wheel->PlaySurfaceEffect(index_, LG_TYPE_SQUARE,
                INT(100 * speedParam_[index_]),
                INT(150 * speedParam_[index_]));

            // Play car in the air effect
            if (g_wheel->ButtonTriggered(index_, 0))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_CAR_AIRBORNE))
                {
                    g_wheel->StopCarAirborne(index_);

                }
                else
                {
                    g_wheel->PlayCarAirborne(index_);

                }
            }
#endif

#ifdef _CONSTANT
            if (g_wheel->IsPlaying(index_, LG_FORCE_CONSTANT))
            {
                g_wheel->PlayConstantForce(index_,
                    INT(100 * (speedParam_[index_] - brakeParam_[index_])));
            }

            if (g_wheel->ButtonTriggered(index_, 4))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_CONSTANT))
                {
                    g_wheel->StopConstantForce(index_);
                }
                else
                {
                    g_wheel->PlayConstantForce(index_,
                        INT(100 * (speedParam_[index_] - brakeParam_[index_])));
                }
            }
#endif

#ifdef _SURFACE_EFFECT
            // Play Surface effect
            if (g_wheel->ButtonIsPressed(index_, 0))
            {
                g_wheel->PlaySurfaceEffect(index_, LG_TYPE_SQUARE,
                    INT(100 * speedParam_[index_]),
                    INT(150 * speedParam_[index_]));
            }
            else if (g_wheel->ButtonIsPressed(index_, 1))
            {
                g_wheel->PlaySurfaceEffect(index_, LG_TYPE_SINE,
                    INT(100 * speedParam_[index_]),
                    INT(150 * speedParam_[index_]));
            }
            else if (g_wheel->ButtonIsPressed(index_, 2))
            {
                g_wheel->PlaySurfaceEffect(index_, LG_TYPE_TRIANGLE,
                    INT(100 * speedParam_[index_]),
                    INT(150 * speedParam_[index_]));
            }

            if (g_wheel->ButtonTriggered(index_, 3))
            {
                g_wheel->StopSurfaceEffect(index_);
            }
#endif

#ifdef _SOFT_STOP
            if (g_wheel->ButtonTriggered(index_, 5))
            {
                if (g_wheel->IsPlaying(index_, LG_FORCE_SOFTSTOP))
                {
                    g_wheel->StopSoftstopForce(index_);
                }
                else
                {
                    g_wheel->PlaySoftstopForce(index_,
                        INT(100 * speedParam_[index_]));
                }
            }
#endif

            // Display joystick state to dialog

            // check which effects are playing and update state
            wsprintf( bumpyRoad_[index_],
                TEXT("off"));
            wsprintf( dirtRoad_[index_],
                TEXT("off"));
            wsprintf( slipperyRoad_[index_],
                TEXT("off"));
            wsprintf( airborne_[index_],
                TEXT("off"));

            if (g_wheel->IsPlaying(index_, LG_FORCE_BUMPY_ROAD))
            {
                wsprintf( bumpyRoad_[index_],
                    TEXT("on"));
            }
            if (g_wheel->IsPlaying(index_, LG_FORCE_DIRT_ROAD))
            {
                wsprintf( dirtRoad_[index_],
                    TEXT("on"));
            }
            if (g_wheel->IsPlaying(index_, LG_FORCE_SLIPPERY_ROAD))
            {
                wsprintf( slipperyRoad_[index_],
                    TEXT("on"));
            }
            if (g_wheel->IsPlaying(index_, LG_FORCE_CAR_AIRBORNE))
            {
                wsprintf( airborne_[index_],
                    TEXT("on"));
            }

            // Device 0
            if (index_ == 0)
            {
                // speed
                wsprintf( strText_, TEXT("%ld"),
                    INT(1000 * speedParam_[index_]) );
                ::SetWindowText( ::GetDlgItem(m_hWnd, IDC_SPEED ), strText_ );

                // brake
                wsprintf( strText_, TEXT("%ld"),
                    INT(1000 * brakeParam_[index_]) );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BRAKE ), strText_ );

                // Device connected
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DEVICE ), deviceConnected_[0] );

                // Axes
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->lX );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_AXIS ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->lY );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_AXIS ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->lZ );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_AXIS ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->lRx );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_ROT ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->lRy );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_ROT ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->lRz );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_ROT ), strText_ );

                // Slider controls
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->rglSlider[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER0 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->rglSlider[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER1 ), strText_ );

                // Points of view
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->rgdwPOV[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV0 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->rgdwPOV[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV1 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->rgdwPOV[2] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV2 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(0)->rgdwPOV[3] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV3 ), strText_ );


                // Fill up text with which buttons are pressed
                str_ = strText_;
                for( counter_ = 0; counter_ < 128; counter_++ )
                {
                    if ( g_wheel->GetState(0)->rgbButtons[counter_] & 0x80 )
                        str_ += wsprintf( str_, TEXT("%02d "), counter_ );
                }
                *str_ = 0;   // Terminate the string

                ::SetWindowText( ::GetDlgItem( m_hWnd, IDC_BUTTONS ),
                    strText_ );

                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DIRT_ROAD_PLAYING ), dirtRoad_[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BUMPY_ROAD_PLAYING  ), bumpyRoad_[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIPPERY_ROAD_PLAYING  ), slipperyRoad_[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_CAR_AIRBORNE_PLAYING  ), airborne_[0] );
            }

            if (index_ == 1)
            {
                // Device 1

                // speed
                wsprintf( strText_, TEXT("%ld"),
                    INT(1000 * speedParam_[index_]) );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SPEED2 ), strText_ );

                // brake
                wsprintf( strText_, TEXT("%ld"),
                    INT(1000 * brakeParam_[index_]) );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BRAKE2 ), strText_ );

                // Device connected
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DEVICE2 ), deviceConnected_[1] );

                // Axes
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->lX );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_AXIS2 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->lY );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_AXIS2 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->lZ );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_AXIS2 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->lRx );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_ROT2 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->lRy );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_ROT2 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->lRz );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_ROT2 ), strText_ );

                // Slider controls
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->rglSlider[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER02 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->rglSlider[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER12 ), strText_ );

                // Points of view
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->rgdwPOV[0] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV02 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->rgdwPOV[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV12 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->rgdwPOV[2] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV22 ), strText_ );
                wsprintf( strText_, TEXT("%ld"),
                    g_wheel->GetState(1)->rgdwPOV[3] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV32 ), strText_ );


                // Fill up text with which buttons are pressed
                str_ = strText_;
                for( counter_ = 0; counter_ < 128; counter_++ )
                {
                    if ( g_wheel->GetState(1)->rgbButtons[counter_] & 0x80 )
                        str_ += wsprintf( str_, TEXT("%02d "), counter_ );
                }
                *str_ = 0;   // Terminate the string

                ::SetWindowText( ::GetDlgItem( m_hWnd, IDC_BUTTONS2 ),
                    strText_ );

                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DIRT_ROAD_PLAYING2 ), dirtRoad_[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BUMPY_ROAD_PLAYING2 ), bumpyRoad_[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIPPERY_ROAD_PLAYING2 ), slipperyRoad_[1] );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_CAR_AIRBORNE_PLAYING2 ), airborne_[1] );
            }

        }
        else
        {
            if (index_ == 0)
            {
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DEVICE ), _T("No device connected"));
                // speed
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SPEED ), _T("0") );

                // brake
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BRAKE ), _T("0") );

                // Axes
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_AXIS ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_AXIS ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_AXIS ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_ROT ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_ROT ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_ROT ), _T("0") );

                // Slider controls
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER0 ), _T("0"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER1 ), _T("0"));

                // Points of view
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV0 ), _T("-1"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV1 ), _T("-1"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV2 ), _T("-1"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV3 ), _T("-1"));

                ::SetWindowText( ::GetDlgItem( m_hWnd, IDC_BUTTONS ),
                    _T(""));

                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DIRT_ROAD_PLAYING ), _T("off") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BUMPY_ROAD_PLAYING  ), _T("off") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIPPERY_ROAD_PLAYING  ), _T("off") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_CAR_AIRBORNE_PLAYING  ), _T("off") );
            }

            if (index_ == 1)
            {
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DEVICE2 ), _T("No device connected"));
                // speed
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SPEED2 ), _T("0") );

                // brake
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BRAKE2 ), _T("0") );

                // Axes
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_AXIS2 ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_AXIS2 ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_AXIS2 ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_X_ROT2 ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Y_ROT2 ), _T("0") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_Z_ROT2 ), _T("0") );

                // Slider controls
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER02 ), _T("0"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIDER12 ), _T("0"));

                // Points of view
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV02 ), _T("-1"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV12 ), _T("-1"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV22 ), _T("-1"));
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_POV32 ), _T("-1"));

                ::SetWindowText( ::GetDlgItem( m_hWnd, IDC_BUTTONS2 ),
                    _T(""));

                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_DIRT_ROAD_PLAYING2 ), _T("off") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_BUMPY_ROAD_PLAYING2  ), _T("off") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_SLIPPERY_ROAD_PLAYING2  ), _T("off") );
                ::SetWindowText( ::GetDlgItem( m_hWnd,
                    IDC_CAR_AIRBORNE_PLAYING2  ), _T("off") );
            }
        }
    }
}

void CSteeringWheelSDKDemoDlg::OnDestroy()
{
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

    KillTimer(1);
}

void CSteeringWheelSDKDemoDlg::OnBnClickedButtonGetWheelProperties0()
{
    ControllerPropertiesData propertiesData_;
    ZeroMemory(&propertiesData_, sizeof(propertiesData_));

    if (g_wheel->IsConnected(0))
    {
        ::SetWindowText( GetDlgItem(IDC_EDIT_WHEEL_PROPERTIES0)->m_hWnd, _T("SUCCEEDED"));

        g_wheel->GetCurrentControllerProperties(0, propertiesData_);

        FillGetPropertiesFields(propertiesData_, g_wheel->GetShifterMode(0));
    }
    else
    {
        ::SetWindowText( GetDlgItem(IDC_EDIT_WHEEL_PROPERTIES0)->m_hWnd, _T("FAILED"));

        EmptyGetPropertiesFields();
    }

    ::SetWindowText( GetDlgItem(IDC_EDIT_SET_PREFERRED)->m_hWnd, _T(""));
}

void CSteeringWheelSDKDemoDlg::OnBnClickedButtonGetWheelProperties1()
{
    ControllerPropertiesData propertiesData_;
    ZeroMemory(&propertiesData_, sizeof(propertiesData_));

    if (g_wheel->IsConnected(1))
    {
        ::SetWindowText( GetDlgItem(IDC_EDIT_WHEEL_PROPERTIES1)->m_hWnd, _T("SUCCEEDED"));

        g_wheel->GetCurrentControllerProperties(1, propertiesData_);

        FillGetPropertiesFields(propertiesData_, g_wheel->GetShifterMode(1));
    }
    else
    {
        ::SetWindowText( GetDlgItem(IDC_EDIT_WHEEL_PROPERTIES1)->m_hWnd, _T("FAILED"));

        EmptyGetPropertiesFields();
    }

    ::SetWindowText( GetDlgItem(IDC_EDIT_SET_PREFERRED)->m_hWnd, _T(""));
}

void CSteeringWheelSDKDemoDlg::FillGetPropertiesFields(CONST ControllerPropertiesData propertiesData, CONST INT isGatedShifter)
{
    // Fill out all the fields
    TCHAR text_[MAX_PATH] = {'\0'};

    if (-1 == isGatedShifter)
    {
        ::EnableWindow( GetDlgItem(IDC_STATIC_SHIFTER_GATED)->m_hWnd, FALSE );
        ((CButton*)GetDlgItem(IDC_CHECK_SHIFTER_GATED))->SetCheck(FALSE);
    }
    else
    {
        ::EnableWindow( GetDlgItem(IDC_STATIC_SHIFTER_GATED)->m_hWnd, TRUE );
        ((CButton*)GetDlgItem(IDC_CHECK_SHIFTER_GATED))->SetCheck(isGatedShifter);
    }

    ((CButton*)GetDlgItem(IDC_CHECK_FORCE_ENABLED))->SetCheck(propertiesData.forceEnable);

    _itot_s(propertiesData.overallGain, text_, 10);
    ::SetWindowText( GetDlgItem(IDC_EDIT_OVERALL_GAIN)->m_hWnd, text_);

    _itot_s(propertiesData.springGain, text_, 10);
    ::SetWindowText( GetDlgItem(IDC_EDIT_SPRING_GAIN)->m_hWnd, text_);

    _itot_s(propertiesData.damperGain, text_, 10);
    ::SetWindowText( GetDlgItem(IDC_EDIT_DAMPER_GAIN)->m_hWnd, text_);

    ((CButton*)GetDlgItem(IDC_CHECKDEFAULT_SPRING_ENABLED))->SetCheck(propertiesData.defaultSpringEnabled);

    _itot_s(propertiesData.defaultSpringGain, text_, 10);
    ::SetWindowText( GetDlgItem(IDC_EDIT_DEFAULT_SPRING_GAIN)->m_hWnd, text_);

    ((CButton*)GetDlgItem(IDC_CHECK_PEDALS_COMBINED))->SetCheck(propertiesData.combinePedals);

    _itot_s(propertiesData.wheelRange, text_, 10);
    ::SetWindowText( GetDlgItem(IDC_EDIT_DEGREES_TURN)->m_hWnd, text_);

    ((CButton*)GetDlgItem(IDC_CHECK_USER_ALLOWS_SETTINGS))->SetCheck(propertiesData.allowGameSettings);
}

void CSteeringWheelSDKDemoDlg::EmptyGetPropertiesFields()
{
    // Empty Get fields
    TCHAR text_[MAX_PATH] = {'\0'};

    ::EnableWindow( GetDlgItem(IDC_STATIC_SHIFTER_GATED)->m_hWnd, FALSE );
    ((CButton*)GetDlgItem(IDC_CHECK_SHIFTER_GATED))->SetCheck(FALSE);

    ((CButton*)GetDlgItem(IDC_CHECK_FORCE_ENABLED))->SetCheck(0);

    ::SetWindowText( GetDlgItem(IDC_EDIT_OVERALL_GAIN)->m_hWnd, text_);

    ::SetWindowText( GetDlgItem(IDC_EDIT_SPRING_GAIN)->m_hWnd, text_);

    ::SetWindowText( GetDlgItem(IDC_EDIT_DAMPER_GAIN)->m_hWnd, text_);

    ((CButton*)GetDlgItem(IDC_CHECKDEFAULT_SPRING_ENABLED))->SetCheck(0);

    ::SetWindowText( GetDlgItem(IDC_EDIT_DEFAULT_SPRING_GAIN)->m_hWnd, text_);

    ((CButton*)GetDlgItem(IDC_CHECK_PEDALS_COMBINED))->SetCheck(0);

    ::SetWindowText( GetDlgItem(IDC_EDIT_DEGREES_TURN)->m_hWnd, text_);

    ((CButton*)GetDlgItem(IDC_CHECK_USER_ALLOWS_SETTINGS))->SetCheck(0);
}

HRESULT CSteeringWheelSDKDemoDlg::RetrieveFieldsForSet(ControllerPropertiesData &propertiesData)
{
    TCHAR text_[MAX_PATH] = {'\0'};

    INT enableCheck_ = ((CButton*)GetDlgItem(IDC_CHECK_FORCE_ENABLED))->GetCheck();

    ::GetWindowText(GetDlgItem(IDC_EDIT_OVERALL_GAIN)->m_hWnd, text_, MAX_PATH);
    INT overallGain_ = _wtoi(text_);
    if (overallGain_ < 0 || overallGain_ > 150 || 0 == _tcscmp(_T(""), text_))
    {
        ::MessageBox(NULL, _T("Overall gain needs to be set between 0 and 150"), NULL, MB_OK);
        return E_FAIL;
    }

    ::GetWindowText(GetDlgItem(IDC_EDIT_SPRING_GAIN)->m_hWnd, text_, MAX_PATH);
    INT springGain_ = _wtoi(text_);
    if (springGain_ < 0 || springGain_ > 150 || 0 == _tcscmp(_T(""), text_))
    {
        ::MessageBox(NULL, _T("Spring gain needs to be set between 0 and 150"), NULL, MB_OK);
        return E_FAIL;
    }

    ::GetWindowText(GetDlgItem(IDC_EDIT_DAMPER_GAIN)->m_hWnd, text_, MAX_PATH);
    INT damperGain_ = _wtoi(text_);
    if (damperGain_ < 0 || damperGain_ > 150 || 0 == _tcscmp(_T(""), text_))
    {
        ::MessageBox(NULL, _T("Damper gain needs to be set between 0 and 150"), NULL, MB_OK);
        return E_FAIL;
    }

    INT pedalsAreCombinedCheck_ = ((CButton*)GetDlgItem(IDC_CHECK_PEDALS_COMBINED))->GetCheck();

    ::GetWindowText(GetDlgItem(IDC_EDIT_DEGREES_TURN)->m_hWnd, text_, MAX_PATH);
    INT degreesOfTurn_ = _wtoi(text_);
    if (degreesOfTurn_ < 40 || degreesOfTurn_ > 900)
    {
        ::MessageBox(NULL, _T("Degrees of turn needs to be set between 40 and 900"), NULL, MB_OK);
        return E_FAIL;
    }

    propertiesData.forceEnable = enableCheck_;
    propertiesData.overallGain = overallGain_;
    propertiesData.springGain = springGain_;
    propertiesData.damperGain = damperGain_;
    propertiesData.combinePedals = pedalsAreCombinedCheck_;
    propertiesData.wheelRange = degreesOfTurn_;

    return S_OK;
}

void CSteeringWheelSDKDemoDlg::OnBnClickedButtonDefaults()
{
    ControllerPropertiesData propertiesData_;
    ZeroMemory(&propertiesData_, sizeof(propertiesData_));

    propertiesData_.allowGameSettings = TRUE;
    propertiesData_.combinePedals = FALSE;
    propertiesData_.damperGain = 100;
    propertiesData_.defaultSpringEnabled = TRUE;
    propertiesData_.defaultSpringGain = 100;
    propertiesData_.forceEnable = TRUE;
    propertiesData_.gameSettingsEnabled = FALSE;
    propertiesData_.overallGain = 100;
    propertiesData_.springGain = 100;
    propertiesData_.wheelRange = 200;

    FillGetPropertiesFields(propertiesData_, -1);

    ::SetWindowText( GetDlgItem(IDC_EDIT_SET_PREFERRED)->m_hWnd, _T(""));
}

void CSteeringWheelSDKDemoDlg::OnBnClickedButtonSetPreferred()
{
    ControllerPropertiesData propertiesData_;
    ZeroMemory(&propertiesData_, sizeof(propertiesData_));

    if (SUCCEEDED(RetrieveFieldsForSet(propertiesData_)))
    {
        g_wheel->SetPreferredControllerProperties(propertiesData_);

        ::SetWindowText( GetDlgItem(IDC_EDIT_SET_PREFERRED)->m_hWnd, _T("DONE"));
    }
    else
    {
        ::SetWindowText( GetDlgItem(IDC_EDIT_SET_PREFERRED)->m_hWnd, _T("FAILED"));
    }
}

void CSteeringWheelSDKDemoDlg::OnBnKillfocusButtonSetPreferred()
{
    ::SetWindowText( GetDlgItem(IDC_EDIT_SET_PREFERRED)->m_hWnd, _T(""));
}

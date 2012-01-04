/*
The Logitech Steering Wheel SDK, including all accompanying documentation,
is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_GLOBALS_H_INCLUDED_
#define LOGI_GLOBALS_H_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800

#ifndef _WIN32_DCOM 
#define _WIN32_DCOM 
#endif

#include <tchar.h>
#include <windows.h>
#include "crtdbg.h"

namespace LogitechSteeringWheel
{
#ifdef _DEBUG
#define LOGIWHEELTRACE LogitechSteeringWheel::Utils::LogiTrace
#else
#define LOGIWHEELTRACE __noop
#endif

    CONST USHORT LG_MAX_CONTROLLERS = 2;

    CONST INT LG_TIME_DELAY_ACTUATORS_RESET = 3000; // milliseconds

    CONST INT LG_COLLISION_EFFECT_DURATION = 150; // milliseconds

    typedef enum
    {
        LG_FORCE_NONE = -1,
        LG_FORCE_SPRING,
        LG_FORCE_CONSTANT,
        LG_FORCE_DAMPER,
        LG_FORCE_SIDE_COLLISION,
        LG_FORCE_FRONTAL_COLLISION,
        LG_FORCE_DIRT_ROAD,
        LG_FORCE_BUMPY_ROAD,
        LG_FORCE_SLIPPERY_ROAD,
        LG_FORCE_SURFACE_EFFECT,
        LG_NUMBER_FORCE_EFFECTS, LG_FORCE_SOFTSTOP, LG_FORCE_CAR_AIRBORNE
    } ForceType;

    typedef enum
    {
        LG_TYPE_NONE = -1, LG_TYPE_SINE, LG_TYPE_SQUARE, LG_TYPE_TRIANGLE
    } PeriodicType;

    // define buttons for better cross platform compatibility with PS2
    /*typedef enum
    {
        LG_BUTTON_BUTTON0 = 0, LG_BUTTON_BUTTON1, LG_BUTTON_BUTTON2, LG_BUTTON_BUTTON3, LG_BUTTON_BUTTON4,
        LG_BUTTON_BUTTON5, LG_BUTTON_BUTTON6, LG_BUTTON_BUTTON7, LG_BUTTON_BUTTON8, LG_BUTTON_BUTTON9,
        LG_BUTTON_BUTTON10, LG_BUTTON_BUTTON11, LG_BUTTON_BUTTON12, LG_BUTTON_BUTTON13, LG_BUTTON_BUTTON14,
        LG_BUTTON_BUTTON15, LG_BUTTON_BUTTON16, LG_BUTTON_BUTTON17, LG_BUTTON_BUTTON18, LG_BUTTON_BUTTON19,
        LG_BUTTON_BUTTON20, LG_BUTTON_BUTTON21, LG_BUTTON_BUTTON22, LG_BUTTON_BUTTON23, LG_BUTTON_BUTTON24,
        LG_BUTTON_BUTTON25, LG_BUTTON_BUTTON26, LG_BUTTON_BUTTON27, LG_BUTTON_BUTTON28, LG_BUTTON_BUTTON29,
        LG_BUTTON_BUTTON30, LG_BUTTON_BUTTON31
    } Button;*/


    //#define _DEBUG

#define _DEBUG_BASIC // prints basic and error messages if active. Comment this and _DEBUG out if you wish to have no messages at all.
}

#endif // LOGI_GLOBALS_H_INCLUDED_

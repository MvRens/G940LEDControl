/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_GLOBALS_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_GLOBALS_H_INCLUDED_

#include <tchar.h>
#include <windows.h>
#include "crtdbg.h"

namespace LogitechControlsAssignmentSDK
{
#ifdef _DEBUG
#define LOGIASSIGNTRACE LogitechControlsAssignmentSDK::Utils::LogiTrace
#else
#define LOGIASSIGNTRACE __noop
#endif

    CONST INT LG_MAX_NUMBER_SUPPORTED_CONTROLLERS = 4;

    CONST TCHAR SIGN_POSITIVE_RANGE[] = _T("+");
    CONST TCHAR SIGN_NEGATIVE_RANGE[] = _T("-");
    CONST TCHAR SIGN_FULL_RANGE[] = _T("+/-");

    // DirectInput control names
    CONST TCHAR NAME_DINPUT_AXIS_X[] = _T("X Axis");
    CONST TCHAR NAME_DINPUT_AXIS_Y[] = _T("Y Axis");
    CONST TCHAR NAME_DINPUT_AXIS_Z[] = _T("Z Axis");
    CONST TCHAR NAME_DINPUT_AXIS_RX[] = _T("Rx Axis");
    CONST TCHAR NAME_DINPUT_AXIS_RY[] = _T("Ry Axis");
    CONST TCHAR NAME_DINPUT_AXIS_RZ[] = _T("Rz Axis");
    CONST TCHAR NAME_DINPUT_AXIS_S0[] = _T("Slider 0");
    CONST TCHAR NAME_DINPUT_AXIS_S1[] = _T("Slider 1");
    CONST TCHAR NAME_DINPUT_BUTTON[] = _T("Btn");
    CONST TCHAR NAME_DINPUT_CONTROLLER[] = _T("Controller");
    CONST TCHAR NAME_DINPUT_POV[] = _T("DPad");
    CONST TCHAR NAME_DINPUT_POV_UP[] = _T("Up");
    CONST TCHAR NAME_DINPUT_POV_DOWN[] = _T("Down");
    CONST TCHAR NAME_DINPUT_POV_LEFT[] = _T("Left");
    CONST TCHAR NAME_DINPUT_POV_RIGHT[] = _T("Right");

    // XInput Control names
    CONST TCHAR NAME_XINPUT_AXIS_LEFT_TRIGGER[] = _T("Left Trigger");
    CONST TCHAR NAME_XINPUT_AXIS_RIGHT_TRIGGER[] = _T("Right Trigger");
    CONST TCHAR NAME_XINPUT_AXIS_THUMB_LX[] = _T("Thumb Left X");
    CONST TCHAR NAME_XINPUT_AXIS_THUMB_LY[] = _T("Thumb Left Y");
    CONST TCHAR NAME_XINPUT_AXIS_THUMB_RX[] = _T("Thumb Right X");
    CONST TCHAR NAME_XINPUT_AXIS_THUMB_RY[] = _T("Thumb Right Y");
    CONST TCHAR NAME_XINPUT_POV_UP[] = _T("Up");
    CONST TCHAR NAME_XINPUT_POV_DOWN[] = _T("Down");
    CONST TCHAR NAME_XINPUT_POV_LEFT[] = _T("Left");
    CONST TCHAR NAME_XINPUT_POV_RIGHT[] = _T("Right");
    CONST TCHAR NAME_XINPUT_BUTTON_START[] = _T("Start");
    CONST TCHAR NAME_XINPUT_BUTTON_BACK[] = _T("Back");
    CONST TCHAR NAME_XINPUT_BUTTON_LEFT_THUMB[] = _T("Left Thumb");
    CONST TCHAR NAME_XINPUT_BUTTON_RIGHT_THUMB[] = _T("Right Thumb");
    CONST TCHAR NAME_XINPUT_BUTTON_LEFT_SHOULDER[] = _T("Left Shoulder");
    CONST TCHAR NAME_XINPUT_BUTTON_RIGHT_SHOULDER[] = _T("Right Shoulder");
    CONST TCHAR NAME_XINPUT_BUTTON_A[] = _T("A");
    CONST TCHAR NAME_XINPUT_BUTTON_B[] = _T("B");
    CONST TCHAR NAME_XINPUT_BUTTON_X[] = _T("X");
    CONST TCHAR NAME_XINPUT_BUTTON_Y[] = _T("Y");
    CONST TCHAR NAME_XINPUT_BUTTON[] = _T("Btn");
    CONST TCHAR NAME_XINPUT_CONTROLLER[] = _T("Controller");
    CONST TCHAR NAME_XINPUT_POV[] = _T("DPad");

    CONST FLOAT AXES_RANGE_MIN_NORMALIZED = -1.0f;
    CONST FLOAT AXES_RANGE_MAX_NORMALIZED = 1.0f;
    CONST FLOAT AXES_CENTER_POSITION_NORMALIZED = (AXES_RANGE_MAX_NORMALIZED + AXES_RANGE_MIN_NORMALIZED) / 2.0f;

    typedef enum
    {
        LG_CONTROLLER_TYPE_NONE = -1, LG_CONTROLLER_TYPE_DINPUT, LG_CONTROLLER_TYPE_XINPUT

    } ControllerType;

    typedef enum
    {
        LG_RANGE_NONE = -1, LG_POSITIVE_RANGE, LG_NEGATIVE_RANGE, LG_FULL_RANGE,
        NUMBER_AXES_RANGE_TYPES
    } AxisRangeType;

    CONST INT LG_CONTROLLER_DISCONNECTED = -1;
}

#endif // LOGI_CONTROLS_ASSIGNMENT_GLOBALS_H_INCLUDED_

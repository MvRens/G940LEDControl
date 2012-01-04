/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_XINPUT_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_XINPUT_H_INCLUDED_

#include "LogiAxis.h"
#include "LogiButton.h"
#include "LogiPovDirection.h"
#include "LogiController.h"
#include <XInput.h>

namespace LogitechControlsAssignmentSDK
{
    CONST INT MAX_NUMBER_POVS_XINPUT = 1;
    CONST LONG AXIS_TRIGGERS_RANGE_MIN_XINPUT = 0;
    CONST LONG AXIS_TRIGGERS_RANGE_MAX_XINPUT = 255;
    CONST LONG AXIS_OTHER_RANGE_MIN_XINPUT = -32768;
    CONST LONG AXIS_OTHER_RANGE_MAX_XINPUT = 32767;

    typedef enum
    {
        LG_AXIS_LEFT_TRIGGER, LG_AXIS_RIGHT_TRIGGER, LG_AXIS_THUMB_LX, LG_AXIS_THUMB_LY, LG_AXIS_THUMB_RX, LG_AXIS_THUMB_RY,
        LG_NBR_AXES_XINPUT
    } AxisIDXInput;

    typedef enum
    {
        LG_BUTTON_NONE = -1, LG_BUTTON_START, LG_BUTTON_BACK, LG_BUTTON_LEFT_THUMB, LG_BUTTON_RIGHT_THUMB, LG_BUTTON_LEFT_SHOULDER, LG_BUTTON_RIGHT_SHOULDER, LG_BUTTON_A, LG_BUTTON_B, LG_BUTTON_X, LG_BUTTON_Y,
        LG_NBR_BUTTONS_XINPUT
    } ButtonIDXinput;

    class ControllerXInput: public Controller
    {
    public:
        ControllerXInput();
        ~ControllerXInput();

        VOID SetInitialValues();
        Control* ControlMoved();
        Control* GetControl(CONST ControlAssignment& controlAssignment);
        HRESULT Update(CONST INT index, CONST XINPUT_STATE* state);

    private:
        Axis m_axis[LG_NBR_AXES_XINPUT][NUMBER_AXES_RANGE_TYPES];
        Button m_button[LG_NBR_BUTTONS_XINPUT];
        PovDirection m_POVDirection[MAX_NUMBER_POVS_XINPUT][LG_NUMBER_POV_DIR];
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_DINPUT_H_INCLUDED_

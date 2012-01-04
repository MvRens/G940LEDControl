/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_DINPUT_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_DINPUT_H_INCLUDED_

#ifndef DIRECTINPUT_VERSION
#define DIRECTINPUT_VERSION 0x0800
#endif

#include "LogiAxis.h"
#include "LogiButton.h"
#include "LogiPovDirection.h"
#include "LogiController.h"
#include <dinput.h>

namespace LogitechControlsAssignmentSDK
{
    CONST INT MAX_NUMBER_POVS_DINPUT = 4;
    CONST INT MAX_NUMBER_BUTTONS_DINPUT = 32;

    typedef enum
    {
        LG_AXIS_NONE = -1, LG_AXIS_X, LG_AXIS_Y, LG_AXIS_Z, LG_AXIS_RX, LG_AXIS_RY, LG_AXIS_RZ, LG_AXIS_S0, LG_AXIS_S1,
        LG_NBR_AXES_DINPUT
    } AxisIDDInput;

    class ControllerDInput : public Controller
    {
    public:
        ControllerDInput();
        ~ControllerDInput();

        VOID Init(CONST LONG axesRangeMin, CONST LONG axesRangeMax);
        VOID SetInitialValues();
        Control* ControlMoved();
        Control* GetControl(CONST ControlAssignment& controlAssignment);
        HRESULT Update(CONST INT index, CONST DIJOYSTATE2* state);

    private:
        Axis m_axis[LG_NBR_AXES_DINPUT][NUMBER_AXES_RANGE_TYPES];
        Button m_button[MAX_NUMBER_BUTTONS_DINPUT];
        PovDirection m_POVDirection[MAX_NUMBER_POVS_DINPUT][LG_NUMBER_POV_DIR];

        LONG m_axesRangeMin;
        LONG m_axesRangeMax;
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_DINPUT_H_INCLUDED_

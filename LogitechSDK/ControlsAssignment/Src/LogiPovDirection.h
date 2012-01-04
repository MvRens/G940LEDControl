/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_POV_DIRECTION_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_POV_DIRECTION_H_INCLUDED_

#ifndef DIRECTINPUT_VERSION
#define DIRECTINPUT_VERSION 0x0800
#endif

#include "LogiControl.h"
#include <dinput.h>
#include <XInput.h>

namespace LogitechControlsAssignmentSDK
{
    CONST FLOAT POVS_RANGE_MIN = 0.0f;
    CONST FLOAT POVS_RANGE_MAX = 1.0f;

    // POV directions
    typedef enum
    {
        LG_POV_NONE = -1, LG_POV_RIGHT, LG_POV_LEFT, LG_POV_UP, LG_POV_DOWN,
        LG_NUMBER_POV_DIR
    } PovDirectionEnum;

    class PovDirection: public Control
    {
    public:
        PovDirection();
        virtual ~PovDirection();

        VOID Initialize();

        VOID SetPovNumber(CONST INT number);
        INT GetPovNumber();

        VOID SetDirection(CONST PovDirectionEnum direction);
        PovDirectionEnum GetDirection();

        INT Pressed(CONST DIJOYSTATE2* state);
        INT Pressed(CONST XINPUT_STATE* state);

        BOOL Moved();

    protected:
        INT m_povNumber;
        PovDirectionEnum m_direction;
    };
}
#endif // LOGI_CONTROLS_ASSIGNMENT_POV_DIRECTION_H_INCLUDED_

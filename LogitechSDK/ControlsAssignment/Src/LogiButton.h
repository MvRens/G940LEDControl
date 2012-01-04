/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_BUTTON_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_BUTTON_H_INCLUDED_

#include "LogiControl.h"

namespace LogitechControlsAssignmentSDK
{
    CONST FLOAT BUTTONS_RANGE_MIN = 0.0f;
    CONST FLOAT BUTTONS_RANGE_MAX = 1.0f;

    class Button: public Control
    {
    public:
        Button();
        virtual ~Button();

        VOID Initialize();

        VOID SetNumber(CONST INT number);
        INT GetNumber();

        BOOL Moved();

    protected:
        INT m_number;
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_BUTTON_H_INCLUDED_

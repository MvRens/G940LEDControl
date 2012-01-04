/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_GAME_ACTION_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_GAME_ACTION_H_INCLUDED_

#include "LogiControl.h"

namespace LogitechControlsAssignmentSDK
{
    class GameAction
    {
    public:
        GameAction();
        ~GameAction();

        VOID SetControl(Control* control);
        Control* GetControl();
        FLOAT GetValue();

        VOID StartCheckingForInput();
        VOID StopCheckingForInput();

        BOOL IsCheckingForInput();

        VOID ResetIfSameControl(CONST Control* control);

        VOID SetID(CONST INT ID);
        INT GetID();

    private:
        BOOL m_isCheckingForInput;
        Control* m_control;
        INT m_ID;	
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_GAME_ACTION_H_INCLUDED_

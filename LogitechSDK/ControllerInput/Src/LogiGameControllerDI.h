/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_DI_H_INCLUDED_
#define LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_DI_H_INCLUDED_

#include "LogiGameController.h"

namespace LogitechControllerInput
{
    class LogiGameControllerDI : public LogiGameController
    {
    public:
        LogiGameControllerDI(CONST INT index, CONST HWND gameHWnd);

        VOID Init();

        HRESULT Read();

        DIJOYSTATE2* GetStateDInput();

        BOOL ButtonIsPressed(CONST INT buttonNbr);
        BOOL ButtonTriggered(CONST INT buttonNbr);
        BOOL ButtonReleased(CONST INT buttonNbr);

        BOOL HasForceFeedback();

        VOID SetNumberFFAxes(CONST INT number);
        INT GetNumberFFAxes();

    private:
        DIJOYSTATE2 m_currentState;
        DIJOYSTATE2 m_previousState;

    };
}

#endif // LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_DI_H_INCLUDED_

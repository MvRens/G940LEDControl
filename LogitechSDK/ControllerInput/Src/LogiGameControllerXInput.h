/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_XINPUT_H_INCLUDED_
#define LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_XINPUT_H_INCLUDED_

#include "LogiGameController.h"

namespace LogitechControllerInput
{
    class LogiGameControllerXInput : public LogiGameController
    {
    public:
        LogiGameControllerXInput(CONST INT index, CONST HWND gameHWnd);

        VOID Init();

        HRESULT Read();

        XINPUT_STATE* GetStateXInput();

        BOOL ButtonIsPressed(CONST INT mask);
        BOOL ButtonTriggered(CONST INT mask);
        BOOL ButtonReleased(CONST INT mask);

        BOOL HasForceFeedback();

        // Set and get XInput ID
        HRESULT SetDeviceXInputID(CONST INT idNbr);
        INT GetDeviceXInputID();

    private:
        XINPUT_STATE m_currentState;
        XINPUT_STATE m_previousState;
    };
}

#endif // LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_XINPUT_H_INCLUDED_

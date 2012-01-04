/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/


#include "LogiGameControllerXInput.h"
#include "LogiControllerInputUtils.h"

using namespace LogitechControllerInput;

LogiGameControllerXInput::LogiGameControllerXInput(CONST INT index, CONST HWND gameHWnd)
{
    m_ctrlNbr = index;
    m_gameHWnd = gameHWnd;

    m_isXInputDevice = TRUE;

    Init();
}

VOID LogiGameControllerXInput::Init()
{
    ZeroMemory(&m_currentState, sizeof(m_currentState));
    ZeroMemory(&m_previousState, sizeof(m_previousState));
}

HRESULT LogiGameControllerXInput::Read()
{
    DWORD dwResult_ = ERROR_SUCCESS;    

    m_previousState = m_currentState;

    dwResult_ = XInputGetState( m_deviceXID, &m_currentState );

    if( dwResult_ != ERROR_SUCCESS )
    {
        LOGICONTROLLERTRACE(_T("Warning: failed to read XInput device (m_ctrlNbr %d, m_deviceXID %d)\n"), m_ctrlNbr, m_deviceXID);
        return E_FAIL;;
    }

    return S_OK;
}

XINPUT_STATE* LogiGameControllerXInput::GetStateXInput()
{
    return &m_currentState;
}

BOOL LogiGameControllerXInput::ButtonIsPressed(INT mask)
{
    return (m_currentState.Gamepad.wButtons & mask);
}

BOOL LogiGameControllerXInput::ButtonTriggered(INT mask)
{
    return (!(m_previousState.Gamepad.wButtons & mask) &&
        (m_currentState.Gamepad.wButtons & mask));
}

BOOL LogiGameControllerXInput::ButtonReleased(INT mask)
{
    return ((m_previousState.Gamepad.wButtons & mask) &&
        !(m_currentState.Gamepad.wButtons & mask));
}

BOOL LogiGameControllerXInput::HasForceFeedback()
{
    XINPUT_CAPABILITIES capabilities_;
    ZeroMemory(&capabilities_, sizeof(capabilities_));
    if (ERROR_SUCCESS != XInputGetCapabilities(m_deviceXID, XINPUT_FLAG_GAMEPAD, &capabilities_))
        return FALSE;

    if (capabilities_.SubType == XINPUT_DEVSUBTYPE_GAMEPAD)
    {
        if (capabilities_.Vibration.wLeftMotorSpeed == 0 && capabilities_.Vibration.wRightMotorSpeed == 0)
        {
            return FALSE;
        }
        else
        {
            return TRUE;
        }
    }

    return TRUE;    
}

HRESULT LogiGameControllerXInput::SetDeviceXInputID(INT idNbr)
{
    m_deviceXID = idNbr;

    return S_OK;
}

INT LogiGameControllerXInput::GetDeviceXInputID()
{
    return m_deviceXID;
}

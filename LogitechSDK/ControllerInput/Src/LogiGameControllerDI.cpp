/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/


#include "LogiGameControllerDI.h"
#include "LogiControllerInputUtils.h"

using namespace LogitechControllerInput;

LogiGameControllerDI::LogiGameControllerDI(CONST INT index, CONST HWND gameHWnd)
{
    m_ctrlNbr = index;
    m_gameHWnd = gameHWnd;
    m_isXInputDevice = FALSE;

    Init();
}

VOID LogiGameControllerDI::Init()
{
    ZeroMemory(&m_currentState, sizeof(m_currentState));
    ZeroMemory(&m_previousState, sizeof(m_previousState));

    for (INT ii = 0; ii < 4; ii++)
    {
        m_currentState.rgdwPOV[ii] = 0xffffffff;
        m_previousState.rgdwPOV[ii] = 0xffffffff;
    }
}

HRESULT LogiGameControllerDI::Read()
{
    HRESULT hr_ = E_FAIL;

    if(NULL == m_device)
    {
        LOGICONTROLLERTRACE(_T("ERROR: trying to read a gaming device that doesn't have a handle\n"));
        return hr_;
    }

    // Poll the device to read the current state
    hr_ = m_device->Poll();
    if( FAILED(hr_) )
    {
        // DInput is telling us that the input stream has been
        // interrupted. We aren't tracking any state between polls, so
        // we don't have any special reset that needs to be done. We
        // just re-acquire and try again.
        hr_ = m_device->Acquire();

        if (SUCCEEDED(hr_))
        {
            // This only gets called once after window regains focus. This disables centering
            // spring on Logitech wheels.
            if (HasForceFeedback() && LG_DEVICE_TYPE_WHEEL == m_deviceType)
            {
                if (FAILED(hr_ = m_device->SendForceFeedbackCommand(DISFFC_SETACTUATORSON)))
                {
                    LOGICONTROLLERTRACE(_T("WARNING: Controller nbr %d: failed to set actuators to ON\n"), m_ctrlNbr);
                    m_actuatorsAreOn = FALSE;
                }
                else
                {
                    m_actuatorsAreOn = TRUE;
                }
            }
        }

        // hr_ may be DIERR_OTHERAPPHASPRIO or other errors.  This
        // may occur when the app is minimized or in the process of
        // switching, so just try again later
        return S_OK;
    }

    // Set actuators on. This command will take off the centering spring on the logitech wheel.
    if (!m_actuatorsAreOn && HasForceFeedback() && LG_DEVICE_TYPE_WHEEL == m_deviceType)
    {
        if (FAILED(hr_ = m_device->SendForceFeedbackCommand(DISFFC_SETACTUATORSON)))
        {
            LOGICONTROLLERTRACE(_T("WARNING: Controller nbr %d: failed to set actuators to ON\n"), m_ctrlNbr);
            m_actuatorsAreOn = FALSE;
        }
        else
        {
            m_actuatorsAreOn = TRUE;
        }
    }

    // Save the last position
    m_previousState = m_currentState;

    // Get the input's device state
    if( FAILED( hr_ = m_device->GetDeviceState( sizeof(DIJOYSTATE2), &m_currentState ) ) )
    {
        LOGICONTROLLERTRACE(_T("WARNING: could not retrieve positional information for gaming device\n"));
        if (hr_ == DIERR_INPUTLOST)
        {
            //TRACE(_T("Gaming device got unplugged!\n"));
            ZeroMemory(&m_currentState, sizeof(m_currentState));
            for (INT ii = 0; ii < 4; ii++)
            {
                m_currentState.rgdwPOV[ii] = 0xffffffff;
            }
        }
        return hr_; // The device should have been acquired during the Poll()
    }

    // For some bloody reason, XInput gamepads report their Y axes on both left and right ministick the opposite than DInput devices.
    // So let's invert the DInput gamepad ministick Y axes in order to get it all the same...
    if (LG_DEVICE_TYPE_GAMEPAD == m_deviceType)
    {
        m_currentState.lY = -m_currentState.lY - 1;
        m_currentState.lRz = -m_currentState.lRz - 1;
    }

    return S_OK;
}

DIJOYSTATE2* LogiGameControllerDI::GetStateDInput()
{
    return &m_currentState;
}

BOOL LogiGameControllerDI::ButtonIsPressed(INT buttonNbr)
{
    return (m_currentState.rgbButtons[buttonNbr] & 0x80 );
}

BOOL LogiGameControllerDI::ButtonTriggered(INT buttonNbr)
{
    return (!(m_previousState.rgbButtons[buttonNbr] & 0x80) &&
        (m_currentState.rgbButtons[buttonNbr] & 0x80));
}

BOOL LogiGameControllerDI::ButtonReleased(INT buttonNbr)
{
    return ((m_previousState.rgbButtons[buttonNbr] & 0x80) &&
        !(m_currentState.rgbButtons[buttonNbr] & 0x80));
}

BOOL LogiGameControllerDI::HasForceFeedback()
{
    if (m_numFFAxes > 0)
        return TRUE;

    return FALSE;
}

VOID LogiGameControllerDI::SetNumberFFAxes(INT number)
{
    m_numFFAxes = number;
}

INT LogiGameControllerDI::GetNumberFFAxes()
{
    return m_numFFAxes;
}

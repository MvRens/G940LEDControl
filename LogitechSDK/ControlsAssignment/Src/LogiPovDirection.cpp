/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiPovDirection.h"

using namespace LogitechControlsAssignmentSDK;

PovDirection::PovDirection()
{
    Initialize();
}

PovDirection::~PovDirection()
{
}

VOID PovDirection::SetPovNumber(CONST INT number)
{
    m_povNumber = number;
}

INT PovDirection::GetPovNumber()
{
    return m_povNumber;
}

VOID PovDirection::SetDirection(CONST PovDirectionEnum direction)
{
    m_direction = direction;
}

PovDirectionEnum PovDirection::GetDirection()
{
    return m_direction;
}

// Check if a POV is being pressed
INT PovDirection::Pressed(CONST DIJOYSTATE2* state)
{
    _ASSERT(NULL != state);
    if (NULL == state)
        return FALSE;

    switch (m_direction)
    {
    case LG_POV_UP:
        if (state->rgdwPOV[m_povNumber] == 31500 || state->rgdwPOV[m_povNumber] == 0 || state->rgdwPOV[m_povNumber] == 4500)
            return TRUE;
        break;
    case LG_POV_DOWN:
        if (state->rgdwPOV[m_povNumber] == 13500 || state->rgdwPOV[m_povNumber] == 18000 || state->rgdwPOV[m_povNumber] == 22500)
            return TRUE;
        break;
    case LG_POV_RIGHT:
        if (state->rgdwPOV[m_povNumber] == 4500 || state->rgdwPOV[m_povNumber] == 9000 || state->rgdwPOV[m_povNumber] == 13500)
            return TRUE;
        break;
    case LG_POV_LEFT:
        if (state->rgdwPOV[m_povNumber] == 22500 || state->rgdwPOV[m_povNumber] == 27000 || state->rgdwPOV[m_povNumber] == 31500)
            return TRUE;
        break;
    default:
        _ASSERT(0);
    }

    return FALSE;
}

INT PovDirection::Pressed(CONST XINPUT_STATE* state)
{
    _ASSERT(NULL != state);
    if (NULL == state)
        return FALSE;

    switch (m_direction)
    {
    case LG_POV_UP:
        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_UP)
            return TRUE;
        break;
    case LG_POV_DOWN:
        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_DOWN)
            return TRUE;
        break;
    case LG_POV_RIGHT:
        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_RIGHT)
            return TRUE;
        break;
    case LG_POV_LEFT:
        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_LEFT)
            return TRUE;
        break;
    default:
        _ASSERT(0);
    }

    return FALSE;
}

VOID PovDirection::Initialize()
{
    m_type = CONTROL_TYPE_POV;
    m_povNumber = -1;
    m_value = POVS_RANGE_MIN;
    m_direction = LG_POV_NONE;
}

BOOL PovDirection::Moved()
{
    return (POVS_RANGE_MAX == m_value) ? TRUE : FALSE;
}
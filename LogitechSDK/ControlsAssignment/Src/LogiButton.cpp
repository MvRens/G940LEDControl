/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiButton.h"

using namespace LogitechControlsAssignmentSDK;

Button::Button()
{
    Initialize();
}

Button::~Button()
{
}

VOID Button::SetNumber(CONST INT number)
{
    m_number = number;
}

INT Button::GetNumber()
{
    return m_number;
}

VOID Button::Initialize()
{
    m_number = -1;
    m_value = BUTTONS_RANGE_MIN;
    m_type = CONTROL_TYPE_BUTTON;
}

BOOL Button::Moved()
{
    return (BUTTONS_RANGE_MAX == m_value) ? TRUE : FALSE;
}
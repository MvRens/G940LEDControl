/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiControl.h"

using namespace LogitechControlsAssignmentSDK;

Control::Control()
{
    Initialize();
}

Control::~Control()
{
}

HRESULT Control::SetType(CONST ControlType type)
{
    m_type = type;
    return S_OK;
}

ControlType Control::GetType()
{
    return m_type;
}

VOID Control::SetInitialValue()
{
    m_initialValue = m_value;
}

FLOAT Control::GetInitialValue()
{
    return m_initialValue;
}

VOID Control::Initialize()
{
    m_controlName[0] = '\0';
    m_value = 0.0f;
    m_type = CONTROL_TYPE_NONE;
    m_initialValue = 0.0f;
    m_controllerIndex = LG_CONTROLLER_DISCONNECTED;
    m_controllerType = LG_CONTROLLER_TYPE_NONE;
}
LPCTSTR Control::GetName()
{
    return m_controlName;
}

HRESULT Control::SetName(LPCTSTR name)
{
    errno_t ret_ = _tcscpy_s(m_controlName, name);

    if (0 == ret_)
        return S_OK;

    return E_FAIL;
}

VOID Control::SetControllerIndex(CONST INT index)
{
    m_controllerIndex = index;
}

INT Control::GetControllerIndex()
{
    return m_controllerIndex;
}

VOID Control::SetControllerType(CONST ControllerType type)
{
    m_controllerType = type;
}

INT Control::GetControllerType()
{
    return m_controllerType;

}

AxisRangeType Control::GetRangeType()
{
    // By default we suppose a positive range
    return LG_POSITIVE_RANGE;
}

VOID Control::SetValue(CONST FLOAT value)
{
    m_value = value;
}

FLOAT Control::GetValue()
{
    return m_value;
}


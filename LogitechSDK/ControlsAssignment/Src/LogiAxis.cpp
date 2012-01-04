/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiAxis.h"
#include "LogiControlsAssignmentUtils.h"

using namespace LogitechControlsAssignmentSDK;

Axis::Axis()
{
    Initialize();
}

Axis::~Axis()
{
}

FLOAT Axis::GetValue()
{
    switch (m_rangeType)
    {
    case LG_POSITIVE_RANGE:
        return (0 > m_value) ? 0.0f : m_value;
    case LG_NEGATIVE_RANGE:
        return (0 <= m_value) ? 0.0f : m_value;
    case LG_FULL_RANGE:
        if (m_initialValue < AXES_CENTER_POSITION_NORMALIZED)
        {
            return (m_value - AXES_RANGE_MIN_NORMALIZED) / (AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED);
        }
        else
        {
            return 1 - ((m_value - AXES_RANGE_MIN_NORMALIZED) / (AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED));
        }
    default:
        _ASSERT(0);
    }

    return 0.0f;
}

FLOAT Axis::GetRangeIndepValue()
{
    return m_value;
}

// Check if an axis has the center as initial value
BOOL Axis::IsCentered()
{
    FLOAT centerValue = ((AXES_RANGE_MAX_NORMALIZED + AXES_RANGE_MIN_NORMALIZED) / 2.0f);
    if (Utils::Abs(m_initialValue - centerValue) < (0.2f * (AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED))) // Joystick
    {
        return TRUE;
    }
    return FALSE;
}

// Check if current value is on the other side of the axis' compared to the initial value
BOOL Axis::SideFromCenterDiffers()
{
    FLOAT centerPosition_ = (AXES_RANGE_MAX_NORMALIZED + AXES_RANGE_MIN_NORMALIZED) / 2.0f;

    if ((m_value >= centerPosition_ && m_initialValue < centerPosition_)
        || (m_value < centerPosition_ && m_initialValue >= centerPosition_))
    {
        return TRUE;
    }
    return FALSE;
}

VOID Axis::Initialize()
{
    m_type = CONTROL_TYPE_AXIS;
    m_rangeType = LG_RANGE_NONE;
    m_axisName[0] = '\0';
    m_axisID = -1;
}

HRESULT Axis::SetAxisName(CONST LPCTSTR axisName)
{
    errno_t ret_ = _tcscpy_s(m_axisName, axisName);

    if (0 == ret_)
        return S_OK;

    return E_FAIL;
}

LPCTSTR Axis::GetAxisName()
{
    return m_axisName;
}

VOID Axis::SetRangeType(CONST AxisRangeType range)
{
    m_rangeType = range;
}

AxisRangeType Axis::GetRangeType()
{
    return m_rangeType;
}

BOOL Axis::Moved()
{
    if (IsCentered())
    {
        if ((m_value - m_initialValue) > ((AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED) / 4)
            || (m_value - m_initialValue) < - ((AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED) / 4))
        {
            if (m_value - m_initialValue > 0)
            {
                if (LG_POSITIVE_RANGE == m_rangeType)
                {
                    return TRUE;
                }
            }
            else if (m_value - m_initialValue < 0)
            {
                if (LG_NEGATIVE_RANGE == m_rangeType)
                {
                    return TRUE;
                }
            }
        }
    }
    else // m_axis not automatically centered
    {
        if ((((m_value - AXES_CENTER_POSITION_NORMALIZED) > ((AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED) / 4))
            || ((AXES_CENTER_POSITION_NORMALIZED - m_value ) > ((AXES_RANGE_MAX_NORMALIZED - AXES_RANGE_MIN_NORMALIZED) / 4)))
            && SideFromCenterDiffers())
        {
            if (LG_FULL_RANGE == m_rangeType)
            {
                return TRUE;
            }
        }
    }

    return FALSE;
}

VOID Axis::SetAxisID(INT axisID)
{
    m_axisID = axisID;
}

INT Axis::GetAxisID()
{
    return m_axisID;
}

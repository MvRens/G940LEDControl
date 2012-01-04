/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiControllerDInput.h"
#include "LogiControlsAssignmentUtils.h"

using namespace LogitechControlsAssignmentSDK;

ControllerDInput::ControllerDInput()
{
    m_type = LG_CONTROLLER_TYPE_DINPUT;
    m_axesRangeMin = 0;
    m_axesRangeMax = 0;

    for (INT ll = 0; ll < NUMBER_AXES_RANGE_TYPES; ll++)
    {
        // Set axes names
        m_axis[LG_AXIS_X][ll].SetAxisName(NAME_DINPUT_AXIS_X);
        m_axis[LG_AXIS_Y][ll].SetAxisName(NAME_DINPUT_AXIS_Y);
        m_axis[LG_AXIS_Z][ll].SetAxisName(NAME_DINPUT_AXIS_Z);
        m_axis[LG_AXIS_RX][ll].SetAxisName(NAME_DINPUT_AXIS_RX);
        m_axis[LG_AXIS_RY][ll].SetAxisName(NAME_DINPUT_AXIS_RY);
        m_axis[LG_AXIS_RZ][ll].SetAxisName(NAME_DINPUT_AXIS_RZ);
        m_axis[LG_AXIS_S0][ll].SetAxisName(NAME_DINPUT_AXIS_S0);
        m_axis[LG_AXIS_S1][ll].SetAxisName(NAME_DINPUT_AXIS_S1);

        for (INT mm = 0; mm < LG_NBR_AXES_DINPUT; mm++)
        {
            m_axis[mm][ll].SetAxisID(mm);
            m_axis[mm][ll].SetRangeType(static_cast<AxisRangeType>(ll));
        }
    }

    // Set buttons names
    for (INT ii = 0; ii < MAX_NUMBER_BUTTONS_DINPUT; ii++)
    {
        m_button[ii].SetNumber(ii);
    }

    // Set POVs names
    for (INT ii = 0; ii < MAX_NUMBER_POVS_DINPUT; ii++)
    {
        for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
        {
            m_POVDirection[ii][jj].SetPovNumber(ii);
            m_POVDirection[ii][jj].SetDirection(static_cast<PovDirectionEnum>(jj));
        }
    }
}

ControllerDInput::~ControllerDInput()
{
}

VOID ControllerDInput::Init(CONST LONG axesRangeMin, CONST LONG axesRangeMax)
{
    m_axesRangeMin = axesRangeMin;
    m_axesRangeMax = axesRangeMax;
}

VOID ControllerDInput::SetInitialValues()
{
    for (INT ii = 0; ii < LG_NBR_AXES_DINPUT; ii++)
    {
        for (INT jj = 0; jj < NUMBER_AXES_RANGE_TYPES; jj++)
        {
            m_axis[ii][jj].SetInitialValue();
        }
    }

    for (INT ii = 0; ii < MAX_NUMBER_BUTTONS_DINPUT; ii++)
    {
        m_button[ii].SetInitialValue();
    }

    for (INT ii = 0; ii < MAX_NUMBER_POVS_DINPUT; ii++)
    {
        for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
        {
            m_POVDirection[ii][jj].SetInitialValue();
        }
    }
}

HRESULT ControllerDInput::Update(CONST INT index, CONST DIJOYSTATE2* state)
{
    SetIndex(index);

    if (index != LG_CONTROLLER_DISCONNECTED)
    {
        for (INT ll = 0; ll < NUMBER_AXES_RANGE_TYPES; ll++)
        {
            // Set normalized values.
            m_axis[LG_AXIS_X][ll].SetValue(Utils::GetNormalizedValue(state->lX, m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_Y][ll].SetValue(Utils::GetNormalizedValue(state->lY, m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_Z][ll].SetValue(Utils::GetNormalizedValue(state->lZ, m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_RX][ll].SetValue(Utils::GetNormalizedValue(state->lRx, m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_RY][ll].SetValue(Utils::GetNormalizedValue(state->lRy, m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_RZ][ll].SetValue(Utils::GetNormalizedValue(state->lRz, m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_S0][ll].SetValue(Utils::GetNormalizedValue(state->rglSlider[0], m_axesRangeMin, m_axesRangeMax));
            m_axis[LG_AXIS_S1][ll].SetValue(Utils::GetNormalizedValue(state->rglSlider[1], m_axesRangeMin, m_axesRangeMax));

            for (INT ii = 0; ii < LG_NBR_AXES_DINPUT; ii ++)
            {
                m_axis[ii][ll].SetControllerIndex(index);
                m_axis[ii][ll].SetControllerType(LG_CONTROLLER_TYPE_DINPUT);
            }
        }

        for (INT ii = 0; ii < MAX_NUMBER_BUTTONS_DINPUT; ii++)
        {
            if (state->rgbButtons[ii] & 0x80)
            {
                m_button[ii].SetValue(BUTTONS_RANGE_MAX);
            }
            else
            {
                m_button[ii].SetValue(BUTTONS_RANGE_MIN);
            }

            m_button[ii].SetControllerIndex(index);
            m_button[ii].SetControllerType(LG_CONTROLLER_TYPE_DINPUT);
        }

        for (INT ii = 0; ii < MAX_NUMBER_POVS_DINPUT; ii++)
        {
            for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
            {
                if (m_POVDirection[ii][jj].Pressed(state))
                {
                    m_POVDirection[ii][jj].SetValue(POVS_RANGE_MAX);
                }
                else
                {
                    m_POVDirection[ii][jj].SetValue(POVS_RANGE_MIN);
                }

                m_POVDirection[ii][jj].SetControllerIndex(index);
                m_POVDirection[ii][jj].SetControllerType(LG_CONTROLLER_TYPE_DINPUT);
            }
        }
    }
    else
    {
        for (INT ii = 0; ii < LG_NBR_AXES_DINPUT; ii ++)
        {
            for (INT ll = 0; ll < NUMBER_AXES_RANGE_TYPES; ll++)
            {
                m_axis[ii][ll].SetValue(0);
                m_axis[ii][ll].SetControllerIndex(LG_CONTROLLER_DISCONNECTED);  
                m_axis[ii][ll].SetControllerType(LG_CONTROLLER_TYPE_NONE);
            }
        }

        for (INT ii = 0; ii < MAX_NUMBER_BUTTONS_DINPUT; ii++)
        {
            m_button[ii].SetValue(BUTTONS_RANGE_MIN);
            m_button[ii].SetControllerIndex(LG_CONTROLLER_DISCONNECTED);
            m_button[ii].SetControllerType(LG_CONTROLLER_TYPE_NONE);
        }

        for (INT ii = 0; ii < MAX_NUMBER_POVS_DINPUT; ii++)
        {
            for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
            {
                m_POVDirection[ii][jj].SetValue(POVS_RANGE_MIN);
                m_POVDirection[ii][jj].SetControllerIndex(LG_CONTROLLER_DISCONNECTED);
                m_POVDirection[ii][jj].SetControllerType(LG_CONTROLLER_TYPE_NONE);
            }
        }
    }

    return S_OK;
}

Control* ControllerDInput::ControlMoved()
{
    for (INT ii = 0; ii < LG_NBR_AXES_DINPUT; ii++)
    {
        for (INT jj = 0; jj < NUMBER_AXES_RANGE_TYPES; jj++)
        {
            if (m_axis[ii][jj].Moved())
            {
                return &m_axis[ii][jj];
            }
        }
    }

    for (INT ii = 0; ii < MAX_NUMBER_BUTTONS_DINPUT; ii++)
    {
        if (m_button[ii].Moved())
        {
            return &m_button[ii];
        }
    }

    for (INT ii = 0; ii < MAX_NUMBER_POVS_DINPUT; ii++)
    {
        for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
        {
            if (m_POVDirection[ii][jj].Moved())
            {
                return &m_POVDirection[ii][jj];
            }
        }
    }

    return NULL;
}

Control* ControllerDInput::GetControl(CONST ControlAssignment& controlAssignment)
{
    if (controlAssignment.axis > LG_AXIS_NONE 
        && controlAssignment.axis < LG_NBR_AXES_DINPUT 
        && controlAssignment.axisRangeType > LG_RANGE_NONE
        && controlAssignment.axisRangeType < NUMBER_AXES_RANGE_TYPES)
    {
        m_axis[controlAssignment.axis][controlAssignment.axisRangeType].SetControllerIndex(controlAssignment.controllerIndex);
        m_axis[controlAssignment.axis][controlAssignment.axisRangeType].SetControllerType(controlAssignment.controllerType);
        return &m_axis[controlAssignment.axis][controlAssignment.axisRangeType];
    }

    if (controlAssignment.button >= 0 && controlAssignment.button < MAX_NUMBER_BUTTONS_DINPUT)
    {
        m_button[controlAssignment.button].SetControllerIndex(controlAssignment.controllerIndex);
        m_button[controlAssignment.button].SetControllerType(controlAssignment.controllerType);
        return &m_button[controlAssignment.button];
    }

    if (controlAssignment.povNbr > -1 
        && controlAssignment.povNbr < MAX_NUMBER_POVS_DINPUT
        && controlAssignment.povDirection > LG_POV_NONE
        && controlAssignment.povDirection < LG_NUMBER_POV_DIR)
    {
        m_POVDirection[controlAssignment.povNbr][controlAssignment.povDirection].SetControllerIndex(controlAssignment.controllerIndex);
        m_POVDirection[controlAssignment.povNbr][controlAssignment.povDirection].SetControllerType(controlAssignment.controllerType);
        return &m_POVDirection[controlAssignment.povNbr][controlAssignment.povDirection];
    }

    return NULL;
}
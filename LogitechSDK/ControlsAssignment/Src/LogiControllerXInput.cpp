/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiControllerXInput.h"
#include "LogiControlsAssignmentUtils.h"

using namespace LogitechControlsAssignmentSDK;

ControllerXInput::ControllerXInput()
{
    m_type = LG_CONTROLLER_TYPE_XINPUT;

    for (INT ll = 0; ll < NUMBER_AXES_RANGE_TYPES; ll++)
    {
        // Set axes names
        m_axis[LG_AXIS_LEFT_TRIGGER][ll].SetAxisName(NAME_XINPUT_AXIS_LEFT_TRIGGER);
        m_axis[LG_AXIS_RIGHT_TRIGGER][ll].SetAxisName(NAME_XINPUT_AXIS_RIGHT_TRIGGER);
        m_axis[LG_AXIS_THUMB_LX][ll].SetAxisName(NAME_XINPUT_AXIS_THUMB_LX);
        m_axis[LG_AXIS_THUMB_LY][ll].SetAxisName(NAME_XINPUT_AXIS_THUMB_LY);
        m_axis[LG_AXIS_THUMB_RX][ll].SetAxisName(NAME_XINPUT_AXIS_THUMB_RX);
        m_axis[LG_AXIS_THUMB_RY][ll].SetAxisName(NAME_XINPUT_AXIS_THUMB_RY);

        for (INT mm = 0; mm < LG_NBR_AXES_XINPUT; mm++)
        {
            m_axis[mm][ll].SetAxisID(mm);
            m_axis[mm][ll].SetRangeType(static_cast<AxisRangeType>(ll));
        }
    }

    // Set buttons names
    for (INT ii = 0; ii < LG_NBR_BUTTONS_XINPUT; ii++)
    {
        m_button[ii].SetNumber(ii);
    }

    // Set POVs names
    for (INT ii = 0; ii < MAX_NUMBER_POVS_XINPUT; ii++)
    {
        for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
        {
            m_POVDirection[ii][jj].SetPovNumber(ii);
            m_POVDirection[ii][jj].SetDirection(static_cast<PovDirectionEnum>(jj));
        }
    }
}

ControllerXInput::~ControllerXInput()
{
}

HRESULT ControllerXInput::Update(CONST INT index, CONST XINPUT_STATE* state)
{
    SetIndex(index);

    if (index != LG_CONTROLLER_DISCONNECTED)
    {
        for (INT ll = 0; ll < NUMBER_AXES_RANGE_TYPES; ll++)
        {
            // Set normalized values.
            m_axis[LG_AXIS_LEFT_TRIGGER][ll].SetValue(Utils::GetNormalizedValue(state->Gamepad.bLeftTrigger, AXIS_TRIGGERS_RANGE_MIN_XINPUT, AXIS_TRIGGERS_RANGE_MAX_XINPUT));
            m_axis[LG_AXIS_RIGHT_TRIGGER][ll].SetValue(Utils::GetNormalizedValue(state->Gamepad.bRightTrigger, AXIS_TRIGGERS_RANGE_MIN_XINPUT, AXIS_TRIGGERS_RANGE_MAX_XINPUT));
            m_axis[LG_AXIS_THUMB_LX][ll].SetValue(Utils::GetNormalizedValue(state->Gamepad.sThumbLX, AXIS_OTHER_RANGE_MIN_XINPUT, AXIS_OTHER_RANGE_MAX_XINPUT));
            m_axis[LG_AXIS_THUMB_LY][ll].SetValue(Utils::GetNormalizedValue(state->Gamepad.sThumbLY, AXIS_OTHER_RANGE_MIN_XINPUT, AXIS_OTHER_RANGE_MAX_XINPUT));
            m_axis[LG_AXIS_THUMB_RX][ll].SetValue(Utils::GetNormalizedValue(state->Gamepad.sThumbRX, AXIS_OTHER_RANGE_MIN_XINPUT, AXIS_OTHER_RANGE_MAX_XINPUT));
            m_axis[LG_AXIS_THUMB_RY][ll].SetValue(Utils::GetNormalizedValue(state->Gamepad.sThumbRY, AXIS_OTHER_RANGE_MIN_XINPUT, AXIS_OTHER_RANGE_MAX_XINPUT));

            for (INT ii = 0; ii < LG_NBR_AXES_XINPUT; ii ++)
            {
                m_axis[ii][ll].SetControllerIndex(index);
                m_axis[ii][ll].SetControllerType(LG_CONTROLLER_TYPE_XINPUT);
            }
        }

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_START)
            m_button[LG_BUTTON_START].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_START].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_BACK)
            m_button[LG_BUTTON_BACK].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_BACK].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_LEFT_THUMB)
            m_button[LG_BUTTON_LEFT_THUMB].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_LEFT_THUMB].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_RIGHT_THUMB)
            m_button[LG_BUTTON_RIGHT_THUMB].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_RIGHT_THUMB].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_LEFT_SHOULDER)
            m_button[LG_BUTTON_LEFT_SHOULDER].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_LEFT_SHOULDER].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_RIGHT_SHOULDER)
            m_button[LG_BUTTON_RIGHT_SHOULDER].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_RIGHT_SHOULDER].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_A)
            m_button[LG_BUTTON_A].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_A].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_B)
            m_button[LG_BUTTON_B].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_B].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_X)
            m_button[LG_BUTTON_X].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_X].SetValue(BUTTONS_RANGE_MIN);

        if (state->Gamepad.wButtons & XINPUT_GAMEPAD_Y)
            m_button[LG_BUTTON_Y].SetValue(BUTTONS_RANGE_MAX);
        else
            m_button[LG_BUTTON_Y].SetValue(BUTTONS_RANGE_MIN);

        for (INT ii = 0; ii < LG_NBR_BUTTONS_XINPUT; ii++)
        {
            m_button[ii].SetControllerIndex(index);
            m_button[ii].SetControllerType(LG_CONTROLLER_TYPE_XINPUT);
        }

        for (INT ii = 0; ii < MAX_NUMBER_POVS_XINPUT; ii++)
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
                m_POVDirection[ii][jj].SetControllerType(LG_CONTROLLER_TYPE_XINPUT);
            }
        }
    }
    else
    {
        for (INT ii = 0; ii < LG_NBR_AXES_XINPUT; ii ++)
        {
            for (INT ll = 0; ll < NUMBER_AXES_RANGE_TYPES; ll++)
            {
                m_axis[ii][ll].SetValue(0);
                m_axis[ii][ll].SetControllerIndex(LG_CONTROLLER_DISCONNECTED);  
                m_axis[ii][ll].SetControllerType(LG_CONTROLLER_TYPE_NONE);
            }
        }

        for (INT ii = 0; ii < LG_NBR_BUTTONS_XINPUT; ii++)
        {
            m_button[ii].SetValue(BUTTONS_RANGE_MIN);
            m_button[ii].SetControllerIndex(LG_CONTROLLER_DISCONNECTED);
            m_button[ii].SetControllerType(LG_CONTROLLER_TYPE_NONE);
        }

        for (INT ii = 0; ii < MAX_NUMBER_POVS_XINPUT; ii++)
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

VOID ControllerXInput::SetInitialValues()
{
    for (INT ii = 0; ii < LG_NBR_AXES_XINPUT; ii++)
    {
        for (INT jj = 0; jj < NUMBER_AXES_RANGE_TYPES; jj++)
        {
            m_axis[ii][jj].SetInitialValue();
        }
    }

    for (INT ii = 0; ii < LG_NBR_BUTTONS_XINPUT; ii++)
    {
        m_button[ii].SetInitialValue();
    }

    for (INT ii = 0; ii < MAX_NUMBER_POVS_XINPUT; ii++)
    {
        for (INT jj = 0; jj < LG_NUMBER_POV_DIR; jj++)
        {
            m_POVDirection[ii][jj].SetInitialValue();
        }
    }    
}

Control* ControllerXInput::ControlMoved()
{
    for (INT ii = 0; ii < LG_NBR_AXES_XINPUT; ii++)
    {
        for (INT jj = 0; jj < NUMBER_AXES_RANGE_TYPES; jj++)
        {
            if (m_axis[ii][jj].Moved())
            {
                return &m_axis[ii][jj];
            }
        }
    }

    for (INT ii = 0; ii < LG_NBR_BUTTONS_XINPUT; ii++)
    {
        if (m_button[ii].Moved())
        {
            return &m_button[ii];
        }
    }

    for (INT ii = 0; ii < MAX_NUMBER_POVS_XINPUT; ii++)
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

Control* ControllerXInput::GetControl(CONST ControlAssignment& controlAssignment)
{
    if (controlAssignment.axis > -1 
        && controlAssignment.axis < LG_NBR_AXES_XINPUT 
        && controlAssignment.axisRangeType > LG_RANGE_NONE
        && controlAssignment.axisRangeType < NUMBER_AXES_RANGE_TYPES)
    {
        m_axis[controlAssignment.axis][controlAssignment.axisRangeType].SetControllerIndex(controlAssignment.controllerIndex);
        m_axis[controlAssignment.axis][controlAssignment.axisRangeType].SetControllerType(controlAssignment.controllerType);
        return &m_axis[controlAssignment.axis][controlAssignment.axisRangeType];
    }

    if (controlAssignment.button >= 0 && controlAssignment.button < LG_NBR_BUTTONS_XINPUT)
    {
        m_button[controlAssignment.button].SetControllerIndex(controlAssignment.controllerIndex);
        m_button[controlAssignment.button].SetControllerType(controlAssignment.controllerType);
        return &m_button[controlAssignment.button];
    }

    if (controlAssignment.povNbr > -1 
        && controlAssignment.povNbr < MAX_NUMBER_POVS_XINPUT
        && controlAssignment.povDirection > LG_POV_NONE
        && controlAssignment.povDirection < LG_NUMBER_POV_DIR)
    {
        m_POVDirection[controlAssignment.povNbr][controlAssignment.povDirection].SetControllerIndex(controlAssignment.controllerIndex);
        m_POVDirection[controlAssignment.povNbr][controlAssignment.povDirection].SetControllerType(controlAssignment.controllerType);
        return &m_POVDirection[controlAssignment.povNbr][controlAssignment.povDirection];
    }
    return NULL;
}
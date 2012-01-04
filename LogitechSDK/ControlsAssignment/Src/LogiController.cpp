/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiController.h"

using namespace LogitechControlsAssignmentSDK;

Controller::Controller()
{
    m_index = -1;
    m_type = LG_CONTROLLER_TYPE_NONE;
}

Controller::~Controller()
{

}

ControlAssignment::ControlAssignment()
{
    Init();    
}

VOID Controller::SetIndex(INT index)
{
    m_index = index;
}

INT Controller::GetIndex()
{
    return m_index;
}

VOID ControlAssignment::Init()
{
    controllerIndex = LG_CONTROLLER_DISCONNECTED;
    controllerType = LG_CONTROLLER_TYPE_NONE;
    controlType = CONTROL_TYPE_NONE;
    axis = -1;
    axisRangeType = LG_RANGE_NONE;
    button = -1;
    povNbr = -1;
    povDirection = -1;
}
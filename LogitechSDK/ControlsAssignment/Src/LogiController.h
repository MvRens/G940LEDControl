/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_H_INCLUDED_

#include "LogiControl.h"

namespace LogitechControlsAssignmentSDK
{
    class ControlAssignment
    {
    public:
        ControlAssignment();

        INT controllerIndex;
        ControllerType controllerType;
        ControlType controlType;

        INT axis;
        INT axisRangeType;
        INT button;
        INT povNbr;
        INT povDirection;

        VOID Init();
    };

    class Controller
    {
    public:
        Controller();
        virtual ~Controller();

        VOID SetIndex(INT index);
        INT GetIndex();

        virtual VOID SetInitialValues() = 0;
        virtual Control* ControlMoved() = 0;

        virtual Control* GetControl(CONST ControlAssignment& controlAssignment) = 0;

    protected:
        INT m_index;
        ControllerType m_type;
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_CONTROLLER_H_INCLUDED_

/*
The Logitech Controls Assignment SDK, including all acompanying documentation, 
is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_CONTROL_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_CONTROL_H_INCLUDED_

#include "LogiControlsAssignmentGlobals.h"

namespace LogitechControlsAssignmentSDK
{
    typedef enum
    {
        CONTROL_TYPE_NONE = -1, CONTROL_TYPE_AXIS, CONTROL_TYPE_BUTTON, CONTROL_TYPE_POV
    } ControlType;

    class Control
    {
    public:
        Control();
        virtual ~Control();

        virtual VOID Initialize();

        LPCTSTR GetName();
        HRESULT SetName(LPCTSTR name);

        HRESULT SetType(CONST ControlType type);
        ControlType GetType();

        virtual AxisRangeType GetRangeType();

        VOID SetInitialValue();
        FLOAT GetInitialValue();

        VOID SetControllerIndex(CONST INT index);
        INT GetControllerIndex();

        VOID SetControllerType(CONST ControllerType type);
        INT GetControllerType();

        virtual FLOAT GetValue();
        virtual VOID SetValue(CONST FLOAT value);

        virtual BOOL Moved() = 0;

    protected:
        TCHAR m_controlName[MAX_PATH];
        FLOAT m_value;
        ControlType m_type;
        FLOAT m_initialValue;
        INT m_controllerIndex;
        ControllerType m_controllerType;
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_CONTROL_H_INCLUDED_

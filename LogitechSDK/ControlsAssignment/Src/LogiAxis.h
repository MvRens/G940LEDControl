/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_AXIS_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_AXIS_H_INCLUDED_

#include "LogiControl.h"

namespace LogitechControlsAssignmentSDK
{
    class Axis: public Control
    {
    public:
        Axis();
        ~Axis();

        VOID Initialize();
        HRESULT SetAxisName(CONST LPCTSTR axisName);
        LPCTSTR GetAxisName();

        VOID SetRangeType(CONST AxisRangeType range);
        AxisRangeType GetRangeType();

        VOID SetAxisID(INT axisID);
        INT GetAxisID();

        FLOAT GetValue();
        BOOL Moved();
        FLOAT GetRangeIndepValue();

    private:
        AxisRangeType m_rangeType;
        TCHAR m_axisName[MAX_PATH];
        INT m_axisID;

        BOOL IsCentered();
        BOOL SideFromCenterDiffers();
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_AXIS_H_INCLUDED_

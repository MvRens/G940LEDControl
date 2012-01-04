/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLS_ASSIGNMENT_UTILS_H_INCLUDED_
#define LOGI_CONTROLS_ASSIGNMENT_UTILS_H_INCLUDED_

#ifndef _WIN32_DCOM 
#define _WIN32_DCOM 
#endif

#include <wbemidl.h>
#include <objbase.h>

#include "LogiControl.h"

namespace LogitechControlsAssignmentSDK
{
    class Utils
    {
    public:
        static FLOAT Combine(Control* control1, Control* control2, CONST BOOL reverseFlag);

        static FLOAT Abs(CONST FLOAT value);

        static FLOAT GetNormalizedValue(CONST LONG value, LONG min, LONG max);

        static BOOL IsXInputDevice(CONST GUID* pGuidProductFromDirectInput);

        static VOID LogiTrace(LPCTSTR lpszFormat, ...);
    };
}

#endif // LOGI_CONTROLS_ASSIGNMENT_UTILS_H_INCLUDED_

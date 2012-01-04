/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLLER_INPUT_UTILS_H_INCLUDED_
#define LOGI_CONTROLLER_INPUT_UTILS_H_INCLUDED_

#ifndef _WIN32_DCOM 
#define _WIN32_DCOM 
#endif

#include <wbemidl.h>
#include <objbase.h>

#include "LogiControllerInputGlobals.h"

namespace LogitechControllerInput
{
    class Utils
    {
    public:
        static Utils* Instance();

        BOOL IsXInputDevice(CONST GUID* pGuidProductFromDirectInput);
        VOID LogiTrace(LPCTSTR lpszFormat, ...);
        BOOL IsEven(INT nbr);
        STRING StringToUpper(STRING myString);
        HRESULT GetUniqueIDFromDbcc_name(TCHAR* outputString, CONST TCHAR* inputString);
        HRESULT GetDeviceIDStringFromSetupDI(STRING_VECTOR& deviceID, CONST DWORD vid, CONST DWORD pid);
        INT FindIG_Number(STRING deviceIDString);
        STRING GetUniqueID(STRING deviceIDString);
        VOID SetRecurringTimer(INT id, DWORD initialTickCounts, DWORD endTickCounts, DWORD intervals);
        BOOL TimerTriggered(INT id);
        HRESULT GetVidPid(CONST STRING deviceIDString, DWORD &vid, DWORD &pid);
        INT HexStringToInt(CONST TCHAR *value);

    protected:
        Utils();
        Utils(const Utils&);
        Utils& operator = (const Utils&);

    private:
        static Utils* m_instance;
        RECURRING_TIMER_DATA_VECTOR m_recurringTimerData;
    };
}

#endif // LOGI_CONTROLLER_INPUT_UTILS_H_INCLUDED_

#ifndef LOGI_UTILS_H_INCLUDED_
#define LOGI_UTILS_H_INCLUDED_

#include "LogiWheelGlobals.h"

namespace LogitechSteeringWheel
{
    class Utils
    {
    public:
        static INT FromPercentage(CONST INT percentage, CONST INT minPercentage, CONST INT maxPercentage, CONST INT minOutput, CONST INT maxOutput);
        static VOID LogiTrace(CONST LPCTSTR lpszFormat, ...);
    };
}

#endif // LOGI_UTILS_H_INCLUDED_

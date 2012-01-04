#include "LogiWheelUtils.h"
#include "LogiWheelGlobals.h"

INT LogitechSteeringWheel::Utils::FromPercentage(CONST INT percentage, CONST INT minPercentage, CONST INT maxPercentage, CONST INT minOutput, CONST INT maxOutput)
{
    INT percentage_ = percentage;
    if (percentage_ < minPercentage)
    {
        LOGIWHEELTRACE(_T("WARNING: input percentage smaller than min percentage. Clamping value.\n"));
        percentage_ = minPercentage;
    }

    if (percentage_ > maxPercentage)
    {
        LOGIWHEELTRACE(_T("WARNING: input percentage bigger than max percentage. Clamping value.\n"));
        percentage_ = maxPercentage;
    }

    FLOAT var1_ = (FLOAT)maxOutput - (FLOAT)minOutput;
    FLOAT var2_ = (FLOAT)(percentage_ - minPercentage) / (FLOAT)(maxPercentage - minPercentage);
    INT output_ = (INT)(var1_ * var2_) + minOutput;

    return output_;
}

VOID LogitechSteeringWheel::Utils::LogiTrace(CONST LPCTSTR lpszFormat, ...)
{
    va_list args;
    va_start(args, lpszFormat);

    int nBuf;
    TCHAR szBuffer[512];

    nBuf = _vsntprintf_s(szBuffer, _countof(szBuffer), sizeof(szBuffer) / sizeof(TCHAR), lpszFormat, args);

    // was there an error? was the expanded string too long?
    _ASSERT(nBuf >= 0);

    OutputDebugString(szBuffer);

    va_end(args);
}

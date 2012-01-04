#ifndef LOGISPRINGFORCE_H_INCLUDED_
#define LOGISPRINGFORCE_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class SpringForceParams : public ForceParams
    {
    public:
        SpringForceParams();
        DICONDITION m_diCondition[2];
        LONG m_rglDirection[2];
    };

    class LogiSpringForce : public Force
    {
    public:
        LogiSpringForce();

        HRESULT CreateEffect(SpringForceParams& params);
        HRESULT SetParameters(SpringForceParams& params);
        SpringForceParams& GetCurrentForceParams();

    private:
        SpringForceParams m_currentForceParams;
    };
}

#endif // LOGISPRINGFORCE_H_INCLUDED_

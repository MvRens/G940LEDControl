#ifndef LOGIDAMPERFORCE_H_INCLUDED_
#define LOGIDAMPERFORCE_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class DamperForceParams : public ForceParams
    {
    public:
        DamperForceParams();
        DICONDITION m_diCondition[2];
        LONG m_rglDirection[2];
    };

    class LogiDamperForce : public Force
    {
    public:
        LogiDamperForce();

        HRESULT CreateEffect(DamperForceParams& params);
        HRESULT SetParameters(DamperForceParams& params);
        DamperForceParams& GetCurrentForceParams();

    private:
        DamperForceParams m_currentForceParams;
    };
}

#endif // LOGIDAMPERFORCE_H_INCLUDED_

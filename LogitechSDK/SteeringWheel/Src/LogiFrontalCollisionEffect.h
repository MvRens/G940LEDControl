#ifndef LOGIFRONTALCOLLISIONEFFECT_H_INCLUDED_
#define LOGIFRONTALCOLLISIONEFFECT_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class FrontalCollisionEffectParams : public ForceParams
    {
    public:
        FrontalCollisionEffectParams();
        DIPERIODIC m_diPeriodic;
        DIENVELOPE m_diEnvelope;
    };

    class LogiFrontalCollisionEffect : public Force
    {
    public:
        LogiFrontalCollisionEffect();

        HRESULT CreateEffect(FrontalCollisionEffectParams& params);
        HRESULT SetParameters(FrontalCollisionEffectParams& params);
        FrontalCollisionEffectParams& GetCurrentForceParams();

    private:
        FrontalCollisionEffectParams m_currentForceParams;
    };
}

#endif // LOGIFRONTALCOLLISIONEFFECT_H_INCLUDED_

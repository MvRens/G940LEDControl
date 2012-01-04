#ifndef LOGISIDECOLLISIONEFFECT_H_INCLUDED_
#define LOGISIDECOLLISIONEFFECT_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class SideCollisionEffectParams : public ForceParams
    {
    public:
        SideCollisionEffectParams();
        DICONSTANTFORCE m_diConstantForce;
        DIENVELOPE m_diEnvelope;
    };

    class LogiSideCollisionEffect : public Force
    {
    public:
        LogiSideCollisionEffect();

        HRESULT CreateEffect(SideCollisionEffectParams& params);
        HRESULT SetParameters(SideCollisionEffectParams& params);
        SideCollisionEffectParams& GetCurrentForceParams();

    private:
        SideCollisionEffectParams m_currentForceParams;
    };
}

#endif // LOGISIDECOLLISIONEFFECT_H_INCLUDED_

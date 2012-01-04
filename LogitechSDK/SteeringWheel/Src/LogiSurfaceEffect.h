#ifndef LOGISURFACEEFFECT_H_INCLUDED_
#define LOGISURFACEEFFECT_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class SurfaceEffectParams : public ForceParams
    {
    public:
        SurfaceEffectParams();
        DIPERIODIC m_diPeriodic;
        DIENVELOPE m_diEnvelope;
        CONST struct _GUID *m_type;
    };

    class LogiSurfaceEffect : public Force
    {
    public:
        LogiSurfaceEffect();

        HRESULT CreateEffect(SurfaceEffectParams& params);
        HRESULT SetParameters(SurfaceEffectParams& params);
        SurfaceEffectParams& GetCurrentForceParams();

    private:
        SurfaceEffectParams m_currentForceParams;
    };
}

#endif // LOGISURFACEEFFECT_H_INCLUDED_

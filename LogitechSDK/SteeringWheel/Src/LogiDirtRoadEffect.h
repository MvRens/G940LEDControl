#ifndef LOGIDIRTROADEFFECT_H_INCLUDED_
#define LOGIDIRTROADEFFECT_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class DirtRoadEffectParams : public ForceParams
    {
    public:
        DirtRoadEffectParams();
        DIPERIODIC m_diPeriodic;
        DIENVELOPE m_diEnvelope;
    };

    class LogiDirtRoadEffect : public Force
    {
    public:
        LogiDirtRoadEffect();

        HRESULT CreateEffect(DirtRoadEffectParams& params);
        HRESULT SetParameters(DirtRoadEffectParams& params);
        DirtRoadEffectParams& GetCurrentForceParams();

    private:
        DirtRoadEffectParams m_currentForceParams;
    };
}

#endif // LOGIDIRTROADEFFECT_H_INCLUDED_

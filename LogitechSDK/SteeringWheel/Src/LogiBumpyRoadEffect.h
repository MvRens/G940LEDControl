#ifndef LOGIBUMPYROADEFFECT_H_INCLUDED_
#define LOGIBUMPYROADEFFECT_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class BumpyRoadEffectParams : public ForceParams
    {
    public:
        BumpyRoadEffectParams();
        DIPERIODIC m_diPeriodic;
        DIENVELOPE m_diEnvelope;
    };

    class LogiBumpyRoadEffect : public Force
    {
    public:
        LogiBumpyRoadEffect();

        HRESULT CreateEffect(BumpyRoadEffectParams& params);
        HRESULT SetParameters(BumpyRoadEffectParams& params);
        BumpyRoadEffectParams& GetCurrentForceParams();

    private:
        BumpyRoadEffectParams m_currentForceParams;
    };
}

#endif // LOGIBUMPYROADEFFECT_H_INCLUDED_

#ifndef LOGISLIPPERYROADEFFECT_H_INCLUDED_
#define LOGISLIPPERYROADEFFECT_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class SlipperyRoadEffectParams : public ForceParams
    {
    public:
        SlipperyRoadEffectParams();
        DICONDITION m_diCondition[2];
        LONG m_rglDirection[2];
    };

    class LogiSlipperyRoadEffect : public Force
    {
    public:
        LogiSlipperyRoadEffect();

        HRESULT CreateEffect(SlipperyRoadEffectParams& params);
        HRESULT SetParameters(SlipperyRoadEffectParams& params);
        SlipperyRoadEffectParams& GetCurrentForceParams();

    private:
        SlipperyRoadEffectParams m_currentForceParams;
    };
}

#endif // LOGISLIPPERYROADEFFECT_H_INCLUDED_

#ifndef LOGICONSTANTFORCE_H_INCLUDED_
#define LOGICONSTANTFORCE_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class ConstantForceParams : public ForceParams
    {
    public:
        ConstantForceParams();
        DICONSTANTFORCE m_diConstantForce;
        DIENVELOPE m_diEnvelope;
    };

    class LogiConstantForce : public Force
    {
    public:
        LogiConstantForce();

        HRESULT CreateEffect(ConstantForceParams& params);
        HRESULT SetParameters(ConstantForceParams& params);
        ConstantForceParams& GetCurrentForceParams();

    private:
        ConstantForceParams m_currentForceParams;
    };
}

#endif // LOGICONSTANTFORCE_H_INCLUDED_

#ifndef LOGISOFTSTOPFORCE_H_INCLUDED_
#define LOGISOFTSTOPFORCE_H_INCLUDED_

#include "LogiForce.h"

namespace LogitechSteeringWheel
{
    class SoftstopForceParams : public ForceParams
    {
    public:
        SoftstopForceParams();
        DICONDITION m_diCondition[2];
    };

    class LogiSoftstopForce : public Force
    {
    public:
        LogiSoftstopForce();

        HRESULT CreateEffect(SoftstopForceParams& params);
        HRESULT SetParameters(SoftstopForceParams& params);
        SoftstopForceParams& GetCurrentForceParams();

    private:
        SoftstopForceParams m_currentForceParams;
    };
}

#endif // LOGISOFTSTOPFORCE_H_INCLUDED_

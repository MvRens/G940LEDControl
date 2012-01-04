#include "LogiSpringForce.h"
#include "LogiControllerForceManager.h"
#include "LogiWheelUtils.h"

using namespace LogitechSteeringWheel;

SpringForceParams::SpringForceParams()
{
    m_diCondition[0].lDeadBand = 0;
    m_diCondition[0].lOffset = 0;
    m_diCondition[0].lPositiveCoefficient = 0;
    m_diCondition[0].lNegativeCoefficient = 0;
    m_diCondition[0].dwPositiveSaturation = 0;
    m_diCondition[0].dwNegativeSaturation = 0;

    m_diCondition[1].lDeadBand = 0;
    m_diCondition[1].lOffset = 0;
    m_diCondition[1].lPositiveCoefficient = Utils::FromPercentage(80, -100, 100, -DI_FFNOMINALMAX, DI_FFNOMINALMAX);
    m_diCondition[1].lNegativeCoefficient = m_diCondition[1].lPositiveCoefficient;
    m_diCondition[1].dwPositiveSaturation = Utils::FromPercentage(80, 0, 100, 0, DI_FFNOMINALMAX);
    m_diCondition[1].dwNegativeSaturation = m_diCondition[1].dwPositiveSaturation;

    m_rglDirection[0] = 1;
    m_rglDirection[1] = 0;
}

LogiSpringForce::LogiSpringForce()
{
    m_type = LG_FORCE_SPRING;
}

HRESULT LogiSpringForce::CreateEffect(SpringForceParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.rglDirection            = params.m_rglDirection;
    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = NULL;
    m_diEffect.cbTypeSpecificParams    = m_diEffect.cAxes * sizeof(DICONDITION);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diCondition;

    if( FAILED( hr_ = m_device->CreateEffect( GUID_Spring,
        &m_diEffect, &m_effect, NULL ) ) )
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to create spring force\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

HRESULT LogiSpringForce::SetParameters(SpringForceParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.rglDirection            = params.m_rglDirection;
    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = NULL;
    m_diEffect.cbTypeSpecificParams    = m_diEffect.cAxes * sizeof(DICONDITION);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diCondition;

    if( FAILED( hr_ = m_effect->SetParameters(&m_diEffect, DIEP_DIRECTION |
        DIEP_TYPESPECIFICPARAMS )))
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to update spring force\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

SpringForceParams& LogiSpringForce::GetCurrentForceParams()
{
    return m_currentForceParams;
}

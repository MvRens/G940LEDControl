#include "LogiSurfaceEffect.h"
#include "LogiControllerForceManager.h"
#include "LogiWheelUtils.h"

using namespace LogitechSteeringWheel;

SurfaceEffectParams::SurfaceEffectParams()
{
    m_diPeriodic.dwMagnitude = 0;
    m_diPeriodic.dwPeriod = 0;
    m_diPeriodic.dwPhase = 0;
    m_diPeriodic.lOffset = 0;

    m_diEnvelope.dwSize = sizeof(DIENVELOPE);
    m_diEnvelope.dwAttackLevel = 0;
    m_diEnvelope.dwAttackTime = 0;
    m_diEnvelope.dwFadeLevel = 0;
    m_diEnvelope.dwFadeTime = 0;

    m_type = NULL;
}

LogiSurfaceEffect::LogiSurfaceEffect()
{
    m_type = LG_FORCE_SURFACE_EFFECT;
}

HRESULT LogiSurfaceEffect::CreateEffect(SurfaceEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DIPERIODIC);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diPeriodic;

    if( FAILED( hr_ = m_device->CreateEffect( *params.m_type,
        &m_diEffect, &m_effect, NULL ) ) )
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to create surface effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

HRESULT LogiSurfaceEffect::SetParameters(SurfaceEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DIPERIODIC);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diPeriodic;

    if( FAILED( hr_ = m_effect->SetParameters(&m_diEffect, DIEP_DIRECTION |
        DIEP_TYPESPECIFICPARAMS )))
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to update surface effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

SurfaceEffectParams& LogiSurfaceEffect::GetCurrentForceParams()
{
    return m_currentForceParams;
}

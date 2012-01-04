#include "LogiFrontalCollisionEffect.h"

#include "LogiControllerForceManager.h"

using namespace LogitechSteeringWheel;

FrontalCollisionEffectParams::FrontalCollisionEffectParams()
{
    m_diPeriodic.dwMagnitude = 0;
    m_diPeriodic.dwPeriod = static_cast<DWORD>(0.075 * DI_SECONDS);
    m_diPeriodic.dwPhase = 0;
    m_diPeriodic.lOffset = 0;

    m_diEnvelope.dwSize = sizeof(DIENVELOPE);
    m_diEnvelope.dwAttackLevel = 0;
    m_diEnvelope.dwAttackTime = 0;
    m_diEnvelope.dwFadeLevel = 0;
    m_diEnvelope.dwFadeTime = static_cast<ULONG>(0.02f * static_cast<FLOAT>(DI_SECONDS));
}

LogiFrontalCollisionEffect::LogiFrontalCollisionEffect()
{
    m_type = LG_FORCE_FRONTAL_COLLISION;
}

HRESULT LogiFrontalCollisionEffect::CreateEffect(FrontalCollisionEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.dwDuration              = static_cast<ULONG>(LG_COLLISION_EFFECT_DURATION * 1000);
    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DIPERIODIC);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diPeriodic;

    if( FAILED( hr_ = m_device->CreateEffect( GUID_Square,
        &m_diEffect, &m_effect, NULL ) ) )
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to create frontal collision effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

HRESULT LogiFrontalCollisionEffect::SetParameters(FrontalCollisionEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.dwDuration              = static_cast<ULONG>(LG_COLLISION_EFFECT_DURATION * 1000);
    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DIPERIODIC);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diPeriodic;

    if( FAILED( hr_ = m_effect->SetParameters(&m_diEffect, DIEP_DIRECTION |
        DIEP_TYPESPECIFICPARAMS )))
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to update frontal collision effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

FrontalCollisionEffectParams& LogiFrontalCollisionEffect::GetCurrentForceParams()
{
    return m_currentForceParams;
}

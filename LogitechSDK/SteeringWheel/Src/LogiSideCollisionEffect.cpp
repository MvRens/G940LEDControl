#include "LogiSideCollisionEffect.h"

#include "LogiControllerForceManager.h"

using namespace LogitechSteeringWheel;

SideCollisionEffectParams::SideCollisionEffectParams()
{
    m_diConstantForce.lMagnitude = 0;
    m_diEnvelope.dwSize = sizeof(DIENVELOPE);
    m_diEnvelope.dwAttackLevel = 0;
    m_diEnvelope.dwAttackTime = 0;
    m_diEnvelope.dwFadeLevel = 0;
    m_diEnvelope.dwFadeTime = 0;
}

LogiSideCollisionEffect::LogiSideCollisionEffect()
{
    m_type = LG_FORCE_SIDE_COLLISION;
}

HRESULT LogiSideCollisionEffect::CreateEffect(SideCollisionEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.dwDuration              = static_cast<ULONG>(LG_COLLISION_EFFECT_DURATION * 1000);
    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DICONSTANTFORCE);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diConstantForce;

    if( FAILED( hr_ = m_device->CreateEffect( GUID_ConstantForce,
        &m_diEffect, &m_effect, NULL ) ) )
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to create side collision effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

HRESULT LogiSideCollisionEffect::SetParameters(SideCollisionEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.dwDuration              = static_cast<ULONG>(LG_COLLISION_EFFECT_DURATION * 1000);
    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DICONSTANTFORCE);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diConstantForce;

    if( FAILED( hr_ = m_effect->SetParameters(&m_diEffect, DIEP_DIRECTION |
        DIEP_TYPESPECIFICPARAMS )))
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to update side collision effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

SideCollisionEffectParams& LogiSideCollisionEffect::GetCurrentForceParams()
{
    return m_currentForceParams;
}

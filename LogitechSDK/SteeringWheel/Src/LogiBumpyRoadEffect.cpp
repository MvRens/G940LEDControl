#include "LogiBumpyRoadEffect.h"

#include "LogiControllerForceManager.h"

using namespace LogitechSteeringWheel;

BumpyRoadEffectParams::BumpyRoadEffectParams()
{
    m_diPeriodic.dwMagnitude = 0;
    m_diPeriodic.dwPeriod = static_cast<DWORD>(0.100 * DI_SECONDS);
    m_diPeriodic.dwPhase = 0;
    m_diPeriodic.lOffset = 0;

    m_diEnvelope.dwSize = sizeof(DIENVELOPE);
    m_diEnvelope.dwAttackLevel = 0;
    m_diEnvelope.dwAttackTime = 0;
    m_diEnvelope.dwFadeLevel = 0;
    m_diEnvelope.dwFadeTime = 0;
}

LogiBumpyRoadEffect::LogiBumpyRoadEffect()
{
    m_type = LG_FORCE_BUMPY_ROAD;
}

HRESULT LogiBumpyRoadEffect::CreateEffect(BumpyRoadEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DIPERIODIC);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diPeriodic;

    if( FAILED( hr_ = m_device->CreateEffect( GUID_Square,
        &m_diEffect, &m_effect, NULL ) ) )
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to create bumpy road force effect\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

HRESULT LogiBumpyRoadEffect::SetParameters(BumpyRoadEffectParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DIPERIODIC);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diPeriodic;

    if( FAILED( hr_ = m_effect->SetParameters(&m_diEffect, DIEP_DIRECTION |
        DIEP_TYPESPECIFICPARAMS )))
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to update bumpy road force\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

BumpyRoadEffectParams& LogiBumpyRoadEffect::GetCurrentForceParams()
{
    return m_currentForceParams;
}

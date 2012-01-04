#include "LogiConstantForce.h"

#include "LogiControllerForceManager.h"

using namespace LogitechSteeringWheel;

ConstantForceParams::ConstantForceParams()
{
    m_diConstantForce.lMagnitude = 0;
    m_diEnvelope.dwSize = sizeof(DIENVELOPE);
    m_diEnvelope.dwAttackLevel = 0;
    m_diEnvelope.dwAttackTime = 0;
    m_diEnvelope.dwFadeLevel = 0;
    m_diEnvelope.dwFadeTime = 0;
}

LogiConstantForce::LogiConstantForce()
{
    m_type = LG_FORCE_CONSTANT;
}

HRESULT LogiConstantForce::CreateEffect(ConstantForceParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DICONSTANTFORCE);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diConstantForce;

    if( FAILED( hr_ = m_device->CreateEffect( GUID_ConstantForce,
        &m_diEffect, &m_effect, NULL ) ) )
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to create constant force\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

HRESULT LogiConstantForce::SetParameters(ConstantForceParams& params)
{
    HRESULT hr_ = S_OK;

    m_diEffect.cAxes                   = params.m_numFFAxes;
    m_diEffect.lpEnvelope              = &params.m_diEnvelope;
    m_diEffect.cbTypeSpecificParams    = sizeof(DICONSTANTFORCE);
    m_diEffect.lpvTypeSpecificParams   = &params.m_diConstantForce;

    if( FAILED( hr_ = m_effect->SetParameters(&m_diEffect, DIEP_DIRECTION |
        DIEP_TYPESPECIFICPARAMS )))
    {
        LOGIWHEELTRACE(_T("ERROR: Failed to update constant force\n"));
        return hr_;
    }

    m_currentForceParams = params;

    return hr_;
}

ConstantForceParams& LogiConstantForce::GetCurrentForceParams()
{
    return m_currentForceParams;
}

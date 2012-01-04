#include "LogiForce.h"
#include "LogiWheelUtils.h"

using namespace LogitechSteeringWheel;

ForceParams::ForceParams()
{
    m_numFFAxes = 0;
}

Force::Force()
{
    m_rgdwAxes[0] = DIJOFS_X;
    m_rgdwAxes[1] = DIJOFS_Y;
    m_rglDirection[0] = 1;
    m_rglDirection[1] = 0;

    ZeroMemory( &m_diEffect, sizeof(m_diEffect) );
    m_diEffect.dwSize                  = sizeof(DIEFFECT);
    m_diEffect.rgdwAxes                = m_rgdwAxes;
    m_diEffect.rglDirection            = m_rglDirection;
    m_diEffect.dwFlags                 = DIEFF_CARTESIAN | DIEFF_OBJECTOFFSETS;
    m_diEffect.dwDuration              = INFINITE;
    m_diEffect.dwSamplePeriod          = 0;
    m_diEffect.dwGain                  = DI_FFNOMINALMAX;
    m_diEffect.dwTriggerButton         = DIEB_NOTRIGGER;
    m_diEffect.dwTriggerRepeatInterval = 0;
    m_diEffect.cAxes                   = 0;
    m_diEffect.dwStartDelay            = 0;

    Init();
}

HRESULT Force::Init()
{
    m_effect = NULL;
    m_device = NULL;
    m_playing = FALSE;

    return S_OK;
}

HRESULT Force::Start()
{
    HRESULT hr_ = E_FAIL;

    if (m_device == NULL)
    {
        LOGIWHEELTRACE(_T("ERROR: Trying to start force effect but device handle is NULL\n"));
        return E_FAIL;
    }

    if (m_effect == NULL)
    {
        LOGIWHEELTRACE(_T("ERROR: Trying to start force effect but effect handle is NULL\n"));
        return E_FAIL;
    }

    // Make sure the device is acquired, if we are gaining focus.
    hr_ = m_device->Acquire();

    if (FAILED(hr_))
    {
        return hr_;
    }

    if (SUCCEEDED(hr_ = m_effect->Start( 1, 0 ))) // Start the effect
    {
        m_playing = TRUE;
    }
    else
    {
        LOGIWHEELTRACE(_T("ERROR: failed to start force effect\n"));
    }

    return hr_;
}

HRESULT Force::Stop()
{
    HRESULT hr_ = E_FAIL;

    if (m_effect == NULL)
    {
        LOGIWHEELTRACE(_T("ERROR: Trying to stop force effect but we have an invalid effect handle\n"));
        m_playing = FALSE;
        return E_FAIL;
    }

    if (!IsPlaying())
        return S_OK;

    // Make sure the device is acquired, if we are gaining focus.
    hr_ = m_device->Acquire();

    if (FAILED(hr_))
    {
#ifdef LG_DEBUG
        LOGIWHEELTRACE("Acquire failed\n");
#endif
        return hr_;
    }

    if (SUCCEEDED(hr_ = m_effect->Stop())) // Stop the effect
    {
        m_playing = FALSE;
    }
    else
    {
        LOGIWHEELTRACE(_T("WARNING: Failed to stop force effect\n"));
    }

    return hr_;
}

HRESULT Force::Unload()
{
    HRESULT hr_ = E_FAIL;

    if (m_effect == NULL)
    {
        LOGIWHEELTRACE(_T("ERROR: Trying to unload force effect but we have an invalid effect handle\n"));
        return E_FAIL;
    }

    // Make sure the device is acquired, if we are gaining focus.
    hr_ = m_device->Acquire();

    if (FAILED(hr_))
    {
        LOGIWHEELTRACE(_T("WARNING: tried to unload force bit device not acquired\n"));
        return hr_;
    }

    if (FAILED(hr_ = m_effect->Unload())) // Unload the effect
        LOGIWHEELTRACE(_T("WARNING: Failed to unload force effect\n"));
    
    m_playing = FALSE;
    m_effect = NULL;
    
    return hr_;
}

BOOL Force::IsPlaying()
{
    if (!m_effect)
        return FALSE;

    if (!m_device)
        return FALSE;

    return m_playing;
}

LPDIRECTINPUTEFFECT Force::GetEffectHandle()
{
    return m_effect;
}

HRESULT Force::SetDeviceHandle(CONST LPDIRECTINPUTDEVICE8& device)
{
    m_device = device;

    return S_OK;
}

HRESULT Force::ReleaseEffect()
{
    HRESULT hr_ = E_FAIL;

    if (m_effect)
    {
        hr_ = m_effect->Release();
    }

    return hr_;
}

ForceType Force::GetType()
{
    return m_type;
}

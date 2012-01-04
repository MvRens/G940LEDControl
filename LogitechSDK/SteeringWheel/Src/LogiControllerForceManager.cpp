#include "LogiControllerForceManager.h"

using namespace LogitechSteeringWheel;

ControllerForceManager::ControllerForceManager()
{
    m_forces.push_back(&m_constantForce);
    m_forces.push_back(&m_bumpyRoadEffect);
    m_forces.push_back(&m_dirtRoadEffect);
    m_forces.push_back(&m_surfaceEffect);
    m_forces.push_back(&m_springForce);
    m_forces.push_back(&m_damperForce);
    m_forces.push_back(&m_slipperyRoadEffect);
    m_forces.push_back(&m_sideCollisionEffect);
    m_forces.push_back(&m_frontalCollisionEffect);
    m_forces.push_back(&m_softstopForce);
    //m_forces.push_back(&m_logiForce);

    Init();
}

HRESULT ControllerForceManager::Init()
{
    m_deviceHandle = NULL;

    for (UINT ii = 0; ii < m_forces.size(); ii++)
    {
        m_forces[ii]->Init();
    }

    return S_OK;
}

HRESULT ControllerForceManager::SetDeviceHandle(CONST LPDIRECTINPUTDEVICE8 device)
{
    m_deviceHandle = device;

    for (UINT ii = 0; ii < m_forces.size(); ii++)
    {
        m_forces[ii]->SetDeviceHandle(device);
    }

    return S_OK;
}

BOOL ControllerForceManager::IsPlaying(CONST ForceType forceType)
{
    Force* force_ = GetForce(forceType);

    return force_->IsPlaying();
}

Force* ControllerForceManager::GetForce(CONST ForceType forceType)
{
    for (UINT ii = 0; ii < m_forces.size(); ii++)
    {
        if (m_forces[ii]->GetType() == forceType)
        {
            return m_forces[ii];
        }
    }

    return &m_logiForce;
}


HRESULT ControllerForceManager::ReleaseEffects()
{
    for (UINT ii = 0; ii < m_forces.size(); ii++)
    {
        m_forces[ii]->ReleaseEffect();
    }

    m_softstopForce.ReleaseEffect();

    return S_OK;
}

VOID ControllerForceManager::RestartPausedForces()
{
    for (UINT ii = 0; ii < m_forces.size(); ii++)
    {
        if (m_forces[ii]->IsPlaying())
        {
            m_forces[ii]->Stop();
            m_forces[ii]->Start();
        }
    }
}

#ifndef LOGI_GAME_CONTROLLER_H_INCLUDED_
#define LOGI_GAME_CONTROLLER_H_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>

#include <vector>

#include "LogiWheelGlobals.h"
#include "LogiConstantForce.h"
#include "LogiBumpyRoadEffect.h"
#include "LogiDirtRoadEffect.h"
#include "LogiSurfaceEffect.h"
#include "LogiSpringForce.h"
#include "LogiDamperForce.h"
#include "LogiSlipperyRoadEffect.h"
#include "LogiSideCollisionEffect.h"
#include "LogiFrontalCollisionEffect.h"
#include "LogiSoftstopForce.h"
#include "LogiWheelUtils.h"

namespace LogitechSteeringWheel
{
    class ControllerForceManager
    {
    public:
        ControllerForceManager();

        HRESULT Init();
        HRESULT SetDeviceHandle(CONST LPDIRECTINPUTDEVICE8 device);
        BOOL IsPlaying(CONST ForceType forceType);
        Force* GetForce(CONST ForceType forceType);
        HRESULT ReleaseEffects();
        VOID RestartPausedForces();

    private:
        LPDIRECTINPUTDEVICE8 m_deviceHandle;

        LogiConstantForce m_constantForce;
        LogiBumpyRoadEffect m_bumpyRoadEffect;
        LogiDirtRoadEffect m_dirtRoadEffect;
        LogiSurfaceEffect m_surfaceEffect;
        LogiSpringForce m_springForce;
        LogiDamperForce m_damperForce;
        LogiSlipperyRoadEffect m_slipperyRoadEffect;
        LogiSideCollisionEffect m_sideCollisionEffect;
        LogiFrontalCollisionEffect m_frontalCollisionEffect;
        LogiSoftstopForce m_softstopForce;
        Force m_logiForce; // used for GetForce in case no other force found

        std::vector<Force*> m_forces;
    };
}

#endif // LOGI_GAME_CONTROLLER_H_INCLUDED_

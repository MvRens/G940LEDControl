#ifndef LOGIFORCE_H_INCLUDED_
#define LOGIFORCE_H_INCLUDED_

#include "LogiWheelGlobals.h"

#include <dinput.h>

namespace LogitechSteeringWheel
{
    class ForceParams
    {
    public:
        ForceParams();

        INT m_numFFAxes;
    };

    class Force
    {
    public:
        Force();

        HRESULT Init();

        HRESULT Start();
        HRESULT Stop();
        HRESULT Unload();
        BOOL IsPlaying();

        virtual HRESULT CreateEffect(ForceParams& params) { UNREFERENCED_PARAMETER(params); return E_FAIL; }
        HRESULT ReleaseEffect();
        virtual HRESULT SetParameters(ForceParams& params) { UNREFERENCED_PARAMETER(params); return E_FAIL; }

        LPDIRECTINPUTEFFECT GetEffectHandle();

        HRESULT SetDeviceHandle(CONST LPDIRECTINPUTDEVICE8& device);

        ForceType GetType();
    protected:
        LPDIRECTINPUTDEVICE8 m_device;
        DWORD m_rgdwAxes[2];
        LONG m_rglDirection[2];
        LPDIRECTINPUTEFFECT m_effect;
        DIEFFECT m_diEffect;
        BOOL m_playing;
        ForceType m_type;
    };
}

#endif // LOGIFORCE_H_INCLUDED_

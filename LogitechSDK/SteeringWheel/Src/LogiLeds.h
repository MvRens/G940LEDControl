#ifndef LOGI_LEDS_H_INCLUDED_
#define LOGI_LEDS_H_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>

namespace LogitechSteeringWheel
{
    CONST DWORD ESCAPE_COMMAND_LEDS = 0;

    CONST DWORD LEDS_VERSION_NUMBER = 0x00000001;

    struct LedsRpmData
    {
        FLOAT currentRPM;
        FLOAT rpmFirstLedTurnsOn;
        FLOAT rpmRedLine;
    };

    struct WheelData
    {
        DWORD size;
        DWORD versionNbr;
        LedsRpmData rpmData;
    };

    class Leds
    {
    public:
        HRESULT Play(CONST LPDIRECTINPUTDEVICE8 device, CONST FLOAT currentRPM, CONST FLOAT rpmFirstLedTurnsOn, CONST FLOAT rpmRedLine);

    private:
    };
}

#endif // LOGI_LEDS_H_INCLUDED_
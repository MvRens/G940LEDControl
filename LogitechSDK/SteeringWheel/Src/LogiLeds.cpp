#include "LogiLeds.h"
#include "crtdbg.h"

using namespace LogitechSteeringWheel;

HRESULT Leds::Play(CONST LPDIRECTINPUTDEVICE8 device, CONST FLOAT currentRPM, CONST FLOAT rpmFirstLedTurnsOn, CONST FLOAT rpmRedLine)
{
    if (NULL == device)
    {
        return E_POINTER;
    }

    WheelData wheelData_;
    ZeroMemory(&wheelData_, sizeof(wheelData_));

    wheelData_.size = sizeof(WheelData);
    wheelData_.versionNbr = LEDS_VERSION_NUMBER;
    wheelData_.rpmData.currentRPM = currentRPM;
    wheelData_.rpmData.rpmFirstLedTurnsOn = rpmFirstLedTurnsOn;
    wheelData_.rpmData.rpmRedLine = rpmRedLine;

    DIEFFESCAPE data_;
    ZeroMemory(&data_, sizeof(data_));

    data_.dwSize = sizeof(DIEFFESCAPE);
    data_.dwCommand = ESCAPE_COMMAND_LEDS;
    data_.lpvInBuffer = &wheelData_;
    data_.cbInBuffer = sizeof(wheelData_);

    return device->Escape(&data_);
}


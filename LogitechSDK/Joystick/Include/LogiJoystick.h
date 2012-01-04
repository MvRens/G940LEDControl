/*
The Logitech Joystick SDK for PC, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>

    typedef enum
    {
        LOGI_UNDEFINED = -1, LOGI_P1, LOGI_P2, LOGI_P3, LOGI_P4, LOGI_P5, LOGI_P6, LOGI_P7, LOGI_P8
    } LogiPanelButton;

    typedef enum
    {
        LOGI_OFF, LOGI_GREEN, LOGI_AMBER, LOGI_RED
    } LogiColor;

    DWORD SetButtonColor(LPDIRECTINPUTDEVICE8 device, LogiPanelButton button, LogiColor color);
    DWORD SetAllButtonsColor(LPDIRECTINPUTDEVICE8 device, LogiColor color);
    BOOL IsButtonColor(LPDIRECTINPUTDEVICE8 device, LogiPanelButton button, LogiColor color);

    DWORD SetLEDs(LPDIRECTINPUTDEVICE8 device, BYTE redLEDs, BYTE greenLEDs);
    DWORD GetLEDs(LPDIRECTINPUTDEVICE8 device, BYTE& redLEDs, BYTE& greenLEDs);

#ifdef __cplusplus
}
#endif
#include <LogiJoystick.h>
#include <dinput.h>

extern "C"
{
  __declspec(dllexport) DWORD LJ_SetButtonColor(LPDIRECTINPUTDEVICE8 device, LogiPanelButton button, LogiColor color)
  {
    return SetButtonColor(device, button, color);
  }

  __declspec(dllexport) DWORD LJ_SetAllButtonsColor(LPDIRECTINPUTDEVICE8 device, LogiColor color)
  {
    return SetAllButtonsColor(device, color);
  }

  __declspec(dllexport) BOOL LJ_IsButtonColor(LPDIRECTINPUTDEVICE8 device, LogiPanelButton button, LogiColor color)
  {
    return IsButtonColor(device, button, color);
  }

  __declspec(dllexport) DWORD LJ_SetLEDs(LPDIRECTINPUTDEVICE8 device, BYTE redLEDs, BYTE greenLEDs)
  {
    return SetLEDs(device, redLEDs, greenLEDs);
  }

  __declspec(dllexport) DWORD LJ_GetLEDs(LPDIRECTINPUTDEVICE8 device, BYTE& redLEDs, BYTE& greenLEDs)
  {
    return GetLEDs(device, redLEDs, greenLEDs);
  }
}
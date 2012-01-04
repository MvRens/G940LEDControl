// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the LOGIJOYSTICKDLL_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// LOGIJOYSTICKDLL_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef LOGIJOYSTICKDLL_EXPORTS
#define LOGIJOYSTICKDLL_API 
#else
#define LOGIJOYSTICKDLL_API __declspec(dllimport)
#endif


LOGIJOYSTICKDLL_API DWORD LJ_SetButtonColor(LPDIRECTINPUTDEVICE8 device, LogiPanelButton button, LogiColor color);
LOGIJOYSTICKDLL_API DWORD LJ_SetAllButtonsColor(LPDIRECTINPUTDEVICE8 device, LogiColor color);
LOGIJOYSTICKDLL_API BOOL LJ_IsButtonColor(LPDIRECTINPUTDEVICE8 device, LogiPanelButton button, LogiColor color);

LOGIJOYSTICKDLL_API DWORD LJ_SetLEDs(LPDIRECTINPUTDEVICE8 device, BYTE redLEDs, BYTE greenLEDs);
LOGIJOYSTICKDLL_API DWORD LJ_GetLEDs(LPDIRECTINPUTDEVICE8 device, BYTE& redLEDs, BYTE& greenLEDs);
/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_H_INCLUDED_
#define LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_H_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>
#include <XInput.h>

#include "LogiControllerInputGlobals.h"

namespace LogitechControllerInput
{
    class LogiGameController
    {
    public:
        LogiGameController();

        VOID Init();

        LPDIRECTINPUTDEVICE8 GetDeviceHandle();
        VOID SetDeviceHandle(CONST LPDIRECTINPUTDEVICE8 device);

        VOID SetVidPid(CONST DWORD vidPid);
        VOID SetVid(CONST DWORD vid);
        VOID SetPid(CONST DWORD pid);
        DWORD32 GetVid();
        DWORD32 GetPid();

        VOID SetFriendlyProductName(LPCTSTR name);
        LPCTSTR GetFriendlyProductName();

        VOID SetDeviceType(CONST DeviceType deviceType);

        virtual HRESULT Read() = 0;

        virtual DIJOYSTATE2* GetStateDInput() { return NULL; }
        virtual XINPUT_STATE* GetStateXInput() { return NULL; }

        BOOL IsConnected(CONST DeviceType deviceType);
        BOOL IsConnected(CONST ManufacturerName manufacturerName);
        BOOL IsConnected(CONST ModelName modelName);

        virtual BOOL ButtonIsPressed(CONST INT buttonOrMask) { UNREFERENCED_PARAMETER(buttonOrMask); return FALSE; }
        virtual BOOL ButtonTriggered(CONST INT buttonOrMask) { UNREFERENCED_PARAMETER(buttonOrMask); return FALSE; }
        virtual BOOL ButtonReleased(CONST INT buttonOrMask) { UNREFERENCED_PARAMETER(buttonOrMask); return FALSE; }

        virtual BOOL HasForceFeedback() = 0;

        virtual VOID SetNumberFFAxes(CONST INT number) { UNREFERENCED_PARAMETER(number); }
        virtual INT GetNumberFFAxes() { return 0; }

        VOID GenerateNonLinearValues(CONST INT nonLinCoeff);
        INT GetNonLinearValue(CONST INT inputValue);

        BOOL IsXInputDevice();

        // XInput ID (0 to 3)
        virtual HRESULT SetDeviceXInputID(CONST INT idNbr) { UNREFERENCED_PARAMETER(idNbr); return E_FAIL; }
        virtual INT GetDeviceXInputID() {return LG_XINPUT_ID_NONE; }

        // unique device ID
        HRESULT SetDeviceUniqueID(LPCTSTR uniqueID);
        TCHAR* GetDeviceUniqueID();

    protected:
        LPDIRECTINPUTDEVICE8 m_device;
        DWORD m_numFFAxes;
        DeviceType m_deviceType;
        BOOL m_actuatorsAreOn;
        DWORD m_vid;
        DWORD m_pid;
        TCHAR m_friendlyProductName[MAX_PATH];
        INT m_nonLinearWheel[LG_LOOKUP_TABLE_SIZE];
        INT m_nonLinearCoefficient;
        BOOL m_isXInputDevice;
        INT m_deviceXID; // XInput ID
        INT m_ctrlNbr; // controller Number
        HWND m_gameHWnd;
        DWORD m_timeCreated;
        TCHAR m_deviceUniqueID[MAX_PATH];

        FLOAT CalculateNonLinValue(CONST INT inputValue, CONST INT nonLinearCoeff, CONST LONG physicsMinInput, CONST LONG physicsMaxInput);
    };
}

#endif // LOGI_CONTROLLER_INPUT_GAME_CONTROLLER_H_INCLUDED_

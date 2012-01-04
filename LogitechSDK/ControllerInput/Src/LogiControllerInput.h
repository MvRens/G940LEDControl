/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLLER_INPUT_INCLUDED_
#define LOGI_CONTROLLER_INPUT_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800

#include <dinput.h>
#include <XInput.h>

#pragma comment(lib,"dxguid.lib")
#pragma comment(lib,"dinput8.lib")
#pragma comment(lib,"xinput.lib")

#include "LogiControllerInputGlobals.h"
#include "LogiGameController.h"

namespace LogitechControllerInput
{
    class ControllerInput
    {
    public:
        ControllerInput(CONST HWND hwnd, CONST BOOL ignoreXInputControllers = FALSE);
        ~ControllerInput();

        VOID Update();

        DIJOYSTATE2* GetStateDInput(CONST INT index);
        XINPUT_STATE* GetStateXInput(CONST INT index);
        LPCTSTR GetFriendlyProductName(CONST INT index);
        BOOL IsConnected(CONST INT index);
        BOOL IsConnected(CONST INT index, CONST DeviceType deviceType);
        BOOL IsConnected(CONST INT index, CONST ManufacturerName manufacturerName);
        BOOL IsConnected(CONST INT index, CONST ModelName modelName);
        BOOL IsXInputDevice(CONST INT index);
        BOOL HasForceFeedback(CONST INT index);
        DWORD GetVendorID(CONST INT index);
        DWORD GetProductID(CONST INT index);
        LPDIRECTINPUTDEVICE8 GetDeviceHandle(CONST INT index);
        INT GetDeviceXInputID(CONST INT index);
        HRESULT GenerateNonLinearValues(CONST INT index, CONST INT nonLinCoeff);
        INT GetNonLinearValue(CONST INT index, CONST INT inputValue);
        BOOL ButtonIsPressed(CONST INT index, CONST INT buttonOrMask);
        BOOL ButtonTriggered(CONST INT index, CONST INT buttonOrMask);
        BOOL ButtonReleased(CONST INT index, CONST INT buttonOrMask);
        INT GetNumberFFAxesDInput(CONST INT index);
        HWND GetGameHWnd();

    private:
        class DeviceHandleAndIndex
        {
        public:
            DeviceHandleAndIndex() { Init(); }

            LPDIRECTINPUTDEVICE8 device;
            INT index;

        private:
            VOID Init()
            {
                device = NULL;
                index = -1;
            }
        };

        HWND m_gameHWnd;
        HDEVNOTIFY m_hDevNotify;
        BOOL m_intervalTimerHit;

        INT GetCurrentNumberControllersConnected();

        BOOL ControllerExists(CONST INT index);

        HRESULT CreateDIInterface();
        HRESULT AddNewControllers(CONST BOOL calledOnStartup);
        HRESULT EnumerateDevices();
        //HRESULT GetNewDevicesHandleAndIndex(std::vector<DeviceHandleAndIndex>& deviceHandleIndex, CONST BOOL calledOnStartup);
        HRESULT PopulateDeviceDescriptions(DEVICE_INFO_VECTOR& devicesInfo);
        HRESULT ReOrderDeviceDescriptions(DEVICE_INFO_VECTOR& devicesInfo);
        BOOL IsAlreadyPresent(DeviceInfo deviceInfo);
        HRESULT CreateNewControllers(CONST DEVICE_INFO_VECTOR& devicesInfo, CONST BOOL calledOnStartup);
        HRESULT RemoveController(CONST INT index);

        static BOOL FAR PASCAL EnumDevicesCallback(CONST DIDEVICEINSTANCE* pDevInst, VOID* pContext);
        static BOOL FAR PASCAL EnumAxesCallback( CONST DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext );

        HRESULT EnumDeviceObjects(CONST INT index);

        BOOL EnumObjectsCB(CONST DIDEVICEOBJECTINSTANCE* pdidoi, LPVOID pvRef);
        static BOOL FAR PASCAL EnumObjectsCallback(CONST DIDEVICEOBJECTINSTANCE* pdidoi, LPVOID pvRef);

        VOID FreeDirectInput();
    };
}

#endif //LOGI_CONTROLLER_INPUT_INCLUDED_

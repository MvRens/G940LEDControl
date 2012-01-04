/****f* Controller.Input.SDK/ControllerInputSDK[1.00.001]
* NAME
*   Logitech Controller Input SDK
* COPYRIGHT
*   The Logitech Controller Input SDK, including all accompanying
*   documentation, is protected by intellectual property laws. All
*   rights not expressly granted by Logitech are reserved.
* PURPOSE
*   The Logitech Controller Input SDK's purpose is to create a
*   paradigm shift. Today users must have their controller(s) plugged
*   in when launching a PC game, and if they forget, they have to know
*   to exit the game, plug in the controller, and start again.
*   The Controller Input SDK enables users to hot plug/unplug
*   any controllers at any time, mimicking the user-friendly behavior
*   of consoles.
*   The SDK provides a simple interface for:
*       - support of both DirectInput and XInput hot plug/unplug.
*       - seamless integration of a total of 4 DInput and XInput
*         controllers.
*       - getting controller positional information as well as general
*         info such as friendly name, VID, PID, connection status
*         based on various parameters such as controller type,
*         manufacturer, and model name, and whether it supports force
*         feedback/rumble.
*       - getting hooks to add force feedback or rumble (DirectInput
*         device interface and XInput ID).
* EXAMPLE
*   Build and run the sample program to see some of the code usage, or
*   run ControllerInputSDKDemo.exe to quickly see what it can do.
* AUTHOR
*   Christophe Juncker (cj@wingmanteam.com)
******
*/

#include "LogiControllerInput.h"
#include "LogiGameControllerDI.h"
#include "LogiGameControllerXInput.h"
#include "LogiControllerInputUtils.h"
#include <dbt.h>

using namespace LogitechControllerInput;

LPDIRECTINPUT8 g_DIInterface = NULL;
LPDIRECTINPUTDEVICE8 g_deviceHandlesLocal[LogitechControllerInput::LG_MAX_CONTROLLERS];
DWORD g_numForceFeedbackAxisLocal[LogitechControllerInput::LG_MAX_CONTROLLERS];
BOOL g_joystickConnectedLocal[LogitechControllerInput::LG_MAX_CONTROLLERS];
BOOL g_wheelConnectedLocal[LogitechControllerInput::LG_MAX_CONTROLLERS];
BOOL g_gamepadConnectedLocal[LogitechControllerInput::LG_MAX_CONTROLLERS];
STRING g_deviceIDStringLocal[LogitechControllerInput::LG_MAX_CONTROLLERS];

BOOL g_controllerNeedsToBeRemoved[LogitechControllerInput::LG_MAX_CONTROLLERS];

BOOL g_ignoreXInputControllers = FALSE;

STRING_VECTOR g_uniqueIDsRemoved;

DWORD g_appGotActivated = FALSE;
DWORD g_deviceWasChanged = FALSE;
BOOL g_gameControllerWasPluggedIn = FALSE;

LogiGameController* g_controller[LG_MAX_CONTROLLERS];

typedef enum
{
    TIMER_EXTRA_ADD_CONTROLLERS
} LG_TIMER;

WNDPROC g_OldWnd;
LRESULT CALLBACK NewWindowProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);

// stolen from the DDK
#include <InitGuid.h>
DEFINE_GUID( GUID_DEVINTERFACE_HID, 0x4D1E55B2L, 0xF16F, 0x11CF, 0x88, 0xCB, 0x00, \
            0x11, 0x11, 0x00, 0x00, 0x30);

/****f* Controller.Input.SDK/ControllerInput(HWND.hwnd,BOOL.ignoreXInputControllers)
* NAME
*  ControllerInput(HWND hwnd, BOOL ignoreXInputControllers) -- does
*  necessary initialization.
* INPUTS
*  hwnd - game window handle used to initialize DirectInput.
*
* ignoreXInputControllers - if set to TRUE, XInput controllers will be
* ignored alltogether.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
ControllerInput::ControllerInput(CONST HWND hwnd, CONST BOOL ignoreXInputControllers)
{
    _ASSERT(NULL != hwnd);

    m_gameHWnd = hwnd;
    m_hDevNotify = NULL;
    m_intervalTimerHit = FALSE;
    g_DIInterface = NULL;
    g_ignoreXInputControllers = ignoreXInputControllers;

    CreateDIInterface();

    //Replace the Window Procedure and Store the Old Window Procedure
    g_OldWnd = (WNDPROC)(LONG_PTR)GetWindowLongPtr(hwnd, GWLP_WNDPROC);
    SetWindowLongPtr(hwnd, GWLP_WNDPROC, (__int3264)(LONG_PTR)NewWindowProc);

    DEV_BROADCAST_DEVICEINTERFACE bcInterface_;
    ZeroMemory(&bcInterface_, sizeof(bcInterface_));
    bcInterface_.dbcc_size = sizeof(bcInterface_);
    bcInterface_.dbcc_devicetype  = DBT_DEVTYP_DEVICEINTERFACE;
    bcInterface_.dbcc_classguid  = GUID_DEVINTERFACE_HID;

    m_hDevNotify = RegisterDeviceNotification(hwnd, (LPVOID)&bcInterface_, DEVICE_NOTIFY_WINDOW_HANDLE);
    if (m_hDevNotify == NULL)
    {
        LOGICONTROLLERTRACE(_T("ERROR: RegisterDeviceNotification returned error %d\n"), GetLastError());
    }

    for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        g_controller[ii] = NULL;
        g_controllerNeedsToBeRemoved[ii] = FALSE;
    }

    AddNewControllers(TRUE);
}

ControllerInput::~ControllerInput()
{
    FreeDirectInput();
    UnregisterDeviceNotification(m_hDevNotify);
}

HRESULT ControllerInput::CreateDIInterface()
{
    HRESULT hr_;
    // Register with the DirectInput subsystem and get a pointer
    // to a IDirectInput interface we can use.
    // Create a DInput object
    hr_ = DirectInput8Create( GetModuleHandle(NULL), DIRECTINPUT_VERSION,
        IID_IDirectInput8, (VOID**)&g_DIInterface, NULL );
    if( FAILED( hr_ ))
    {
        LOGICONTROLLERTRACE(_T("ERROR: failed to create a DInput object\n"));
        FreeDirectInput();
        return hr_;
    }
    return S_OK;
}

HRESULT ControllerInput::AddNewControllers(CONST BOOL calledOnStartup)
{
    HRESULT hr_ = E_FAIL;
    if (FAILED(hr_ = EnumerateDevices()))
        return hr_;

    DEVICE_INFO_VECTOR devicesInfo_;
    if (FAILED(hr_ = PopulateDeviceDescriptions(devicesInfo_)))
        return hr_;

    if (FAILED(hr_ = ReOrderDeviceDescriptions(devicesInfo_)))
        return hr_;

    if (FAILED(hr_ = CreateNewControllers(devicesInfo_, calledOnStartup)))
        return hr_;

    return S_OK;
}

HRESULT ControllerInput::EnumerateDevices()
{
    HRESULT hr_;

    for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        g_deviceHandlesLocal[ii] = NULL;
        g_numForceFeedbackAxisLocal[ii] = 0;
        g_joystickConnectedLocal[ii] = FALSE;
        g_wheelConnectedLocal[ii] = FALSE;
        g_gamepadConnectedLocal[ii] = FALSE;
        g_deviceIDStringLocal[ii] = _T("");
    }

    if (NULL == g_DIInterface)
        return E_FAIL;

    hr_ = g_DIInterface->EnumDevices( DI8DEVCLASS_GAMECTRL,
        EnumDevicesCallback,
        NULL, DIEDFL_ATTACHEDONLY );
    if( FAILED( hr_ ) )
    {
        LOGICONTROLLERTRACE(_T("ERROR: could not enumerate devices\n"));
        return hr_;
    }

    for (INT ctrlNbr_ = 0; ctrlNbr_ < LogitechControllerInput::LG_MAX_CONTROLLERS; ctrlNbr_++)
    {
        if (NULL != g_deviceHandlesLocal[ctrlNbr_])
        {
            if (FAILED(hr_ = g_deviceHandlesLocal[ctrlNbr_]->EnumObjects( EnumAxesCallback,
                (VOID*)&g_numForceFeedbackAxisLocal[ctrlNbr_], DIDFT_AXIS )))
            {
                LOGICONTROLLERTRACE(_T("ERROR: failed to enumerate force feedback axes for device on channel %d\n"), ctrlNbr_);
                return hr_;
            }

            EnumDeviceObjects(ctrlNbr_);
        }
    }

    return S_OK;
}

HRESULT ControllerInput::PopulateDeviceDescriptions(DEVICE_INFO_VECTOR& devicesInfo)
{
    devicesInfo.clear();

    for (UINT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        if (NULL == g_deviceHandlesLocal[ii])
            continue;

        DeviceInfo deviceInfo_;
        deviceInfo_.device = g_deviceHandlesLocal[ii];
        deviceInfo_.index = ii;
        deviceInfo_.numFFAxis = g_numForceFeedbackAxisLocal[ii];

        DIDEVICEINSTANCE instance_;
        ZeroMemory(&instance_, sizeof(DIDEVICEINSTANCE));
        instance_.dwSize = sizeof(DIDEVICEINSTANCE);
        g_deviceHandlesLocal[ii]->GetDeviceInfo(&instance_);

        DWORD vidPid_ = instance_.guidProduct.Data1;
        deviceInfo_.vid = LOWORD(vidPid_);
        deviceInfo_.pid = HIWORD(vidPid_);

        // Vista breaks DInput capability of telling whether a device
        // is a gamepad, joystick or wheel. So let's just set it
        // manually for our devices.
        if (VID_LOGITECH == deviceInfo_.vid &&
            (PID_RUMBLEPAD == deviceInfo_.pid
            || PID_RUMBLEPAD_2 == deviceInfo_.pid
            || PID_CORDLESS_RUMBLEPAD_2 == deviceInfo_.pid
            || PID_CORDLESS_GAMEPAD == deviceInfo_.pid
            || PID_DUAL_ACTION_GAMEPAD == deviceInfo_.pid
            || PID_PRECISION_GAMEPAD_2 == deviceInfo_.pid
            || PID_CHILLSTREAM == deviceInfo_.pid))
        {
            deviceInfo_.deviceType = LG_DEVICE_TYPE_GAMEPAD;
        }
        else if (VID_LOGITECH == deviceInfo_.vid &&
            (PID_FORCE_3D_PRO == deviceInfo_.pid
            || PID_EXTREME_3D_PRO == deviceInfo_.pid
            || PID_FREEDOM_24 == deviceInfo_.pid
            || PID_ATTACK_3 == deviceInfo_.pid
            || PID_FORCE_3D == deviceInfo_.pid
            || PID_STRIKE_FORCE_3D == deviceInfo_.pid
            || PID_G940_JOYSTICK == deviceInfo_.pid))
        {
            deviceInfo_.deviceType = LG_DEVICE_TYPE_JOYSTICK;
        }
        else if (VID_LOGITECH == deviceInfo_.vid &&
            (PID_G940_THROTTLE == deviceInfo_.pid
            || PID_G940_PEDALS == deviceInfo_.pid))
        {
            deviceInfo_.deviceType = LG_DEVICE_TYPE_OTHER;
        }
        else if (VID_LOGITECH == deviceInfo_.vid &&
            (PID_G27 == deviceInfo_.pid
            || PID_DRIVING_FORCE_GT == deviceInfo_.pid
            || PID_G25 == deviceInfo_.pid
            || PID_MOMO_RACING == deviceInfo_.pid
            || PID_MOMO_FORCE == deviceInfo_.pid
            || PID_DRIVING_FORCE_PRO == deviceInfo_.pid
            || PID_DRIVING_FORCE == deviceInfo_.pid
            || PID_NASCAR_RACING_WHEEL == deviceInfo_.pid
            || PID_DRIVING_FORCE == deviceInfo_.pid
            || PID_FORMULA_FORCE == deviceInfo_.pid
            || PID_FORMULA_FORCE_GP == deviceInfo_.pid))
        {
            deviceInfo_.deviceType = LG_DEVICE_TYPE_WHEEL;
        }
        else
        {
            if (g_gamepadConnectedLocal[ii])
            {
                deviceInfo_.deviceType = LG_DEVICE_TYPE_GAMEPAD;
            }
            else if(g_joystickConnectedLocal[ii])
            {
                deviceInfo_.deviceType = LG_DEVICE_TYPE_JOYSTICK;
            }
            else if(g_wheelConnectedLocal[ii])
            {
                deviceInfo_.deviceType = LG_DEVICE_TYPE_WHEEL;
            }
            else
            {
                deviceInfo_.deviceType = LG_DEVICE_TYPE_OTHER;
            }
        }

        deviceInfo_.friendlyName = instance_.tszProductName;

        deviceInfo_.deviceIDString = g_deviceIDStringLocal[ii];

        deviceInfo_.IG_nbr = Utils::Instance()->FindIG_Number(deviceInfo_.deviceIDString);

        if (-1 != deviceInfo_.IG_nbr)
        {
            deviceInfo_.isXinput = TRUE;
        }

        deviceInfo_.uniqueID = Utils::Instance()->GetUniqueID(deviceInfo_.deviceIDString);

        devicesInfo.push_back(deviceInfo_);
    }

    return S_OK;
}

// When game starts and multiple XInput devices are plugged in, the
// enumeration order is likely not equal to the XInput ID. To get
// around this problem, we change the order of the enumeration as follows:
// - Microsoft XInput devices come first, in order of their IG_ number
// - other XInput devices come next, in order of their IG_ number
// - DInput devices come next, in order of their enumeration.
// - If there are multiple XInput devices with same Vid/Pid and successive
//   ID, they don't need to be re-ordered.
HRESULT ControllerInput::ReOrderDeviceDescriptions(DEVICE_INFO_VECTOR& devicesInfo)
{
    if (0 == devicesInfo.size())
        return S_OK;

    // foreach device

    // Check to see if there are any Microsoft XInput devices. If so, order them by IG_number
    // Check to see if there are other XInput devices. If so, order them by IG_ number.
    // Check for DInput devices. keep them in enumeration order.

    DEVICE_INFO_MAP xinputMicrosoftDevices_;
    DEVICE_INFO_MAP xinputNonMicrosoftDevices_;
    DEVICE_INFO_MAP dinputDevices_;
    for (UINT index_ = 0; index_ < devicesInfo.size(); index_++)
    {
        if (devicesInfo[index_].isXinput)
        {
            if (devicesInfo[index_].vid == VID_MICROSOFT)
            {
                xinputMicrosoftDevices_[devicesInfo[index_].IG_nbr] = devicesInfo[index_];
            }
            else
            {
                xinputNonMicrosoftDevices_[devicesInfo[index_].IG_nbr] = devicesInfo[index_];
            }
        }
        else
        {
            dinputDevices_[index_] = devicesInfo[index_];
        }
    }

    // rebuild devicesInfo
    devicesInfo.clear();

    for(DEVICE_INFO_MAP::const_iterator it_ = xinputMicrosoftDevices_.begin(); it_ != xinputMicrosoftDevices_.end(); ++it_)
    {
        devicesInfo.push_back(it_->second);
    }

    for(DEVICE_INFO_MAP::const_iterator it_ = xinputNonMicrosoftDevices_.begin(); it_ != xinputNonMicrosoftDevices_.end(); ++it_)
    {
        devicesInfo.push_back(it_->second);
    }

    for(DEVICE_INFO_MAP::const_iterator it_ = dinputDevices_.begin(); it_ != dinputDevices_.end(); ++it_)
    {
        devicesInfo.push_back(it_->second);
    }

    return S_OK;
}

HRESULT ControllerInput::CreateNewControllers(CONST DEVICE_INFO_VECTOR& devicesInfo, CONST BOOL calledOnStartup)
{
    HRESULT hr_;
    INT counterXInputViaGetState_ = 0;

    for (UINT ll = 0; ll < devicesInfo.size(); ll++)
    {
        // if device already exists, ignore.
        if (IsAlreadyPresent(devicesInfo[ll]))
            continue;

        if (NULL == devicesInfo[ll].device)
            return E_FAIL;

        for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
        {
            if (NULL == g_controller[ii])
            {
                if (devicesInfo[ll].isXinput)
                {
                    g_controller[ii] = new LogiGameControllerXInput(ii, m_gameHWnd);

                    if (NULL == g_controller[ii])
                        return E_FAIL;

                    if (calledOnStartup)
                    {
                        INT localCounter_ = 0;
                        // For first device, let's set ID for first device we find via XInputGetState. For the second device, the second found ID, and so on.
                        for (INT xinputCount_ = 0; xinputCount_ < LG_NBR_XINPUT_CONTROLLERS; xinputCount_++)
                        {
                            XINPUT_STATE tempState;
                            DWORD dwResult_ = XInputGetState( xinputCount_, &tempState );
                            if (ERROR_DEVICE_NOT_CONNECTED != dwResult_)
                            {
                                ++localCounter_;
                                if (localCounter_ - 1 == counterXInputViaGetState_)
                                {
                                    g_controller[ii]->SetDeviceXInputID(xinputCount_);
                                    ++counterXInputViaGetState_;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {

                        INT_VECTOR existingXInputDevicesID_;
                        // Find IDs of all exisitng XInput devices
                        for (INT jj = 0; jj < LogitechControllerInput::LG_MAX_CONTROLLERS; jj++)
                        {
                            if (ii != jj)
                            {
                                if (NULL != g_controller[jj])
                                {
                                    if (g_controller[jj]->IsXInputDevice())
                                    {
                                        existingXInputDevicesID_.push_back(g_controller[jj]->GetDeviceXInputID());
                                    }
                                }
                            }
                        }

                        // Since we know that the lowest available ID is the one to get assigned, search for it
                        for (INT kk = 0; kk < LG_NBR_XINPUT_CONTROLLERS; kk++)
                        {
                            BOOL foundSameID_ = FALSE;
                            for (UINT jj = 0; jj < existingXInputDevicesID_.size(); jj++)
                            {
                                if (kk == existingXInputDevicesID_[jj])
                                {
                                    foundSameID_ = TRUE;
                                }
                            }

                            if (!foundSameID_)
                            {
                                g_controller[ii]->SetDeviceXInputID(kk);
                                break;
                            }
                        }
                    }
                }
                else
                {
                    g_controller[ii] = new LogiGameControllerDI(ii, m_gameHWnd);

                    if (NULL == g_controller[ii])
                        return E_FAIL;

                    g_controller[ii]->SetNumberFFAxes(devicesInfo[ll].numFFAxis);

                    hr_ = devicesInfo[ll].device->SetDataFormat( &c_dfDIJoystick2 );
                    if( FAILED( hr_ ) )
                    {
                        LOGICONTROLLERTRACE(_T("ERROR: couldn't set data format for gaming device on channel %d\n"), ii);
                        return hr_;
                    }

                    // Set the cooperative level to let DInput know how this device should
                    // interact with the system and with other DInput applications.
                    hr_ = devicesInfo[ll].device->SetCooperativeLevel( m_gameHWnd, DISCL_EXCLUSIVE |
                        DISCL_FOREGROUND );
                    if( FAILED( hr_ ) )
                    {
                        LOGICONTROLLERTRACE(_T("ERROR: couldn't set cooperative level for gaming device on channel %d\n"), ii);
                        return hr_;
                    }
                }
                g_controller[ii]->SetDeviceHandle(devicesInfo[ll].device);

                g_controller[ii]->SetVid(devicesInfo[ll].vid);
                g_controller[ii]->SetPid(devicesInfo[ll].pid);
                g_controller[ii]->SetFriendlyProductName(devicesInfo[ll].friendlyName.c_str());

                g_controller[ii]->SetDeviceType(devicesInfo[ll].deviceType);

                g_controller[ii]->SetDeviceUniqueID(devicesInfo[ll].uniqueID.c_str());
                break;
            }
        }
    }

    return S_OK;
}

BOOL ControllerInput::IsAlreadyPresent(DeviceInfo deviceInfo)
{
    // First check if unique ID already exists.
    for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        if (NULL != g_controller[ii])
        {
            if (0 == _tcscmp(g_controller[ii]->GetDeviceUniqueID(), deviceInfo.uniqueID.c_str()))
            {
                return TRUE;
            }
        }
    }

    return FALSE;
}

BOOL CALLBACK ControllerInput::EnumDevicesCallback(CONST DIDEVICEINSTANCE* pDevInst, VOID* pContext)
{
    UNREFERENCED_PARAMETER(pContext);
    if (NULL == pDevInst || NULL == g_DIInterface)
    {
        LOGICONTROLLERTRACE(_T("ERROR: EnumDevicesCallback: trying to use NULL pointer\n"));
        return DIENUM_CONTINUE;
    }

    DWORD vidPid_ = pDevInst->guidProduct.Data1;

    // Get unique ID
    STRING_VECTOR deviceIDString_;
    Utils::Instance()->GetDeviceIDStringFromSetupDI(deviceIDString_, LOWORD(vidPid_), HIWORD(vidPid_));

    if (g_ignoreXInputControllers)
    {
        if (-1 != Utils::Instance()->FindIG_Number(deviceIDString_[0]))
        {
            return DIENUM_CONTINUE;
        }
    }

    // count how many instances of the same device we already found
    INT deviceCounter_ = 0;
    for (INT index_ = 0; index_ < LogitechControllerInput::LG_MAX_CONTROLLERS; index_++)
    {
        DWORD vid_ = 0;
        DWORD pid_ = 0;
        if (SUCCEEDED(Utils::Instance()->GetVidPid(g_deviceIDStringLocal[index_], vid_, pid_)))
        {
            if (vid_ == LOWORD(vidPid_) && pid_ == HIWORD(vidPid_))
            {
                ++deviceCounter_;
            }
        }
    }

    for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        // Obtain an interface to the enumerated wheels.
        if (g_deviceHandlesLocal[ii] == NULL)
        {
            // If it failed, then we can't use this FF device. (Maybe the user unplugged
            // it while we were in the middle of enumerating it.)
            if( FAILED(g_DIInterface->CreateDevice( pDevInst->guidInstance, &g_deviceHandlesLocal[ii], NULL )))
            {
                LOGICONTROLLERTRACE(_T("ERROR: Failed to obtain an interface for the enumerated FF device %d.\n"), ii);
                return DIENUM_CONTINUE;
            } else
            {
                // check if we have a wheel or a joystick
                switch (GET_DIDEVICE_TYPE(pDevInst->dwDevType))
                {
                case DI8DEVTYPE_DRIVING:
                    g_wheelConnectedLocal[ii] = TRUE;
                    break;
                case DI8DEVTYPE_JOYSTICK:
                    g_joystickConnectedLocal[ii] = TRUE;
                    break;
                case DI8DEVTYPE_GAMEPAD:
                    g_gamepadConnectedLocal[ii] = TRUE;
                    break;
                }

                _ASSERT(deviceCounter_ < static_cast<INT>(deviceIDString_.size()));
                g_deviceIDStringLocal[ii] = deviceIDString_[deviceCounter_];
                STRING uniqueID_ = Utils::Instance()->GetUniqueID(deviceIDString_[deviceCounter_]);

                if (NULL == g_deviceHandlesLocal[ii])
                {
                    LOGICONTROLLERTRACE(_T("ERROR: EnumDevicesCallback: g_deviceHandlesLocal[%d] is NULL\n"), ii);
                    return DIENUM_CONTINUE;
                }

                // Disable centering spring, but only for devices that aren't already present
                BOOL deviceAlreadyPresent_ = FALSE;
                for (INT index_ = 0; index_ < LogitechControllerInput::LG_MAX_CONTROLLERS; index_++)
                {
                    if (NULL != g_controller[index_])
                    {
                        if (0 == _tcscmp(uniqueID_.c_str(), g_controller[index_]->GetDeviceUniqueID()))
                        {
                            deviceAlreadyPresent_ = TRUE;
                            break;
                        }
                    }
                }

                if (!deviceAlreadyPresent_)
                {
                    DIPROPDWORD DIPropAutoCenter_;
                    DIPropAutoCenter_.diph.dwSize       = sizeof(DIPROPDWORD);
                    DIPropAutoCenter_.diph.dwHeaderSize = sizeof(DIPROPHEADER);
                    DIPropAutoCenter_.diph.dwObj        = 0;
                    DIPropAutoCenter_.diph.dwHow        = DIPH_DEVICE;
                    DIPropAutoCenter_.dwData            = DIPROPAUTOCENTER_OFF;
                    if( FAILED( g_deviceHandlesLocal[ii]->SetProperty(DIPROP_AUTOCENTER,
                        &DIPropAutoCenter_.diph) ) )
                    {
                        return DIENUM_CONTINUE;
                    }
                }
            }
            break;
        }
    }

    return DIENUM_CONTINUE;
}

//-----------------------------------------------------------------------------
// Name: EnumAxesCallback()
// Desc: Callback function for enumerating the axes on a joystick and counting
//       each force feedback enabled axis
//-----------------------------------------------------------------------------
BOOL CALLBACK ControllerInput::EnumAxesCallback( CONST DIDEVICEOBJECTINSTANCE* pdidoi,
                                                      VOID* pContext )
{
    DWORD* pdwNumForceFeedbackAxis = (DWORD*) pContext;

    if( (pdidoi->dwFlags & DIDOI_FFACTUATOR) != 0 )
        (*pdwNumForceFeedbackAxis)++;

    return DIENUM_CONTINUE;
}

HRESULT ControllerInput::EnumDeviceObjects(INT index)
{
    HRESULT hr_ = NULL;
    // Enumerate the wheel objects. The callback function enabled user
    // interface elements for objects that are found, and sets the
    // min/max values property for discovere66d axes.
    if (g_deviceHandlesLocal[index] != NULL)
    {
        if( FAILED(hr_ = g_deviceHandlesLocal[index]->EnumObjects( EnumObjectsCallback,
            (VOID*)g_deviceHandlesLocal[index], DIDFT_ALL )))
        {
            LOGICONTROLLERTRACE(_T("ERROR: couldn't enumerate objects for gaming device on channel %d\n"), index);
            return hr_;
        }
    }
    return S_OK;
}

BOOL ControllerInput::EnumObjectsCB(CONST DIDEVICEOBJECTINSTANCE* pdidoi, LPVOID pvRef)
{
    HRESULT hr_;
    LPDIRECTINPUTDEVICE8 WheelHandle_ = (LPDIRECTINPUTDEVICE8) pvRef;

    if (NULL != WheelHandle_ && NULL != pdidoi)
    {
        // For axes that are returned, set the DIPROP_RANGE property for the
        // enumerated axis in order to scale min/max values.
        if( pdidoi->dwType & DIDFT_AXIS )
        {
            DIPROPRANGE diprg;
            diprg.diph.dwSize       = sizeof(DIPROPRANGE);
            diprg.diph.dwHeaderSize = sizeof(DIPROPHEADER);
            diprg.diph.dwHow        = DIPH_BYID;
            diprg.diph.dwObj        = pdidoi->dwType; // Specify the enumerated axis
            diprg.lMin              = LG_DINPUT_RANGE_MIN;
            diprg.lMax              = LG_DINPUT_RANGE_MAX;

            // Set the range for the axis
            if( FAILED(hr_ = WheelHandle_->SetProperty( DIPROP_RANGE, &diprg.diph )))
            {
                LOGICONTROLLERTRACE(_T("ERROR: SetProperty failed\n"));
                return DIENUM_STOP;
            }
        }
    }

    return DIENUM_CONTINUE;
}

BOOL FAR PASCAL ControllerInput::EnumObjectsCallback(CONST DIDEVICEOBJECTINSTANCE* pdidoi, LPVOID pvRef)
{
    ControllerInput *pThis_ = (ControllerInput *) pvRef;
    if(NULL != pThis_)
        return pThis_->EnumObjectsCB(pdidoi, pvRef);
    return DIENUM_STOP;
}

/****f* Controller.Input.SDK/Update()
* NAME
*  VOID Update() -- update controller status (connected or
*  disconnected) and read each controller's positional information.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
VOID ControllerInput::Update()
{
    DWORD currentTicks_ = GetTickCount();

    if (g_gameControllerWasPluggedIn)
    {
        g_gameControllerWasPluggedIn = FALSE;

        INT currentNumberControllersConnected_ = GetCurrentNumberControllersConnected();
        AddNewControllers(FALSE);

        // If number of controllers after AddNewControllers is the
        // same than before, it could be because device was plugged
        // into a USB for first time and didn't get enumerated on
        // first try. So in that case, let's try again regularly 
        // for a few seconds.
        if (currentNumberControllersConnected_ == GetCurrentNumberControllersConnected())
        {
            Utils::Instance()->SetRecurringTimer(TIMER_EXTRA_ADD_CONTROLLERS, currentTicks_, currentTicks_ + LG_MAX_TIME_RESET_OR_ADD_CONTROLLERS, LG_TIME_INTERVAL_RESET_OR_ADD_CONTROLLERS);
        }
    }

    if (Utils::Instance()->TimerTriggered(TIMER_EXTRA_ADD_CONTROLLERS))
    {
        AddNewControllers(FALSE);
    }

    // Remove controllers that need removing
    for (UINT index_ = 0; index_ < g_uniqueIDsRemoved.size(); index_++)
    {
        g_uniqueIDsRemoved[index_] = Utils::Instance()->StringToUpper(g_uniqueIDsRemoved[index_]);

        for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
        {
            if (NULL != g_controller[ii])
            {
                STRING localUniqueID_(g_controller[ii]->GetDeviceUniqueID());
                localUniqueID_ = Utils::Instance()->StringToUpper(localUniqueID_);
                if (0 == _tcscmp(g_uniqueIDsRemoved[index_].c_str(), localUniqueID_.c_str()))
                {
                    RemoveController(ii);
                }
            }
        }
    }

    // re-init our vector containing IDs to be removed
    g_uniqueIDsRemoved.clear();

    for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        if (NULL != g_controller[ii])
        {
            g_controller[ii]->Read();
        }
    }
}

BOOL ControllerInput::ControllerExists(CONST INT index)
{
    if (0 <= index && index < LogitechControllerInput::LG_MAX_CONTROLLERS)
    {
        if (NULL != g_controller[index])
            return TRUE;
    }

    return FALSE;
}

/****f* Controller.Input.SDK/GetStateDInput(INT.index)
* NAME
*  DIJOYSTATE2* GetStateDInput(INT index) -- get a DirectInput
*  controller's positional information.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  DIJOYSTATE2 pointer to the most recent information obtained through
*  Update() if successful.
*  NULL otherwise.
* SEE ALSO
*  Update()
*  SampleInGameImplementation.cpp to see an example.
******
*/
DIJOYSTATE2* ControllerInput::GetStateDInput(CONST INT index)
{

    if (ControllerExists(index))
    {
        return g_controller[index]->GetStateDInput();
    }

    return NULL;
}

/****f* Controller.Input.SDK/GetStateXInput(INT.index)
* NAME
*  XINPUT_STATE* GetStateXInput(INT index) -- get a XInput
*  controller's positional information.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  XINPUT_STATE pointer to the most recent information obtained
*  through Update() if successful.
*  NULL otherwise.
* SEE ALSO
*  Update()
*  SampleInGameImplementation.cpp to see an example.
******
*/
XINPUT_STATE* ControllerInput::GetStateXInput(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetStateXInput();
    }

    return NULL;
}

/****f* Controller.Input.SDK/GetFriendlyProductName(INT.index)
* NAME
*  LPCTSTR GetFriendlyProductName(INT index) -- get the friendly
*  name of a controller (as found in the USB Device Descriptor).
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  String containing friendly name if successful.
*  Empy string otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
LPCTSTR ControllerInput::GetFriendlyProductName(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetFriendlyProductName();
    }

    return _T("");
}

/****f* Controller.Input.SDK/IsConnected(INT.index)
* NAME
*  BOOL IsConnected(INT index) -- check if specified game controller
*  is currently connected.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  TRUE if connected.
*  FALSE otherwise.
* SEE ALSO
*  IsConnected(INT.index,DeviceType.deviceType)
*  IsConnected(INT.index,ManufacturerName.manufacturerName)
*  IsConnected(INT.index,ModelName.modelName)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::IsConnected(CONST INT index)
{
    if (ControllerExists(index))
    {
        return TRUE;
    }

    return FALSE;
}

/****f* Controller.Input.SDK/IsConnected(INT.index,DeviceType.deviceType)
* NAME
*  BOOL IsConnected(INT index, DeviceType deviceType) -- check if
*  specified game controller is currently connected.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  deviceType - type of the device. Possible types are:
*    - LG_DEVICE_TYPE_WHEEL
*    - LG_DEVICE_TYPE_JOYSTICK
*    - DEVICE_TYPE_GAMEPAD
*    - LG_DEVICE_TYPE_OTHER
* RETURN VALUE
*  TRUE if device is connected.
*  FALSE otherwise.
* SEE ALSO
*  IsConnected(INT.index)
*  IsConnected(INT.index,ManufacturerName.manufacturerName)
*  IsConnected(INT.index,ModelName.modelName)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::IsConnected(CONST INT index, CONST DeviceType deviceType)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->IsConnected(deviceType);
    }

    return FALSE;
}

/****f* Controller.Input.SDK/IsConnected(INT.index,ManufacturerName.manufacturerName)
* NAME
*  BOOL IsConnected(INT index, ManufacturerName manufacturerName) --
*  check if specified game controller is currently connected.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  manufacturerName - name of the manufacturer of the device. Possible
*  names are:
*    - LG_MANUFACTURER_LOGITECH
*    - LG_MANUFACTURER_MICROSOFT
*    - LG_MANUFACTURER_OTHER
* RETURN VALUE
*  TRUE if device is connected.
*  FALSE otherwise.
* SEE ALSO
*  IsConnected(INT.index)
*  IsConnected(INT.index,DeviceType.deviceType)
*  IsConnected(INT.index,ModelName.modelName)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::IsConnected(CONST INT index, CONST ManufacturerName manufacturerName)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->IsConnected(manufacturerName);
    }

    return FALSE;
}

/****f* Controller.Input.SDK/IsConnected(INT.index,ModelName.modelName)
* NAME
*  BOOL IsConnected(INT index, ModelName modelName) -- check if
*  specified game controller is currently connected.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  modelName - model name of the device. Possible names are:
*    - LG_MODEL_G27
*    - LG_MODEL_DRIVING_FORCE_GT
*    - LG_MODEL_G25
*    - LG_MODEL_MOMO_RACING
*    - LG_MODEL_MOMO_FORCE
*    - LG_MODEL_DRIVING_FORCE_PRO
*    - LG_MODEL_DRIVING_FORCE
*    - LG_MODEL_NASCAR_RACING_WHEEL
*    - LG_MODEL_FORMULA_FORCE
*    - LG_MODEL_FORMULA_FORCE_GP
*    - LG_MODEL_FORCE_3D_PRO
*    - LG_MODEL_EXTREME_3D_PRO
*    - LG_MODEL_FREEDOM_24
*    - LG_MODEL_ATTACK_3
*    - LG_MODEL_FORCE_3D
*    - LG_MODEL_STRIKE_FORCE_3D
*    - LG_MODEL_G940_JOYSTICK
*    - LG_MODEL_G940_THROTTLE
*    - LG_MODEL_G940_PEDALS
*    - LG_MODEL_RUMBLEPAD
*    - LG_MODEL_RUMBLEPAD_2
*    - LG_MODEL_CORDLESS_RUMBLEPAD_2
*    - LG_MODEL_CORDLESS_GAMEPAD
*    - LG_MODEL_DUAL_ACTION_GAMEPAD
*    - LG_MODEL_PRECISION_GAMEPAD_2
*    - LG_MODEL_CHILLSTREAM
* RETURN VALUE
*  TRUE if device is connected.
*  FALSE otherwise.
* SEE ALSO
*  IsConnected(INT.index)
*  IsConnected(INT.index,DeviceType.deviceType)
*  IsConnected(INT.index,ManufacturerName.manufacturerName)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::IsConnected(CONST INT index, CONST ModelName modelName)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->IsConnected(modelName);
    }

    return FALSE;
}

/****f* Controller.Input.SDK/IsXInputDevice(INT.index)
* NAME
*  BOOL IsXInputDevice(INT index) -- check if the controller is a
*  XInput device or a DirectInput device.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  TRUE if controller is a XInput device.
*  FALSE otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::IsXInputDevice(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->IsXInputDevice();
    }

    return FALSE;
}

/****f* Controller.Input.SDK/HasForceFeedback(INT.index)
* NAME
*  BOOL HasForceFeedback(INT index) -- check if the controller can
*  do force feedback or rumble.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  TRUE if controller is force feedback/rumble capable.
*  FALSE otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::HasForceFeedback(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->HasForceFeedback();
    }

    return FALSE;
}

/****f* Controller.Input.SDK/GetVendorID(INT.index)
* NAME
*  DWORD GetVendorID(INT index) -- Get controller's Vendor ID.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  Vendor ID if successful.
*  0 otherwise.
* SEE ALSO
*  GetProductID(INT.index)
*  SampleInGameImplementation.cpp to see an example.
******
*/
DWORD ControllerInput::GetVendorID(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetVid();
    }

    return 0;
}

/****f* Controller.Input.SDK/GetProductID(INT.index)
* NAME
*  DWORD GetProductID(INT index) -- Get controller's Product ID.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  Product ID if successful.
*  0 otherwise.
* SEE ALSO
*  GetVendorID(INT.index)
*  SampleInGameImplementation.cpp to see an example.
******
*/
DWORD ControllerInput::GetProductID(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetPid();
    }

    return 0;
}

/****f* Controller.Input.SDK/GetDeviceHandle(INT.index)
* NAME
*  LPDIRECTINPUTDEVICE8 GetDeviceHandle(INT index) -- Get handle to
*  controller's corresponding DirectInput device. This handle can be
*  used to do force feedback.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  Device handle if successful.
*  NULL otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
LPDIRECTINPUTDEVICE8 ControllerInput::GetDeviceHandle(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetDeviceHandle();
    }

    return NULL;
}

/****f* Controller.Input.SDK/GetDeviceXinputID(INT.index)
* NAME
*  INT GetDeviceXinputID(INT index) -- Get ID of XInput
*  controller. This ID can be used as the dwUserIndex parameter to use
*  any of the XInput functions.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  XInput ID if successful ( 0 to 3).
*  LG_XINPUT_ID_NONE otherwise.
* SEE ALSO
*  SampleInGameImplementation.cpp to see an example.
******
*/
INT ControllerInput::GetDeviceXInputID(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetDeviceXInputID();
    }

    return LG_XINPUT_ID_NONE;
}

/****f* Controller.Input.SDK/GenerateNonLinearValues(INT.index,INT.nonLinCoeff)
* NAME
*  HRESULT GenerateNonLinearValues(int index, int nonLinCoeff) --
*  Generate non-linear values for the game controller's axis.
* FUNCTION
*  Gaming wheels/joysticks/game pads have very different behavior from
*  real steering wheels. The reason for single-turn wheels is that
*  they only do up to three quarters of a turn lock to lock, compared
*  to about 3 turns for a real car.
*  This directly affects the steering ratio (15:1 to 20:1 for a real
*  car, but only 4:1 for a gaming wheel!). Joysticks and game pads
*  have a much shorter range of movement than a real steering wheel as
*  well.
*  Because of this very short steering ratio or short range, the
*  gaming wheel/joystick/game pad will feel highly sensitive which may
*  make game play very difficult.
*  Especially it may be difficult to drive in a straight line at speed
*  (tendency to swerve back and forth).
*  One way to get around this problem is to use a sensitivity
*  curve. This is a curve that defines the sensitivity of the game
*  controller depending on speed. This type of curve is usually used
*  for game pads to make up for their low physical range. The result
*  of applying such a curve is that at high speed the car's wheels
*  will physically turn less than if the car is moving very slowly.
*  For example the car's wheels may turn 60 degrees lock to lock at
*  low speed but only 10 degrees lock to lock at higher speeds.  If
*  you calculate the resulting steering ratio for 10 degrees lock to
*  lock you find that if you use a steering wheel that turns 180
*  degrees lock to lock the ratio is equal to 180/10 = 18, which
*  corresponds to a real car's steering ratio.
*  If the sensitivity curve has been implemented for the
*  wheel/joystick, adding a non-linear curve probably is not
*  necessary. But you may find that even after applying a sensitivity
*  curve, the car still feels a little twitchy on a straight line when
*  driving fast. This may be because in your game you need more than
*  10 degrees lock to lock even at high speeds. Or maybe the car is
*  moving at very high speeds where even a normal steering ratio is
*  not good enough to eliminate high sensitivity.
*  The best way at this point is to add a non-linear curve on top of
*  the sensitivity curve.
*  The effect of the non-linear curve with positive nonLinCoeff is
*  that around center position the wheel/joystick will be less
*  sensitive.  Yet at locked position left or right the car's wheels
*  will turn the same amount of degrees as without the non-linear
*  response curve.  Therefore the car will become more controllable on
*  a straight line and game-play will be improved.
*  There can sometimes be cases where the wheel does not feel
*  sensitive enough. In that case it is possible to add a non-linear
*  curve with the inverse effect (makes the steering more sensitive
*  around center position) by using negative values for
*  nonLinCoeff. This method lets you define a non-linearity
*  coefficient which will determine how strongly non-linear the curve
*  will be. When running the method it will generate a mapping table
*  in the form of an array. For each of the 1024 entries in this array
*  there will be a corresponding non-linear value which can be used as
*  the wheel/joystick's axis position instead of the original
*  value. See Sample_In-game_Implementation.cs for an example.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  nonLinCoeff - value representing how much non-linearity should be
*  applied. Range is -100 to 100. 0 = linear curve, 100 = maximum
*  non-linear curve with less sensitivity around center, -100 =
*  maximum non-linearity with more sensitivity around center position.
* SEE ALSO
*  GetNonLinearValue(INT.index,INT.inputValue)
*  SampleInGameImplementation.cpp to see an example.
******
*/
HRESULT ControllerInput::GenerateNonLinearValues(CONST INT index, CONST INT nonLinCoeff)
{
    if (ControllerExists(index))
    {
        g_controller[index]->GenerateNonLinearValues(nonLinCoeff);

        return S_OK;
    }

    return E_FAIL;
}

/****f* Controller.Input.SDK/GetNonLinearValue(INT.index,INT.inputValue)
* NAME
*  INT GetNonLinearValue(INT index, INT inputValue) -- Get a
*  non-linear value from a table previously generated. This can be
*  used for the response of a steering wheel.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  inputValue - value between LG_DINPUT_RANGE_MIN and
*  LG_DINPUT_RANGE_MAX corresponding to original value of an axis.
* RETURN VALUE
*  Value between LG_DINPUT_RANGE_MIN and LG_DINPUT_RANGE_MAX
*  corresponding to the level of non-linearity previously set with
*  GenerateNonLinearValues(...).
* SEE ALSO
*  GenerateNonLinearValues(INT.index,INT.nonLinCoeff)
*  SampleInGameImplementation.cpp to see an example.
******
*/
INT ControllerInput::GetNonLinearValue(CONST INT index, CONST INT inputValue)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetNonLinearValue(inputValue);
    }

    return 0;
}

/****f* Controller.Input.SDK/ButtonIsPressed(INT.index,INT.buttonOrMask)
* NAME
*  BOOL ButtonIsPressed(CONST INT index, CONST INT buttonOrMask) --
*  check if the button is currently pressed.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  buttonOrMask - button number between 0 and 127 for DInput, one of
*  the following bitmasks for XInput: XINPUT_GAMEPAD_DPAD_UP,
*  XINPUT_GAMEPAD_DPAD_DOWN, XINPUT_GAMEPAD_DPAD_LEFT,
*  XINPUT_GAMEPAD_DPAD_RIGHT, XINPUT_GAMEPAD_START,
*  XINPUT_GAMEPAD_BACK, XINPUT_GAMEPAD_LEFT_THUMB,
*  XINPUT_GAMEPAD_RIGHT_THUMB, XINPUT_GAMEPAD_LEFT_SHOULDER,
*  XINPUT_GAMEPAD_RIGHT_SHOULDER, XINPUT_GAMEPAD_A, XINPUT_GAMEPAD_B,
*  XINPUT_GAMEPAD_X, XINPUT_GAMEPAD_Y
* RETURN VALUE
*  TRUE if buttons is currently pressed.
*  FALSE otherwise.
* SEE ALSO
*  ButtonTriggered(INT.index,INT.buttonOrMask)
*  ButtonReleased(INT.index,INT.buttonOrMask)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::ButtonIsPressed(CONST INT index, CONST INT buttonOrMask)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->ButtonIsPressed(buttonOrMask);
    }

    return FALSE;
}

/****f* Controller.Input.SDK/ButtonTriggered(INT.index,INT.buttonOrMask)
* NAME
*  BOOL ButtonTriggered(CONST INT index, CONST INT buttonOrMask) --
*  check if the button has been triggered.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  buttonOrMask - button number between 0 and 127 for DInput, one of
*  the following bitmasks for XInput: XINPUT_GAMEPAD_DPAD_UP,
*  XINPUT_GAMEPAD_DPAD_DOWN, XINPUT_GAMEPAD_DPAD_LEFT,
*  XINPUT_GAMEPAD_DPAD_RIGHT, XINPUT_GAMEPAD_START,
*  XINPUT_GAMEPAD_BACK, XINPUT_GAMEPAD_LEFT_THUMB,
*  XINPUT_GAMEPAD_RIGHT_THUMB, XINPUT_GAMEPAD_LEFT_SHOULDER,
*  XINPUT_GAMEPAD_RIGHT_SHOULDER, XINPUT_GAMEPAD_A, XINPUT_GAMEPAD_B,
*  XINPUT_GAMEPAD_X, XINPUT_GAMEPAD_Y
* RETURN VALUE
*  TRUE if button was triggered.
*  FALSE otherwise.
* SEE ALSO
*  ButtonIsPressed(INT.index,INT.buttonOrMask)
*  ButtonReleased(INT.index,INT.buttonOrMask)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::ButtonTriggered(CONST INT index, CONST INT buttonOrMask)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->ButtonTriggered(buttonOrMask);
    }

    return FALSE;
}

/****f* Controller.Input.SDK/ButtonReleased(INT.index,INT.buttonOrMask)
* NAME
*  BOOL ButtonReleased(CONST INT index, CONST INT buttonOrMask) --
*  check if the button has been released.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
*
*  buttonOrMask - button number between 0 and 127 for DInput, one of
*  the following bitmasks for XInput: XINPUT_GAMEPAD_DPAD_UP,
*  XINPUT_GAMEPAD_DPAD_DOWN, XINPUT_GAMEPAD_DPAD_LEFT,
*  XINPUT_GAMEPAD_DPAD_RIGHT, XINPUT_GAMEPAD_START,
*  XINPUT_GAMEPAD_BACK, XINPUT_GAMEPAD_LEFT_THUMB,
*  XINPUT_GAMEPAD_RIGHT_THUMB, XINPUT_GAMEPAD_LEFT_SHOULDER,
*  XINPUT_GAMEPAD_RIGHT_SHOULDER, XINPUT_GAMEPAD_A, XINPUT_GAMEPAD_B,
*  XINPUT_GAMEPAD_X, XINPUT_GAMEPAD_Y

* RETURN VALUE
*  TRUE if button was released.
*  FALSE otherwise.
* SEE ALSO
*  ButtonIsPressed(INT.index,INT.buttonOrMask)
*  ButtonTriggered(INT.index,INT.buttonOrMask)
*  SampleInGameImplementation.cpp to see an example.
******
*/
BOOL ControllerInput::ButtonReleased(CONST INT index, CONST INT buttonOrMask)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->ButtonReleased(buttonOrMask);
    }

    return FALSE;
}

/****f* Controller.Input.SDK/GetNumberFFAxesDInput(INT.index)
* NAME
*  INT GetNumberFFAxesDInput(INT index) -- find out how many force
*  feedback axes the controller has.
* INPUTS
*  index - index of the controller (between 0 and
*  LG_MAX_CONTROLLERS).
* RETURN VALUE
*  Number of FF axes.
******
*/
INT ControllerInput::GetNumberFFAxesDInput(CONST INT index)
{
    if (ControllerExists(index))
    {
        return g_controller[index]->GetNumberFFAxes();
    }

    return 0;
}

VOID ControllerInput::FreeDirectInput()
{
    for (INT ii = 0; ii < LogitechControllerInput::LG_MAX_CONTROLLERS; ii++)
    {
        RemoveController(ii);
    }

    if (g_DIInterface)
    {
        g_DIInterface = NULL;
    }
}

HWND ControllerInput::GetGameHWnd()
{
    return m_gameHWnd;
}

HRESULT ControllerInput::RemoveController(CONST INT index)
{
    if (NULL == g_controller[index])
        return E_FAIL;

    if (g_controller[index]->GetDeviceHandle())
    {
        g_controller[index]->GetDeviceHandle()->Unacquire();
    }
    delete g_controller[index];
    g_controller[index] = NULL;

    /* following feature was removed because if the extra device happens to be a XInput device and its XInput ID is different of 0, it will fail */
    //// See if number of controllers before removal was = to
    //// LG_MAX_CONTROLLERS. In this case let's re-enumerate
    //// because it could be that there extra controllers
    //// present that didn't get an available spot before.
    //INT counter_ = 0;
    //for (INT jj = 0; jj < LG_MAX_CONTROLLERS; jj++)
    //{
    //    if (NULL != g_controller[jj])
    //        ++counter_;
    //}

    //if (counter_ == LG_MAX_CONTROLLERS - 1)
    //    g_gameControllerWasPluggedIn = TRUE;

    return S_OK;
}

INT ControllerInput::GetCurrentNumberControllersConnected()
{
    INT counter_ = 0;

    for (INT index_ = 0; index_ < LogitechControllerInput::LG_MAX_CONTROLLERS; index_++)
    {
        if (IsConnected(index_))
        {
            ++counter_;
        }
    }

    return counter_;
}

LRESULT CALLBACK NewWindowProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    //LONG_PTR ptr_ = GetWindowLongPtr(hwnd, GWLP_USERDATA);
    //ControllerInput* controllerInput_ = (ControllerInput*)ptr_;

    DEV_BROADCAST_HDR* pHeader_ = NULL;
    DEV_BROADCAST_DEVICEINTERFACE* deviceInterface_ = NULL;

    BOOL activateValue_ = FALSE;

    switch(message)
    {
    case WM_ACTIVATEAPP:
        activateValue_ = static_cast<BOOL>(wParam);
        if (activateValue_)
        {
            //LOGICONTROLLERTRACE(_T("WM_ACTIVATEAPP: window got activated\n"));
            XInputEnable(TRUE);
            g_appGotActivated = TRUE;
        }
        else
        {
            //LOGICONTROLLERTRACE(_T("WM_ACTIVATEAPP: window got DEactivated\n"));
            XInputEnable(FALSE);
        }
        break;
    case WM_DESTROY:
        //LOGICONTROLLERTRACE(_T("WindowProc()->WM_DESTROY\n"));
        KillTimer(hwnd, 1);
        break;

    case WM_CREATE:
        {
            CREATESTRUCT* pcs = (CREATESTRUCT*)lParam;
            if (pcs)
            {

                SetWindowLongPtr(hwnd, GWLP_USERDATA, (__int3264)(LONG_PTR)pcs->lpCreateParams);
            }

            SetTimer(hwnd,1,200,NULL);
        }
        break;
    case WM_NCDESTROY:
        //LOGICONTROLLERTRACE("WindowProc()->WM_NCDESTROY\n");
        break;
    case WM_NCCREATE:
        break;
    case WM_DEVICECHANGE:
        // disconnecting or connecting any device, including my pda, can trigger the centering spring, so let's do something about it
        g_deviceWasChanged = TRUE;

        switch (wParam)
        {
        case DBT_DEVICEARRIVAL:
            //LOGICONTROLLERTRACE(_T("DBT_DEVICEARRIVAL\n"));
            pHeader_ = (DEV_BROADCAST_HDR*)lParam;
            if (pHeader_)
            {
                if (pHeader_->dbch_devicetype == DBT_DEVTYP_DEVICEINTERFACE)
                {
                    g_gameControllerWasPluggedIn = TRUE;
                }
            }
            break;
        case DBT_DEVICEREMOVECOMPLETE:
            //LOGICONTROLLERTRACE(_T("DBT_DEVICEREMOVECOMPLETE\n"));

            pHeader_ = (DEV_BROADCAST_HDR*)lParam;
            if (pHeader_)
            {
                if (pHeader_->dbch_devicetype == DBT_DEVTYP_DEVICEINTERFACE)
                {
                    deviceInterface_ = (DEV_BROADCAST_DEVICEINTERFACE*)lParam;

                    //LOGICONTROLLERTRACE(_T("Need to remove %s\n"), deviceInterface_->dbcc_name);
                    TCHAR uniqueIDRemoved_[MAX_PATH] = {'\0'};
                    if (FAILED(Utils::Instance()->GetUniqueIDFromDbcc_name(uniqueIDRemoved_, deviceInterface_->dbcc_name)))
                        break;

                    STRING uniqueIDRemovedWString_(uniqueIDRemoved_);
                    g_uniqueIDsRemoved.push_back(uniqueIDRemovedWString_);
                }
            }
            break;
        default:
            break;
        }
        break;
    default:
        break;
    }

    return CallWindowProc (g_OldWnd, hwnd, message, wParam, lParam);
}

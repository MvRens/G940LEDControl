/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#ifndef LOGI_CONTROLLER_INPUT_GLOBALS_H_INCLUDED_
#define LOGI_CONTROLLER_INPUT_GLOBALS_H_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800

#include <tchar.h>
#include <crtdbg.h>
#include <vector>
#include <map>
#include <dinput.h>

namespace LogitechControllerInput
{
    /************************************************/
    /* Variables that can be changed to your liking */
    /************************************************/
#ifdef _DEBUG
#define LOGICONTROLLERTRACE LogitechControllerInput::Utils::Instance()->LogiTrace
#else
#define LOGICONTROLLERTRACE __noop
#endif

    CONST INT LG_MAX_CONTROLLERS = 4;

    CONST INT LG_DINPUT_RANGE_MIN = -32768;
    CONST INT LG_DINPUT_RANGE_MAX = 32767;

#ifdef _UNICODE
    typedef std::wstring STRING;
#else
    typedef std::string STRING;
#endif
    typedef std::vector<STRING> STRING_VECTOR;
    typedef std::vector<INT> INT_VECTOR;

    class DeviceInfo;
    typedef std::vector<DeviceInfo> DEVICE_INFO_VECTOR;
    typedef std::map<INT, DeviceInfo> DEVICE_INFO_MAP;

    struct RecurringTimerData;
    typedef std::vector<RecurringTimerData> RECURRING_TIMER_DATA_VECTOR;

    /**************************************/
    /* Constants that must not be changed */
    /**************************************/
    CONST INT LG_NBR_XINPUT_CONTROLLERS = 4; // as defined by Microsoft

    CONST INT LG_XINPUT_ID_NONE = -1;
    CONST INT LG_CONTROLLER_NUMBER_NONE = -1;

    CONST INT LG_LOOKUP_TABLE_SIZE = 1024;

    CONST DWORD LG_MAX_TIME_RESET_OR_ADD_CONTROLLERS = 7000; // milliseconds
    CONST DWORD LG_TIME_INTERVAL_RESET_OR_ADD_CONTROLLERS = 1500; // milliseconds

    CONST DWORD VID_LOGITECH = 0x046d;
    CONST DWORD VID_MICROSOFT = 0x045e;

    // Wheel PIDs
    CONST DWORD PID_G27 = 0xC29B;
    CONST DWORD PID_DRIVING_FORCE_GT = 0xC29A;
    CONST DWORD PID_G25 = 0xC299;
    CONST DWORD PID_MOMO_RACING = 0xCA03;
    CONST DWORD PID_MOMO_FORCE = 0xC295;
    CONST DWORD PID_DRIVING_FORCE_PRO = 0xC298;
    CONST DWORD PID_DRIVING_FORCE = 0xC294; // same PID for Driving Force EX/RX and Formula Force EX
    CONST DWORD PID_NASCAR_RACING_WHEEL = 0xCA04;
    CONST DWORD PID_FORMULA_FORCE = 0xC291;
    CONST DWORD PID_FORMULA_FORCE_GP = 0xC293;

    // Joystick PIDs
    CONST DWORD PID_FORCE_3D_PRO = 0xC286;
    CONST DWORD PID_EXTREME_3D_PRO = 0xC215;
    CONST DWORD PID_FREEDOM_24 = 0xC213;
    CONST DWORD PID_ATTACK_3 = 0xC214;
    CONST DWORD PID_FORCE_3D = 0xC283;
    CONST DWORD PID_STRIKE_FORCE_3D = 0xC285;
    CONST DWORD PID_G940_JOYSTICK = 0xC2A8;
    CONST DWORD PID_G940_THROTTLE = 0xC2A9;
    CONST DWORD PID_G940_PEDALS = 0xC2AA;

    // Gamepad PIDs
    CONST DWORD PID_RUMBLEPAD = 0xC20A;
    CONST DWORD PID_RUMBLEPAD_2 = 0xC218;
    CONST DWORD PID_CORDLESS_RUMBLEPAD_2 = 0xC219;
    CONST DWORD PID_CORDLESS_GAMEPAD = 0xC211;
    CONST DWORD PID_DUAL_ACTION_GAMEPAD = 0xC216;
    CONST DWORD PID_PRECISION_GAMEPAD_2 = 0xC21A;
    CONST DWORD PID_CHILLSTREAM = 0xC242;

    typedef enum
    {
        LG_DEVICE_TYPE_NONE = -1, LG_DEVICE_TYPE_WHEEL, LG_DEVICE_TYPE_JOYSTICK, LG_DEVICE_TYPE_GAMEPAD, LG_DEVICE_TYPE_OTHER
    } DeviceType;

    typedef enum
    {
        LG_MANUFACTURER_NONE = -1, LG_MANUFACTURER_LOGITECH, LG_MANUFACTURER_MICROSOFT, LG_MANUFACTURER_OTHER
    } ManufacturerName;

    typedef enum
    {
        LG_MODEL_G27,
        LG_MODEL_DRIVING_FORCE_GT,
        LG_MODEL_G25,
        LG_MODEL_MOMO_RACING,
        LG_MODEL_MOMO_FORCE,
        LG_MODEL_DRIVING_FORCE_PRO,
        LG_MODEL_DRIVING_FORCE,
        LG_MODEL_NASCAR_RACING_WHEEL,
        LG_MODEL_FORMULA_FORCE,
        LG_MODEL_FORMULA_FORCE_GP,
        LG_MODEL_FORCE_3D_PRO,
        LG_MODEL_EXTREME_3D_PRO,
        LG_MODEL_FREEDOM_24,
        LG_MODEL_ATTACK_3,
        LG_MODEL_FORCE_3D,
        LG_MODEL_STRIKE_FORCE_3D,
        LG_MODEL_G940_JOYSTICK,
        LG_MODEL_G940_THROTTLE,
        LG_MODEL_G940_PEDALS,
        LG_MODEL_RUMBLEPAD,
        LG_MODEL_RUMBLEPAD_2,
        LG_MODEL_CORDLESS_RUMBLEPAD_2,
        LG_MODEL_CORDLESS_GAMEPAD,
        LG_MODEL_DUAL_ACTION_GAMEPAD,
        LG_MODEL_PRECISION_GAMEPAD_2,
        LG_MODEL_CHILLSTREAM,
        LG_NUMBER_MODELS
    } ModelName;

    // TODO: define buttons similar to XInput for all our gamepads
    typedef enum
    {
        DPAD_UP,
        DPAD_DOWN

    } XInputEquivalentButtons;

    class DeviceInfo
    {
    public:
        DeviceInfo() { Init(); }

        LPDIRECTINPUTDEVICE8 device;
        INT index; // index corresponding to enumeration order (as in index of g_deviceHandlesLocal array)
        STRING deviceIDString;
        DWORD vid;
        DWORD pid;
        INT IG_nbr; // only XInput devices have such a number. If it is -1, it is a DInput device
        STRING uniqueID;
        BOOL isXinput;
        DeviceType deviceType;
        INT numFFAxis;
        STRING friendlyName;

    private:
        VOID Init()
        {
            device = NULL;
            index = -1;
            vid = 0;
            pid = 0;
            IG_nbr = -1;
            isXinput = FALSE;
            deviceType = LG_DEVICE_TYPE_NONE;
            numFFAxis = 0;
        }
    };

    struct RecurringTimerData
    {
        INT id;
        DWORD initialTickCounts;
        DWORD endTickCounts;
        DWORD intervals;
        INT previousTickZone;
    };
}

#endif // LOGI_CONTROLLER_INPUT_GLOBALS_H_INCLUDED_

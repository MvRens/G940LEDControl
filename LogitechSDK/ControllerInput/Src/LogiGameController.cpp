/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiGameController.h"
#include "LogiControllerInputUtils.h"

using namespace LogitechControllerInput;

LogiGameController::LogiGameController()
{
    m_timeCreated = GetTickCount();

    Init();
}

VOID LogiGameController::Init()
{
    m_device = NULL;
    m_numFFAxes = 0;
    m_deviceType = LG_DEVICE_TYPE_NONE;
    m_actuatorsAreOn = FALSE;
    m_vid = 0;
    m_pid = 0;
    m_friendlyProductName[0] = '\0';
    m_isXInputDevice = FALSE;
    m_deviceXID = LG_XINPUT_ID_NONE;
    m_ctrlNbr = LG_CONTROLLER_NUMBER_NONE;
    m_gameHWnd = NULL;
    m_deviceUniqueID[0] = '\0';
    m_nonLinearCoefficient = 0;

    for (INT jj = 0; jj < LG_LOOKUP_TABLE_SIZE; jj++)
    {
        m_nonLinearWheel[jj] = 0;
    }

    GenerateNonLinearValues(m_nonLinearCoefficient);
}

LPDIRECTINPUTDEVICE8 LogiGameController::GetDeviceHandle()
{
    return m_device;
}

VOID LogiGameController::SetDeviceHandle(CONST LPDIRECTINPUTDEVICE8 device)
{
    m_device = device;
}

BOOL LogiGameController::IsConnected(CONST DeviceType deviceType)
{
    if (NULL == m_device)
        return FALSE;

    return (m_deviceType == deviceType) ? TRUE : FALSE;
}

BOOL LogiGameController::IsConnected(CONST ManufacturerName manufacturerName)
{
    if (NULL == m_device)
        return FALSE;

    DWORD vid_ = GetVid();

    if (manufacturerName == LG_MANUFACTURER_OTHER)
    {
        if (vid_ != VID_LOGITECH && vid_ != VID_MICROSOFT)
        {
            return TRUE;
        }
    }
    else
    {

        DWORD manufacturer_ = 0xffffffff;

        switch (manufacturerName)
        {
        case LG_MANUFACTURER_LOGITECH:
            manufacturer_ = VID_LOGITECH;
            break;
        case LG_MANUFACTURER_MICROSOFT:
            manufacturer_ = VID_MICROSOFT;
            break;
        default:
            return FALSE;
        }

        if (vid_ == manufacturer_)
        {
            return TRUE;
        }
    }

    return FALSE;
}

BOOL LogiGameController::IsConnected(CONST ModelName modelName)
{
    if (NULL == m_device)
        return FALSE;

    // We only support this function for Logitech devices
    if (!IsConnected(LG_MANUFACTURER_LOGITECH))
    {
        return FALSE;
    }

    DWORD model_ = 0xffffffff;

    switch (modelName)
    {
    case LG_MODEL_G27: model_ = PID_G27; break;
    case LG_MODEL_DRIVING_FORCE_GT: model_ = PID_DRIVING_FORCE_GT; break;
    case LG_MODEL_G25: model_ = PID_G25; break;
    case LG_MODEL_MOMO_RACING: model_ = PID_MOMO_RACING; break;
    case LG_MODEL_MOMO_FORCE: model_ = PID_MOMO_FORCE; break;
    case LG_MODEL_DRIVING_FORCE_PRO: model_ = PID_DRIVING_FORCE_PRO; break;
    case LG_MODEL_DRIVING_FORCE: model_ = PID_DRIVING_FORCE; break;
    case LG_MODEL_NASCAR_RACING_WHEEL: model_ = PID_NASCAR_RACING_WHEEL; break;
    case LG_MODEL_FORMULA_FORCE: model_ = PID_FORMULA_FORCE; break;
    case LG_MODEL_FORMULA_FORCE_GP: model_ = PID_FORMULA_FORCE_GP; break;
    case LG_MODEL_FORCE_3D_PRO: model_ = PID_FORCE_3D_PRO; break;
    case LG_MODEL_EXTREME_3D_PRO: model_ = PID_EXTREME_3D_PRO; break;
    case LG_MODEL_FREEDOM_24: model_ = PID_FREEDOM_24; break;
    case LG_MODEL_ATTACK_3: model_ = PID_ATTACK_3; break;
    case LG_MODEL_FORCE_3D: model_ = PID_FORCE_3D; break;
    case LG_MODEL_STRIKE_FORCE_3D: model_ = PID_STRIKE_FORCE_3D; break;
    case LG_MODEL_G940_JOYSTICK: model_ = PID_G940_JOYSTICK; break;
    case LG_MODEL_G940_THROTTLE: model_ = PID_G940_THROTTLE; break;
    case LG_MODEL_G940_PEDALS: model_ = PID_G940_PEDALS; break;
    case LG_MODEL_RUMBLEPAD: model_ = PID_RUMBLEPAD; break;
    case LG_MODEL_RUMBLEPAD_2: model_ = PID_RUMBLEPAD_2; break;
    case LG_MODEL_CORDLESS_RUMBLEPAD_2: model_ = PID_CORDLESS_RUMBLEPAD_2; break;
    case LG_MODEL_CORDLESS_GAMEPAD: model_ = PID_CORDLESS_GAMEPAD; break;
    case LG_MODEL_DUAL_ACTION_GAMEPAD: model_ = PID_DUAL_ACTION_GAMEPAD; break;
    case LG_MODEL_PRECISION_GAMEPAD_2: model_ = PID_PRECISION_GAMEPAD_2; break;
    case LG_MODEL_CHILLSTREAM: model_ = PID_CHILLSTREAM; break;

    default:
        _ASSERT(FALSE);
        break;
    }

    DWORD pid_ = GetPid();

    if (model_ == pid_)
    {
        return TRUE;
    }

    return FALSE;
}

VOID LogiGameController::SetVidPid(CONST DWORD vidPid)
{
    m_vid = LOWORD(vidPid);
    m_pid = HIWORD(vidPid);
}

VOID LogiGameController::SetVid(CONST DWORD vid)
{
    m_vid = vid;
}

VOID LogiGameController::SetPid(CONST DWORD pid)
{
    m_pid = pid;
}

DWORD32 LogiGameController::GetVid()
{
    return m_vid;
}

DWORD32 LogiGameController::GetPid()
{
    return m_pid;
}

VOID LogiGameController::SetFriendlyProductName(LPCTSTR name)
{
    _tcscpy_s(m_friendlyProductName, name);
}

LPCTSTR LogiGameController::GetFriendlyProductName()
{
    return m_friendlyProductName;
}

// nonLinCoeff between 0 and 100. 0 = linear, 100 = maximum mon-linear.
VOID LogiGameController::GenerateNonLinearValues(CONST INT nonLinCoeff)
{
    if (nonLinCoeff == m_nonLinearCoefficient)
    {
        return;
    }

    m_nonLinearCoefficient = nonLinCoeff;

    // Populate lookup table
    for (INT ii = 0; ii < LG_LOOKUP_TABLE_SIZE - 1; ii++)
    {
        m_nonLinearWheel[ii] = (INT)CalculateNonLinValue(ii, m_nonLinearCoefficient, LG_DINPUT_RANGE_MIN, LG_DINPUT_RANGE_MAX);
    }

    // Let's use 10 bits for reading wheel axis, which means 1024 counts. 0 - 1023 gives 511.5 as center position. We need a TRUE center
    // so let's use the range of 0 to 1022 and just define 1023 as equal to 1022.
    m_nonLinearWheel[LG_LOOKUP_TABLE_SIZE - 1] = m_nonLinearWheel[LG_LOOKUP_TABLE_SIZE - 2];
}

///////////////////////////////////////////////////////////////////////
// Method: calculateNonLinearValue(INT inputValue, INT nonLinearCoeff,
// FLOAT physicsMinInput, FLOAT physicsMaxInput)
//     Method calculates a non-linear output value from a linear
//     input value that corresponds to the Logitech wheel output.
//
// Arguments: inputValue: must be between 0 and 255. This corresponds
//        directly to the wheel's position values.
//
//        nonLinearCoeff: non-linearity coefficient which must be a
//        value between 0 and 100.
//      0 corresponds to a completely linear response curve and 100
//      to a heavily non-linear response curve.
//
//        physicsMinInput and physicsMaxInput: minimum and maximum
//      numbers that you want as output in your lookup table. For
//      example if your physics engine takes -1000 to 1000 as input
//      you may specify those values here.
//
// Returns: floating number which has a value between physicsMinInput
//      and physicsMaxInput and which reflects the chosen
//      non-linearity curve.
///////////////////////////////////////////////////////////////////////
FLOAT LogiGameController::CalculateNonLinValue(CONST INT inputValue, CONST INT nonLinearCoeff, CONST LONG physicsMinInput, CONST LONG physicsMaxInput)
{
    // Let's use 10 bits for reading wheel axis, which means 1024 counts. 0 - 1023 gives 511.5 as center position. We need a TRUE center
    // so let's use the range of 0 to 1022 and just define 1023 as equal to 1022.
    INT MaxLookupTableInput_ = 1022;  // These values correspond to the
    // wheel's position values.
    INT MinLookupTableInput_ = 0;
    FLOAT outputValue_;

    // In order to center our curve on the X axis let's calculate the
    // center offset value
    FLOAT centerOffset_ = (FLOAT)(MaxLookupTableInput_ -
        MinLookupTableInput_) / 2;

    // Calculate maximum on x axis for the centered curve
    FLOAT centeredCurveMax_ = MaxLookupTableInput_ - centerOffset_;

    // Normalize non-linear coefficient
    FLOAT nonLinearCoeffNormalized_ = (FLOAT)nonLinearCoeff/100;

    // Normalize input value
    outputValue_=((FLOAT)(inputValue - centerOffset_))/centeredCurveMax_;

    // Apply a cubical curve
    outputValue_=(((physicsMaxInput - physicsMinInput)/2)*((1.0f-nonLinearCoeffNormalized_)*outputValue_+(nonLinearCoeffNormalized_)
        *(outputValue_*outputValue_*outputValue_))) + ((physicsMaxInput + physicsMinInput)/2);

    // if LG_DINPUT_RANGE_MIN is an even number and LG_DINPUT_RANGE_MAX is 
    // odd, then because of the way the calculation is made we probably 
    // get a min that is 1 above, so let's re-adjust it to make sure we do 
    // indeed get the min.
    if (Utils::Instance()->IsEven(LG_DINPUT_RANGE_MIN) && !Utils::Instance()->IsEven(LG_DINPUT_RANGE_MAX))
    {
        if (outputValue_ == LG_DINPUT_RANGE_MIN + 1)
            outputValue_ = outputValue_ - 1.0f;
    }

    // Clip output value
    if (outputValue_ < LG_DINPUT_RANGE_MIN)
    {
        outputValue_ = LG_DINPUT_RANGE_MIN;
    }

    if (outputValue_ > LG_DINPUT_RANGE_MAX)
    {
        outputValue_ = LG_DINPUT_RANGE_MAX;
    }

    return outputValue_;
}

INT LogiGameController::GetNonLinearValue(CONST INT inputValue)
{
    if (inputValue < LG_DINPUT_RANGE_MIN)
    {
        return LG_DINPUT_RANGE_MIN;
    }

    if (inputValue > LG_DINPUT_RANGE_MAX)
    {
        return LG_DINPUT_RANGE_MAX;
    }

    INT index_ = (INT)(((511.5f * (FLOAT)inputValue) / LG_DINPUT_RANGE_MAX) + 511.5f);

    if (index_ < 0 && index_ > 1024)
        return inputValue;

    return m_nonLinearWheel[index_];
}

VOID LogiGameController::SetDeviceType(CONST DeviceType deviceType)
{
    m_deviceType = deviceType;
}

BOOL LogiGameController::IsXInputDevice()
{
    return m_isXInputDevice;
}

HRESULT LogiGameController::SetDeviceUniqueID(LPCTSTR uniqueID)
{
    errno_t ret_ = _tcscpy_s(m_deviceUniqueID, _countof(m_deviceUniqueID), uniqueID);

    if (0 != ret_)
        return E_FAIL;

    return S_OK;
}

TCHAR* LogiGameController::GetDeviceUniqueID()
{
    return m_deviceUniqueID;
}

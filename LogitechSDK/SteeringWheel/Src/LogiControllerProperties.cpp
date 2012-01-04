#include "LogiControllerProperties.h"
#include <dbt.h>
#include <map>

using namespace LogitechSteeringWheel;

CONST LPTSTR LGMSGPIPE_WINDOWCLASS = _T("Logitech Wingman Internal Message Router");

std::map<DWORD, ControllerPropertiesData> g_currentProperties;
std::map<DWORD, BOOL> g_setIsNecessary;
std::map<DWORD, BOOL> g_getIsNecessary;

WNDPROC g_SteeringWheelSDKOldWnd;
LRESULT CALLBACK NewSteeringWheelSDKWindowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);

ControllerProperties::ControllerProperties(HWND hwnd)
{
    m_gameHWnd = hwnd;

    ZeroMemory(&m_defaultControllerProperties, sizeof(m_defaultControllerProperties));
    ZeroMemory(&m_preferredControllerProperties, sizeof(m_preferredControllerProperties));

    m_hadToStartEMon = FALSE;

    SetDefaults();

    m_preferredControllerProperties = m_defaultControllerProperties;

    m_currentVersionSupportsGetSetProperties = FALSE;

    // Check Logitech Gaming Software version
    ZeroMemory(&m_wingmanVersion, sizeof(m_wingmanVersion));
    if (SUCCEEDED(m_gamingSoftwareManager.GetWingmanSWVersion(m_wingmanVersion)))
    {
        if (m_wingmanVersion.major == 5 && m_wingmanVersion.minor >= 3
            || m_wingmanVersion.major > 5)
        {
            m_currentVersionSupportsGetSetProperties = TRUE;
        }
        //else
        //{
            //TRACE(_T("WARNING: current Gaming Software version is older than 5.03 and does not support get/set properties.\n"));
            //TRACE(_T("Please install Logitech Gaming Software 5.03 or newer.\n"));
        //}
    }
    else
    {
        // Let's suppose the following
        m_currentVersionSupportsGetSetProperties = TRUE;
    }

    // saw this on Vista 64, so let's deal with it
    if (0 == m_wingmanVersion.major)
    {
        m_currentVersionSupportsGetSetProperties = TRUE;
    }

    // Start Wingman gaming software if necessary
    if (START_LOGITECH_SOFTWARE)
    {
        if (!m_gamingSoftwareManager.IsEventMonitorRunning())
        {
            // Only start event monitor if it supports getting and setting properties
            if (m_currentVersionSupportsGetSetProperties)
            {
                m_gamingSoftwareManager.StartEventMonitor();
                m_hadToStartEMon = TRUE;
            }
        }
    }

    //Replace the Window Procedure and Store the Old Window Procedure
    g_SteeringWheelSDKOldWnd = (WNDPROC)(LONG_PTR)GetWindowLongPtr(hwnd, GWLP_WNDPROC);
    SetWindowLongPtr(hwnd, GWLP_WNDPROC, (__int3264)(LONG_PTR)NewSteeringWheelSDKWindowProc);
}

ControllerProperties::~ControllerProperties()
{
    if (m_hadToStartEMon)
    {
        m_gamingSoftwareManager.StopEventMonitor();
    }
}

HRESULT ControllerProperties::SetPreferred(ControllerPropertiesData properties)
{
    // Check propertiesData to see if there isn't anything wrong.
    if ((properties.defaultSpringEnabled != TRUE 
        && properties.defaultSpringEnabled != FALSE)
        || (properties.forceEnable != TRUE 
        && properties.forceEnable != FALSE)
        || (properties.damperGain < LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MIN 
        && properties.damperGain > LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MAX)
        || (properties.defaultSpringGain < LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MIN 
        && properties.defaultSpringGain > LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MAX)
        || (properties.overallGain < LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MIN 
        && properties.overallGain > LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MAX)
        || (properties.springGain < LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MIN 
        && properties.springGain > LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MAX)
        || (properties.combinePedals != TRUE 
        && properties.combinePedals != FALSE)
        || (properties.wheelRange < LG_CONTROL_PANEL_PROPERTIES_OPERATING_RANGE_MIN 
        && properties.wheelRange > LG_CONTROL_PANEL_PROPERTIES_OPERATING_RANGE_MAX))
    {
        _ASSERT(NULL);
        return E_INVALIDARG;
    }

    // Check version
    if (m_wingmanVersion.major == 5 && m_wingmanVersion.minor >= 3
        || m_wingmanVersion.major > 5)
    {
        // version is good
    }
    else
    {
        return E_FAIL;
    }

    if (!ControllerPropertiesAreEqual(m_preferredControllerProperties, properties))
    {
        std::map <DWORD,BOOL>::iterator itr_;
        for(itr_ = g_setIsNecessary.begin();itr_!=g_setIsNecessary.end();itr_++)
        {
            g_setIsNecessary[itr_->first] = TRUE;
        }
    }

    m_preferredControllerProperties = properties;

    return S_OK;
}

//VOID ControllerProperties::SetPreferred(CONST DWORD controllerPID, CONST ControllerSetProperty deviceSetProperty, CONST INT value)
//{
//    if (deviceSetProperty < PROPERTY_ALL
//        || deviceSetProperty >= PROPERTY_NUMBER)
//    {
//        //Utils::LogiTrace(_T("Error: invalid argument given to ControllerProperties::SetPreferred(...)\n"));
//        _ASSERT(NULL);
//        return;
//    }
//
//    // Check version
//    if (m_wingmanVersion.major == 5 && m_wingmanVersion.minor >= 3
//        || m_wingmanVersion.major > 5)
//    {
//        // version is good
//    }
//    else
//    {
//        return;
//    }
//
//    ControllerPropertiesSetData propertiesSetData_;
//    ZeroMemory(&propertiesSetData_, sizeof(propertiesSetData_));
//
//    propertiesSetData_.size = sizeof(ControllerPropertiesSetData);
//    propertiesSetData_.propertyToSet = deviceSetProperty;
//    propertiesSetData_.versionNbr = VERSION_NUMBER_PROPERTIES;
//    propertiesSetData_.productID = controllerPID;
//    propertiesSetData_.properties = m_defaultControllerProperties;
//
//    switch(deviceSetProperty)
//    {
//    case PROPERTY_OVERALL_GAIN:
//        propertiesSetData_.properties.overallGain = value;
//        break;
//    case PROPERTY_SPRING_GAIN:
//        propertiesSetData_.properties.springGain = value;
//        break;
//    case PROPERTY_DAMPER_GAIN:
//        propertiesSetData_.properties.damperGain = value;
//        break;
//    case PROPERTY_FORCE_ENABLE:
//        propertiesSetData_.properties.forceEnable = value;
//        break;
//    case PROPERTY_COMBINED_PEDALS:
//        propertiesSetData_.properties.combinePedals = value;
//        break;
//    case PROPERTY_WHEEL_RANGE:
//        propertiesSetData_.properties.wheelRange = value;
//        break;
//    default:
//        _ASSERT(NULL);
//    }
//
//    COPYDATASTRUCT myCDS_;
//    myCDS_.dwData = JOY_CONTROL_PANEL_SET_PROPERTIES ;
//    myCDS_.cbData = sizeof(propertiesSetData_);
//    myCDS_.lpData = &propertiesSetData_;
//
//    HWND hEventMonitor_ = ::FindWindow(LGMSGPIPE_WINDOWCLASS, NULL);
//    if (!hEventMonitor_)
//    { 
//        //Utils::LogiTrace(_T("ControllerProperties::SetPreferred(): Didn't get the event monitor...\n"));
//        return;
//    }
//    else
//    {
//        ::SendMessage(hEventMonitor_, WM_COPYDATA, (WPARAM)(HWND)m_gameHWnd, (LPARAM)(LPVOID)&myCDS_);
//
//        g_setIsNecessary = TRUE;
//    }
//}

VOID ControllerProperties::GetDefault(ControllerPropertiesData& properties)
{
    properties = m_defaultControllerProperties;
}

HRESULT ControllerProperties::GetASync(CONST DWORD controllerPID)
{
    ControllerPropertiesGetData propertiesGetData_;
    ZeroMemory(&propertiesGetData_, sizeof(propertiesGetData_));

    propertiesGetData_.size = sizeof(ControllerPropertiesGetData);
    propertiesGetData_.versionNbr = VERSION_NUMBER_PROPERTIES;
    propertiesGetData_.productID = controllerPID;
    propertiesGetData_.properties = m_defaultControllerProperties;

    COPYDATASTRUCT myCDS_;
    myCDS_.dwData = JOY_CONTROL_PANEL_GET_PROPERTIES ;
    myCDS_.cbData = sizeof(propertiesGetData_);
    myCDS_.lpData = &propertiesGetData_;

    HWND hEventMonitor_ = ::FindWindow(LGMSGPIPE_WINDOWCLASS, NULL);
    if (!hEventMonitor_)
    { 
        return E_FAIL;
    }
    else
    {
        ::SendMessage(hEventMonitor_, WM_COPYDATA, (WPARAM)(HWND)m_gameHWnd, (LPARAM)(LPVOID)&myCDS_);
    }

    return S_OK;
}

BOOL ControllerProperties::GetCurrent(CONST DWORD controllerPID, ControllerPropertiesData& properties)
{
    if (0 == g_currentProperties.count(controllerPID))
    {
        GetDefault(properties);
        return FALSE;
    }
    else
    {
        properties = g_currentProperties[controllerPID];
        return TRUE;
    }
}

BOOL ControllerProperties::ControllerPropertiesAreEqual(CONST ControllerPropertiesData properties1, CONST ControllerPropertiesData properties2, CONST BOOL ignoreWheelRange)
{
    if (properties1.forceEnable == properties2.forceEnable
        && properties1.defaultSpringEnabled == properties2.defaultSpringEnabled
        && properties1.damperGain == properties2.damperGain
        && properties1.overallGain == properties2.overallGain
        && properties1.springGain == properties2.springGain
        && properties1.combinePedals == properties2.combinePedals)
    {
        if (ignoreWheelRange)
        {
            return TRUE;
        }
        else
        {
            if (properties1.wheelRange == properties2.wheelRange)
            {
                return TRUE;
            }
        }
    }

    return FALSE;
}

VOID ControllerProperties::SetDefaults()
{
    m_defaultControllerProperties.defaultSpringEnabled = FALSE;
    m_defaultControllerProperties.forceEnable = TRUE;
    m_defaultControllerProperties.damperGain = 100;
    m_defaultControllerProperties.defaultSpringGain = 100;
    m_defaultControllerProperties.overallGain = 100;
    m_defaultControllerProperties.springGain= 100;

    // We have separate pedals by default since 5.01
    m_defaultControllerProperties.combinePedals = TRUE;

    WingmanSoftwareVersion version_;
    if (SUCCEEDED(m_gamingSoftwareManager.GetWingmanSWVersion(version_)))
    {
        if (version_.major == 5 && version_.minor >= 1
            || version_.major > 5)
        {
            m_defaultControllerProperties.combinePedals = FALSE;
        }
    }
    else
    {
        m_defaultControllerProperties.combinePedals = FALSE;
    }

    m_defaultControllerProperties.wheelRange = 200;

    m_defaultControllerProperties.gameSettingsEnabled = TRUE;
    m_defaultControllerProperties.allowGameSettings = TRUE;
}

INT ControllerProperties::GetShifterMode(CONST LPDIRECTINPUTDEVICE8 device)
{
    INT isShifterGated_ = -1;

    if (NULL != device)
    {
        ShifterData shifterData_;
        ZeroMemory(&shifterData_, sizeof(shifterData_));
        shifterData_.size = sizeof(ShifterData);
        shifterData_.versionNbr = VERSION_NUMBER_SHIFTER_MODE;
        shifterData_.isGated = -1;

        DIEFFESCAPE data_;
        ZeroMemory(&data_, sizeof(data_));

        data_.dwSize = sizeof(DIEFFESCAPE);
        data_.dwCommand = ESCAPE_COMMAND_GATED_SHIFTER_MODE;
        data_.lpvInBuffer = &shifterData_;
        data_.cbInBuffer = sizeof(shifterData_);

        HRESULT hr_ = E_FAIL;
        if (SUCCEEDED(hr_ = device->Escape(&data_)))
        {
            isShifterGated_ = -1;

            if (sizeof(INT) == data_.cbOutBuffer)
            {
                INT* returnValue_ = (INT*)data_.lpvOutBuffer;
                if (NULL != returnValue_)
                {
                    isShifterGated_ = *returnValue_;
                }
            }
        }
        else
        {
            //TRACE(_T("ERROR: escape returned error: 0x%x\n"), hr_);
        }
    }

    return isShifterGated_;
}

BOOL ControllerProperties::IsMultiturnCapable(CONST DWORD controllerPID)
{
    // Multiturn wheel PIDs
    CONST DWORD PID_G27 = 0xC29B;
    CONST DWORD PID_G25 = 0xC299;
    CONST DWORD PID_DRIVING_FORCE_PRO = 0xC298;

    if (PID_G27 == controllerPID
        || PID_G25 == controllerPID
        || PID_DRIVING_FORCE_PRO == controllerPID)
    {
        return TRUE;
    }

    return FALSE;
}

VOID ControllerProperties::SendSetMessage(CONST DWORD controllerPID, CONST ControllerPropertiesData properties)
{
    ControllerPropertiesSetData propertiesSetData_;
    ZeroMemory(&propertiesSetData_, sizeof(propertiesSetData_));

    propertiesSetData_.size = sizeof(ControllerPropertiesSetData);
    propertiesSetData_.propertyToSet = PROPERTY_ALL;
    propertiesSetData_.versionNbr = VERSION_NUMBER_PROPERTIES;
    propertiesSetData_.productID = controllerPID;
    propertiesSetData_.properties = properties;

    COPYDATASTRUCT myCDS_;
    myCDS_.dwData = JOY_CONTROL_PANEL_SET_PROPERTIES ;
    myCDS_.cbData = sizeof(propertiesSetData_);
    myCDS_.lpData = &propertiesSetData_;

    HWND hEventMonitor_ = ::FindWindow(LGMSGPIPE_WINDOWCLASS, NULL);
    if (!hEventMonitor_)
    {
        //TRACE(_T("SetPreferred: Event Monitor is not running\n"));
        return;
    }
    else
    {
        ::SendMessage(hEventMonitor_, WM_COPYDATA, (WPARAM)(HWND)m_gameHWnd, (LPARAM)(LPVOID)&myCDS_);
    }
}

HRESULT ControllerProperties::Update(CONST std::vector<DWORD> currentlyConnectedPIDs)
{
    // Check version
    if (m_wingmanVersion.major == 5 && m_wingmanVersion.minor >= 3
        || m_wingmanVersion.major > 5)
    {
        // version is good
    }
    else
    {
        return E_NOTIMPL;
    }

    if (m_previouslyConnectedPIDs != currentlyConnectedPIDs)
    {
        for (UINT index_ = 0; index_ < currentlyConnectedPIDs.size(); index_++)
        {
            SendSetMessage(currentlyConnectedPIDs[index_], m_preferredControllerProperties);
            g_setIsNecessary[currentlyConnectedPIDs[index_]] = FALSE;
            g_getIsNecessary[currentlyConnectedPIDs[index_]] = TRUE;
        }
    }

    for (UINT index_ = 0; index_ < currentlyConnectedPIDs.size(); index_++)
    {
        if (0 != g_getIsNecessary.count(currentlyConnectedPIDs[index_]))
        {
            if (g_getIsNecessary[currentlyConnectedPIDs[index_]])
            {
                GetASync(currentlyConnectedPIDs[index_]);
            }
        }

        if (0 != g_setIsNecessary.count(currentlyConnectedPIDs[index_]))
        {
            if (g_setIsNecessary[currentlyConnectedPIDs[index_]])
            {
                SendSetMessage(currentlyConnectedPIDs[index_], m_preferredControllerProperties);
                g_setIsNecessary[currentlyConnectedPIDs[index_]] = FALSE;
                g_getIsNecessary[currentlyConnectedPIDs[index_]] = TRUE;
            }
        }
    }

    m_previouslyConnectedPIDs = currentlyConnectedPIDs;

    return S_OK;
}

LRESULT CALLBACK NewSteeringWheelSDKWindowProc (HWND hwnd, UINT message, 
                                WPARAM wParam, LPARAM lParam)
{
    BOOL activateValue_ = FALSE;

    switch (message)
    {
    case WM_ACTIVATEAPP:
        activateValue_ = static_cast<BOOL>(wParam);
        if (activateValue_)
        {
            std::map <DWORD,BOOL>::iterator itr_;
            for(itr_ = g_setIsNecessary.begin();itr_!=g_setIsNecessary.end();itr_++)
            {
                g_setIsNecessary[itr_->first] = TRUE;
            }
        }
        break;
    //case WM_TIMER:
    //    {
    //        switch (wParam) 
    //        { 
    //        case 0xacbd: 
    //        }
    //    }
    //    break;
    case WM_COPYDATA:
        {
            COPYDATASTRUCT* myCDS_ = (COPYDATASTRUCT *)lParam;
            
            ControllerPropertiesGetData* properties_ = (ControllerPropertiesGetData*)myCDS_->lpData;

            if (myCDS_->dwData == JOY_CONTROL_PANEL_GET_PROPERTIES)
            {
                g_currentProperties[properties_->productID] = properties_->properties;
                g_getIsNecessary[properties_->productID] = FALSE;
            }
        }

        break;
    case WM_DEVICECHANGE:
        {
            std::map <DWORD,BOOL>::iterator itr_;
            for(itr_ = g_setIsNecessary.begin();itr_!=g_setIsNecessary.end();itr_++)
            {
                g_setIsNecessary[itr_->first] = TRUE;
            }
        }
        break;
    default:
        break;
    }

    return CallWindowProc (g_SteeringWheelSDKOldWnd, hwnd, message, wParam, lParam);
}

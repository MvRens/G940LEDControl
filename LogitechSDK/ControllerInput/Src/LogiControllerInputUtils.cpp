/*
The Logitech Controller Input SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiControllerInputUtils.h"
#include <stdio.h>
#include <crtdbg.h>
#include <tchar.h>
#include <OleAuto.h>
#include <sstream>
#include <iostream>

#include <setupapi.h>
#pragma comment(lib,"setupapi.lib")

#define LOGITECH_SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }

LogitechControllerInput::Utils* LogitechControllerInput::Utils::m_instance = 0;// initialize pointer

LogitechControllerInput::Utils* LogitechControllerInput::Utils::Instance()
{
    static Utils inst;
    return &inst;
}
LogitechControllerInput::Utils::Utils()
{
}


BOOL LogitechControllerInput::Utils::IsXInputDevice(CONST GUID* pGuidProductFromDirectInput)
{
    IWbemLocator*           pIWbemLocator  = NULL;
    IEnumWbemClassObject*   pEnumDevices   = NULL;
    IWbemClassObject*       pDevices[20]   = {0};
    IWbemServices*          pIWbemServices = NULL;
    BSTR                    bstrNamespace  = NULL;
    BSTR                    bstrDeviceID   = NULL;
    BSTR                    bstrClassName  = NULL;
    DWORD                   uReturned      = 0;
    bool                    bIsXinputDevice= false;
    UINT                    iDevice        = 0;
    VARIANT                 var;
    HRESULT                 hr;

    // CoInit if needed
    hr = CoInitialize(NULL);
    bool bCleanupCOM = SUCCEEDED(hr);

    // Create WMI
    hr = CoCreateInstance( __uuidof(WbemLocator),
        NULL,
        CLSCTX_INPROC_SERVER,
        __uuidof(IWbemLocator),
        (LPVOID*) &pIWbemLocator);
    if( FAILED(hr) || pIWbemLocator == NULL )
        goto LCleanup;

    bstrNamespace = SysAllocString( L"\\\\.\\root\\cimv2" );if( bstrNamespace == NULL ) goto LCleanup;        
    bstrClassName = SysAllocString( L"Win32_PNPEntity" );   if( bstrClassName == NULL ) goto LCleanup;        
    bstrDeviceID  = SysAllocString( L"DeviceID" );          if( bstrDeviceID == NULL )  goto LCleanup;        

    // Connect to WMI 
    hr = pIWbemLocator->ConnectServer( bstrNamespace, NULL, NULL, 0L, 
        0L, NULL, NULL, &pIWbemServices );

    if( FAILED(hr) || pIWbemServices == NULL )
        goto LCleanup;

    // Switch security level to IMPERSONATE. 
    CoSetProxyBlanket( pIWbemServices, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL, 
        RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE );                    

    hr = pIWbemServices->CreateInstanceEnum( bstrClassName, 0, NULL, &pEnumDevices ); 
    if( FAILED(hr) || pEnumDevices == NULL )
        goto LCleanup;

    // Loop over all devices
    for( ;; )
    {
        // Get 20 at a time
        hr = pEnumDevices->Next( 10000, 20, pDevices, &uReturned );
        if( FAILED(hr) )
            goto LCleanup;
        if( uReturned == 0 )
            break;

        for( iDevice=0; iDevice<uReturned; iDevice++ )
        {
            if (NULL == pDevices[iDevice])
                continue;

            // For each device, get its device ID
            hr = pDevices[iDevice]->Get( bstrDeviceID, 0L, &var, NULL, NULL );
            if( SUCCEEDED( hr ) && var.vt == VT_BSTR && var.bstrVal != NULL )
            {
                // Check if the device ID contains "IG_".  If it does, then it's an XInput device
                // This information can not be found from DirectInput 
                if( wcsstr( var.bstrVal, L"IG_" ) )
                {
                    // If it does, then get the VID/PID from var.bstrVal
                    DWORD dwPid = 0, dwVid = 0;
                    WCHAR* strVid = wcsstr( var.bstrVal, L"VID_" );
                    if( strVid && swscanf_s( strVid, L"VID_%4X", &dwVid ) != 1 )
                        dwVid = 0;
                    WCHAR* strPid = wcsstr( var.bstrVal, L"PID_" );
                    if( strPid && swscanf_s( strPid, L"PID_%4X", &dwPid ) != 1 )
                        dwPid = 0;

                    // Compare the VID/PID to the DInput device
                    DWORD dwVidPid = MAKELONG( dwVid, dwPid );
                    if (NULL == pGuidProductFromDirectInput)
                        goto LCleanup;
                    if( dwVidPid == pGuidProductFromDirectInput->Data1 )
                    {
                        bIsXinputDevice = true;
                        goto LCleanup;
                    }
                }
            }   
            LOGITECH_SAFE_RELEASE( pDevices[iDevice] );
        }
    }

LCleanup:
    if(bstrNamespace)
        SysFreeString(bstrNamespace);
    if(bstrDeviceID)
        SysFreeString(bstrDeviceID);
    if(bstrClassName)
        SysFreeString(bstrClassName);
    for( iDevice=0; iDevice<20; iDevice++ )
        LOGITECH_SAFE_RELEASE( pDevices[iDevice] );
    LOGITECH_SAFE_RELEASE( pEnumDevices );
    LOGITECH_SAFE_RELEASE( pIWbemLocator );
    LOGITECH_SAFE_RELEASE( pIWbemServices );

    if( bCleanupCOM )
        CoUninitialize();

    return bIsXinputDevice;
}

VOID LogitechControllerInput::Utils::LogiTrace(LPCTSTR lpszFormat, ...)
{
    va_list args;
    va_start(args, lpszFormat);

    int nBuf;
    TCHAR szBuffer[512];

    nBuf = _vsntprintf_s(szBuffer, _countof(szBuffer), sizeof(szBuffer) / sizeof(TCHAR), lpszFormat, args);

    // was there an error? was the expanded string too long?
    _ASSERT(nBuf >= 0);

    OutputDebugString(szBuffer);

    va_end(args);



    //va_list args;
    //va_start(args, strFormat);
    //nPos += _vsntprintf(pBuffer+nPos,nMaxSize,strFormat,args);
    //va_end(args);
    //// print the end of the line to buffer
    //_stprintf(pBuffer+nPos,_T("\r\n"));
}

BOOL LogitechControllerInput::Utils::IsEven(INT nbr)
{
    if (0 == nbr % 2)
    {
        return TRUE;
    }

    return FALSE;
}

LogitechControllerInput::STRING LogitechControllerInput::Utils::StringToUpper(LogitechControllerInput::STRING myString)
{
    for(unsigned int index_=0; index_< myString.length(); index_++)
    {
        myString[index_] = static_cast<TCHAR>(_totupper(myString[index_]));
    }

    return myString;
}

HRESULT LogitechControllerInput::Utils::GetUniqueIDFromDbcc_name(TCHAR* outputString, CONST TCHAR* inputString)
{
    STRING dbccName_(inputString);
    size_t beginning_ = dbccName_.find(_T("#"));
    _ASSERT(-1 != beginning_);
    beginning_ = dbccName_.find(_T("#"), beginning_ + 1);
    ++beginning_;
    size_t end_ = dbccName_.find(_T("#"), beginning_ + 1);
    _ASSERT(-1 != end_);
    _ASSERT(end_ > beginning_);
    if (-1 == end_ || end_ < beginning_)
        return E_FAIL;

    STRING outputString_ = dbccName_.substr(beginning_, end_ - beginning_);
    _tcscpy_s(outputString, MAX_PATH, outputString_.c_str());

    return S_OK;
}

VOID LogitechControllerInput::Utils::SetRecurringTimer(INT id, DWORD initialTickCounts, DWORD endTickCounts, DWORD intervals)
{
    INT idAlreadyUsed_ = -1;
    // check if ID not already taken
    for (UINT index_ = 0; index_ < m_recurringTimerData.size(); index_++)
    {
        if (m_recurringTimerData[index_].id == id)
        {
            idAlreadyUsed_ = index_;
            break;
        }
    }

    if (-1 != idAlreadyUsed_)
    {
        m_recurringTimerData[idAlreadyUsed_].initialTickCounts = initialTickCounts;
        m_recurringTimerData[idAlreadyUsed_].endTickCounts = endTickCounts;
        m_recurringTimerData[idAlreadyUsed_].intervals = intervals;
        m_recurringTimerData[idAlreadyUsed_].previousTickZone = -1;
    }
    else
    {
        RecurringTimerData data_;
        ZeroMemory(&data_, sizeof(data_));
        data_.id = id;
        data_.initialTickCounts = initialTickCounts;
        data_.endTickCounts = endTickCounts;
        data_.intervals = intervals;
        data_.previousTickZone = -1;

        m_recurringTimerData.push_back(data_);
    }
}

BOOL LogitechControllerInput::Utils::TimerTriggered(INT id)
{
    INT correspondingIndex_ = -1;

    for (UINT index_ = 0; index_ < m_recurringTimerData.size(); index_++)
    {
        if (m_recurringTimerData[index_].id == id)
        {
            correspondingIndex_ = index_;
            break;
        }
    }

    if (-1 == correspondingIndex_)
    {
        return FALSE;
    }

    DWORD initialTickCounts_ = m_recurringTimerData[correspondingIndex_].initialTickCounts;
    DWORD endTickCounts_ = m_recurringTimerData[correspondingIndex_].endTickCounts;
    DWORD intervals_ = m_recurringTimerData[correspondingIndex_].intervals;

    DWORD currentTicks_ = GetTickCount();

    _ASSERT(endTickCounts_ >= initialTickCounts_);

    if (currentTicks_ >= endTickCounts_
        || endTickCounts_ < initialTickCounts_
        || initialTickCounts_ > currentTicks_)
    {
        return FALSE;
    }    

    INT currentTickZone_ = static_cast<INT>(static_cast<FLOAT>(currentTicks_ - initialTickCounts_) / static_cast<FLOAT>(intervals_));

    if (m_recurringTimerData[correspondingIndex_].previousTickZone != currentTickZone_)
    {
        m_recurringTimerData[correspondingIndex_].previousTickZone = currentTickZone_;
        return TRUE;
    }


    return FALSE;
}

INT LogitechControllerInput::Utils::FindIG_Number(STRING deviceIDString)
{
    // Find IG_ number, if present
    size_t beginning_ = deviceIDString.find(_T("IG_"));
    if (-1 != beginning_)
    {
        beginning_ = beginning_ + 3;
        size_t end_ = deviceIDString.find(_T("\\"), beginning_);
        STRING numberString_ = deviceIDString.substr(beginning_, end_ - beginning_);

        INT number_ = _ttoi(numberString_.c_str());
        _ASSERT(number_ >= 0);

        return number_;
    }

    return -1;
}

LogitechControllerInput::STRING LogitechControllerInput::Utils::GetUniqueID(LogitechControllerInput::STRING deviceIDString)
{
    // Find unique ID
    size_t beginning_ = deviceIDString.find(_T("\\"));
    ++beginning_;
    beginning_ = deviceIDString.find(_T("\\"), beginning_);
    ++beginning_;
    return deviceIDString.substr(beginning_, deviceIDString.length() - beginning_ );
}

HRESULT LogitechControllerInput::Utils::GetDeviceIDStringFromSetupDI(STRING_VECTOR& deviceID, CONST DWORD vid, CONST DWORD pid)
{
    TCHAR vidString_[MAX_PATH] = {'\0'};
    INT ret_ = wsprintf( vidString_, TEXT("%.4x"), vid);

    TCHAR pidString_[MAX_PATH] = {'\0'};
    ret_ = wsprintf( pidString_, TEXT("%.4x"), pid);

    STRING searchString_ = _T("");
    searchString_.append(_T("HID\\VID_"));
    searchString_.append(vidString_);
    searchString_.append(_T("&PID_"));
    searchString_.append(pidString_);

    searchString_ = Utils::Instance()->StringToUpper(searchString_);

    HDEVINFO devInfo_ = SetupDiGetClassDevs(NULL, NULL, NULL, DIGCF_DEVICEINTERFACE | DIGCF_ALLCLASSES | DIGCF_PRESENT | DIGCF_PROFILE);
    if( INVALID_HANDLE_VALUE == devInfo_ )
    {
        /*switch(GetLastError())
        {
        case ERROR_INVALID_PARAMETER:
        LOGICONTROLLERTRACE(_T("ERROR SetupDiGetClassDevs: ERROR_INVALID_PARAMETER\n"));
        break;
        case ERROR_INVALID_FLAGS:
        LOGICONTROLLERTRACE(_T("ERROR SetupDiGetClassDevs: ERROR_INVALID_FLAGS\n"));
        break;
        }*/
        return E_FAIL;
    }

    SP_DEVINFO_DATA* devInfoData_ =
        (SP_DEVINFO_DATA*)HeapAlloc(GetProcessHeap(), 0, sizeof(SP_DEVINFO_DATA));
    if (NULL == devInfoData_)
        return E_FAIL;
    devInfoData_->cbSize = sizeof(SP_DEVINFO_DATA);

    for(INT ii = 0; SetupDiEnumDeviceInfo(devInfo_,ii,devInfoData_); ii++)
    {
        DWORD size_ = 0;
        TCHAR buf_[MAX_PATH];

        if ( !SetupDiGetDeviceInstanceId(devInfo_, devInfoData_, buf_, _countof(buf_), &size_) )
        {
            break;
        }

        STRING tempText_(buf_);

        //LOGICONTROLLERTRACE(_T("%s\n"), buf_);

        size_t beginning_ = tempText_.find(searchString_);
        if (-1 != beginning_)
        {
            deviceID.push_back(tempText_);
        }
    }

    if ( devInfoData_ ) HeapFree(GetProcessHeap(), 0, devInfoData_);
    SetupDiDestroyDeviceInfoList(devInfo_);

    return S_OK;

}

HRESULT LogitechControllerInput::Utils::GetVidPid(CONST STRING deviceIDString, DWORD &vid, DWORD &pid)
{
    // "HID\VID_046D&PID_C298\8&2A00AA53&A&0000"
    // VID
    size_t beginning_ = deviceIDString.find(_T("VID_"));

    if (-1 == beginning_)
    {
        return E_FAIL;
    }

    beginning_ = beginning_ + 4;

    STRING vidString_ = deviceIDString.substr(beginning_, 4);
    _ASSERT(4 == vidString_.size());
    if (4 != vidString_.size())
    {
        return E_FAIL;
    }

    vid = HexStringToInt(vidString_.c_str());

    // PID
    beginning_ = deviceIDString.find(_T("PID_"));

    if (-1 == beginning_)
    {
        return E_FAIL;
    }

    beginning_ = beginning_ + 4;

    STRING pidString_ = deviceIDString.substr(beginning_, 4);
    _ASSERT(4 == pidString_.size());
    if (4 != pidString_.size())
    {
        return E_FAIL;
    }

    pid = HexStringToInt(pidString_.c_str());

    return S_OK;
}

#ifdef _UNICODE
template <class T>
bool from_string(T& t, 
                 const std::wstring& s, 
                 std::ios_base& (*f)(std::ios_base&))
{
    std::wistringstream iss(s);
    return !(iss >> f >> t).fail();
}
#else
template <class T>
bool from_string(T& t, 
                 const std::string& s, 
                 std::ios_base& (*f)(std::ios_base&))
{
    std::stringstream iss(s);
    return !(iss >> f >> t).fail();
}
#endif

INT LogitechControllerInput::Utils::HexStringToInt(CONST TCHAR *value)
{
    int result_;

#ifdef _UNICODE
    if(from_string<int>(result_, std::wstring(value), std::hex))
#else
    if(from_string<int>(result_, std::string(value), std::hex))
#endif
    {
        return result_;
    }

    return 0;
}

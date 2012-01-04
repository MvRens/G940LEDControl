/*
The Logitech Controls Assignment SDK, including all accompanying 
documentation, is protected by intellectual property laws. All rights
not expressly granted by Logitech are reserved.
*/

#include "LogiControlsAssignmentUtils.h"

#define SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }

using namespace LogitechControlsAssignmentSDK;

FLOAT Utils::Combine(Control* control1, Control* control2, CONST BOOL reverseFlagIsSet)
{
    FLOAT reverseValue = 1.0f;

    if (NULL == control1 || NULL == control2)
        return 0.0f;

    if (reverseFlagIsSet)
        reverseValue = -1.0f;

    if (control1->GetRangeType() == control2->GetRangeType())
    {
        return (control1->GetValue() - control2->GetValue()) * reverseValue;
    }
    else if ((control1->GetRangeType() == LG_POSITIVE_RANGE && control2->GetRangeType() == LG_NEGATIVE_RANGE)
        || (control1->GetRangeType() == LG_NEGATIVE_RANGE && control2->GetRangeType() == LG_POSITIVE_RANGE))
    {
        return (control1->GetValue() + control2->GetValue()) * reverseValue;
    }
    else if ((control1->GetRangeType() == LG_FULL_RANGE && control2->GetRangeType() == LG_POSITIVE_RANGE)
        || (control1->GetRangeType() == LG_POSITIVE_RANGE && control2->GetRangeType() == LG_FULL_RANGE))
    {
        return (control1->GetValue() - control2->GetValue()) * reverseValue;
    }
    else if ((control1->GetRangeType() == LG_FULL_RANGE && control2->GetRangeType() == LG_NEGATIVE_RANGE)
        || (control1->GetRangeType() == LG_NEGATIVE_RANGE && control2->GetRangeType() == LG_FULL_RANGE))
    {
        return (control1->GetValue() + control2->GetValue()) * reverseValue;
    }

    return 0.0f;
}

FLOAT Utils::Abs(CONST FLOAT value)
{
    FLOAT value_ = value;

    if (value_ < 0.0f)
    {
        value_ = value_ * -1.0f;
    }

    return value_;
}

FLOAT Utils::GetNormalizedValue(CONST LONG value, LONG min, LONG max)
{
    FLOAT ret_ = ((static_cast<FLOAT>(value) - min) / ((max - min) / 2.0f)) - 1.0f;

    if (ret_ < AXES_RANGE_MIN_NORMALIZED)
        ret_ = AXES_RANGE_MIN_NORMALIZED;
    if (ret_ > AXES_RANGE_MAX_NORMALIZED)
        ret_ = AXES_RANGE_MAX_NORMALIZED;

    return ret_;
}

BOOL Utils::IsXInputDevice(CONST GUID* pGuidProductFromDirectInput)
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
                goto LCleanup;

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
                    if( dwVidPid == pGuidProductFromDirectInput->Data1 )
                    {
                        bIsXinputDevice = true;
                        goto LCleanup;
                    }
                }
            }   
            SAFE_RELEASE( pDevices[iDevice] );
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
        SAFE_RELEASE( pDevices[iDevice] );
    SAFE_RELEASE( pEnumDevices );
    SAFE_RELEASE( pIWbemLocator );
    SAFE_RELEASE( pIWbemServices );

    if( bCleanupCOM )
        CoUninitialize();

    return bIsXinputDevice;
}

VOID Utils::LogiTrace(LPCTSTR lpszFormat, ...)
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
}

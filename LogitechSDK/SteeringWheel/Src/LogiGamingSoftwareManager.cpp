#include "LogiGamingSoftwareManager.h"

#pragma comment(lib,"Version.lib")

using namespace LogitechSteeringWheel;

GamingSoftwareManager::GamingSoftwareManager()
{
    m_hWnd = NULL;
}

BOOL GamingSoftwareManager::IsEventMonitorRunning()
{
    m_hWnd = ::FindWindow(LGMSGPIPE_WINDOWCLASS, NULL);
    if (NULL != m_hWnd)
        return TRUE;

    return FALSE;
}

HRESULT GamingSoftwareManager::StartEventMonitor()
{
    // Get the location to the profiler exe
    TCHAR szBuffer[MAX_PATH];
    STARTUPINFO StartupInfo;
    PROCESS_INFORMATION ProcInfo;

    memset(&StartupInfo, 0, sizeof(StartupInfo));
    StartupInfo.cb = sizeof(StartupInfo);
    memset(&ProcInfo, 0, sizeof(ProcInfo));

    if (SUCCEEDED(BuildEmonCommandline(szBuffer, MAX_PATH, TRUE)))
    {
        BOOL bResult = ::CreateProcess(
            NULL,
            szBuffer,
            NULL,
            NULL,
            FALSE,
            NORMAL_PRIORITY_CLASS,
            NULL,
            NULL,
            &StartupInfo,
            &ProcInfo);

        if(!bResult)
        {
            // Free process and thread handle resource
            CloseHandle(ProcInfo.hProcess);
            CloseHandle(ProcInfo.hThread);
        }
        else
        {
            return S_OK;
        }
    }                   // this is the end

    return E_FAIL;
}

VOID GamingSoftwareManager::StopEventMonitor()
{
    HWND hWnd_ = ::FindWindow(LGMSGPIPE_WINDOWCLASS, NULL);
    if (NULL != hWnd_)
    {
        ::SendMessage(hWnd_, MENU_FASTEXIT, 0, 0);
        ::SendMessage(hWnd_, WM_CLOSE, 0, 0);
    }
}

HRESULT GamingSoftwareManager::GetWingmanSWVersion(WingmanSoftwareVersion& version)
{
    TCHAR eventMonitorPath_[MAX_PATH] = {'\0'};

    ZeroMemory(&version, sizeof(version));

    if (FAILED(GetEventMonitorPath(eventMonitorPath_, MAX_PATH)))
        return E_FAIL;

    WORD major;
    WORD minor;
    WORD build;
    WORD revision_ = 0;

    if (FAILED(GetAppVersion(eventMonitorPath_, &major, &minor, &build, &revision_)))
        return E_FAIL;

    version.major = major;
    version.minor = minor;
    version.build = build;

    return S_OK;
}

HRESULT GamingSoftwareManager::GetEventMonitorPath(LPTSTR szBuffer, UINT nMaxChars)
{
    DWORD type_ = 0;
    DWORD size_ = nMaxChars * sizeof(TCHAR);

    if (ERROR_SUCCESS != SHGetValue(REG_STORAGE, REG_KEY_WINGMAN, REG_KEY_WINGMAN_PROFILER, &type_, szBuffer, &size_))
    {
        return E_FAIL;
    }

    if (nMaxChars * sizeof(TCHAR) < size_)
    {
        return E_FAIL;
    }

    return S_OK;
}

HRESULT GamingSoftwareManager::BuildEmonCommandline(LPTSTR szBuffer, UINT nMaxChars, BOOL bNoUI)
{
    if(SUCCEEDED(GetEventMonitorPath(szBuffer, nMaxChars)))
    {
        // make sure the spaces are quoted
        PathQuoteSpaces(szBuffer);
        if(bNoUI)
        {
            _tcscat_s(szBuffer, nMaxChars, _T(" "));
            _tcscat_s(szBuffer, nMaxChars,  EVENTMONITOR_CMDLINE);
        }

        if (0 == _tcscmp(_T(""), szBuffer))
        {
            return E_FAIL;
        }

        return S_OK;
    }


    return E_FAIL;
}

HRESULT GamingSoftwareManager::GetAppVersion( LPTSTR LibName, WORD *MajorVersion, WORD *MinorVersion, WORD *BuildNumber, WORD *RevisionNumber )
{
    DWORD dwHandle, dwLen;
    UINT BufLen;
    LPTSTR lpData; 
    VS_FIXEDFILEINFO *pFileInfo;

    dwLen = GetFileVersionInfoSize(LibName, &dwHandle);

    if (!dwLen)
        return E_FAIL;

    lpData = (LPTSTR) malloc (dwLen);

    if (!lpData)
        return E_FAIL;

    if(!GetFileVersionInfo( LibName, dwHandle, dwLen, lpData))
    {
        free (lpData);
        return E_FAIL;
    }

    if(VerQueryValue( lpData, _T("\\"), (VOID**) &pFileInfo, (PUINT)&BufLen))
    {
        *MajorVersion = HIWORD(pFileInfo->dwFileVersionMS);
        *MinorVersion = LOWORD(pFileInfo->dwFileVersionMS);
        *BuildNumber = HIWORD(pFileInfo->dwFileVersionLS);
        *RevisionNumber = LOWORD(pFileInfo->dwFileVersionLS);
        free (lpData);
        return S_OK;
    }

    free (lpData);

    return E_FAIL;
}

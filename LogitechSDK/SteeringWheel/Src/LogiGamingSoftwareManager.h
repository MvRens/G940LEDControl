#ifndef LOGITECH_GAMING_SOFTWARE_MANAGER_H_INCLUDED_
#define LOGITECH_GAMING_SOFTWARE_MANAGER_H_INCLUDED_

#include <atlstr.h>

namespace LogitechSteeringWheel
{
    // Following 2 lines must be identical than Globals.h in Profiler.
    #define MENU_FASTEXIT               (WM_USER + 100 + 77)

    CONST LPTSTR REG_KEY_WINGMAN_PROFILER = _T("Profiler");
    CONST HKEY REG_STORAGE = HKEY_LOCAL_MACHINE;
    CONST LPTSTR REG_KEY_WINGMAN = _T("Software\\Logitech\\Gaming Software");
    CONST LPTSTR REG_KEY_WINGMAN_DRIVERVERSION = _T("DriverVer");
    CONST LPTSTR EVENTMONITOR_CMDLINE = _T("/noui /force");
    CONST LPTSTR LGMSGPIPE_WINDOWCLASS = _T("Logitech Wingman Internal Message Router");

    struct WingmanSoftwareVersion
    {
        WORD major;
        WORD minor;
        WORD build;
    };

    class GamingSoftwareManager
    {
    public:
        GamingSoftwareManager();

        BOOL IsEventMonitorRunning();
        HRESULT StartEventMonitor();
        VOID StopEventMonitor();
        HRESULT GetWingmanSWVersion(WingmanSoftwareVersion& version);

    private:
        HWND m_hWnd;
        HRESULT GetEventMonitorPath(LPTSTR szBuffer, UINT nMaxChars);
        HRESULT GetEnvironmentValue(LPCTSTR szValue, LPTSTR szBuffer, UINT nMaxChars);
        HRESULT BuildEmonCommandline(LPTSTR szBuffer, UINT nMaxChars, BOOL bNoUI);
        HRESULT GetAppVersion(LPTSTR LibName, WORD *MajorVersion, WORD *MinorVersion, WORD *BuildNumber, WORD *RevisionNumber);
    };
}

#endif // LOGITECH_GAMING_SOFTWARE_MANAGER_H_INCLUDED_

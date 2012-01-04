    #ifndef LOGI_CONTROLLER_PROPERTIES_H_INCLUDED_
#define LOGI_CONTROLLER_PROPERTIES_H_INCLUDED_

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>
#include "LogiGamingSoftwareManager.h"
#include <vector>

namespace LogitechSteeringWheel
{
    // If your game does not use any of the functions in this class, you
    // may set following value to FALSE to keep Logitech Gaming Software 
    // from getting started unnecessarily.
    CONST BOOL START_LOGITECH_SOFTWARE = TRUE;

    // Following values must not be changed
    /*****************************************************/
    CONST DWORD VERSION_NUMBER_PROPERTIES = 0x00000002;
    CONST DWORD VERSION_NUMBER_SHIFTER_MODE = 0x00000001;

    CONST DWORD ESCAPE_COMMAND_GATED_SHIFTER_MODE = 1;

    CONST INT JOY_CONTROL_PANEL_GET_PROPERTIES= (WM_USER + 100 + 78);
    CONST INT JOY_CONTROL_PANEL_SET_PROPERTIES = (WM_USER + 100 + 79);

    CONST INT LG_CONTROL_PANEL_PROPERTIES_OPERATING_RANGE_MIN = 40;
    CONST INT LG_CONTROL_PANEL_PROPERTIES_OPERATING_RANGE_MAX = 900;
    CONST INT LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MIN = 0;
    CONST INT LG_CONTROL_PANEL_PROPERTIES_ATTENUATION_MAX = 150;
    /*****************************************************/

    // Following defines and structs need to be identical than in Globals.h in Wingman CGameStore.h
    typedef enum
    {
        PROPERTY_ALL,
        PROPERTY_FORCE_ENABLE,             // enable (1) or disable (0) forces
        PROPERTY_OVERALL_GAIN,             // overall gain, 0-10000
        PROPERTY_SPRING_GAIN,              // spring specific gain. 0-10000
        PROPERTY_DAMPER_GAIN,              // damper specific gain. 0-10000
        PROPERTY_COMBINED_PEDALS,          // report combined (1) or separate (0) pedals on wheels
        PROPERTY_WHEEL_RANGE,              // [Cheetah/Hobbes] range of motion (influences soft-stop/multiturn)
        PROPERTY_NUMBER
    } ControllerSetProperty;

    struct ControllerPropertiesData
    {
        BOOL forceEnable;
        INT overallGain;
        INT springGain;
        INT damperGain;
        BOOL defaultSpringEnabled;
        INT defaultSpringGain;
        BOOL combinePedals;
        INT wheelRange;
        BOOL gameSettingsEnabled;
        BOOL allowGameSettings;
    };

    struct ControllerPropertiesGetData
    {
        DWORD size;
        DWORD versionNbr;
        DWORD productID;
        ControllerPropertiesData properties;
    };

    struct ControllerPropertiesSetData
    {
        DWORD size;
        DWORD versionNbr;
        DWORD productID;
        ControllerSetProperty propertyToSet;
        ControllerPropertiesData properties;
    };

    struct ShifterData
    {
        DWORD size;
        DWORD versionNbr;
        INT isGated; // -1 = uninitialized, 0 = Nope, 1 = Yesch
    };

    class ControllerProperties
    {
    public:
        ControllerProperties(HWND hWnd);
        ~ControllerProperties();

        HRESULT SetPreferred(CONST ControllerPropertiesData properties);
        //VOID SetPreferred(CONST DWORD controllerPID, CONST ControllerSetProperty deviceSetProperty, CONST INT value);
        BOOL GetCurrent(CONST DWORD controllerPID, ControllerPropertiesData& properties);

        INT GetShifterMode(CONST LPDIRECTINPUTDEVICE8 device);

        VOID GetDefault(ControllerPropertiesData& properties);

        HRESULT Update(CONST std::vector<DWORD> currentlyConnectedPIDs);

    private:
        ControllerPropertiesData m_defaultControllerProperties;
        ControllerPropertiesData m_preferredControllerProperties;
        std::vector<DWORD> m_previouslyConnectedPIDs;
        HWND m_gameHWnd;
        GamingSoftwareManager m_gamingSoftwareManager;
        BOOL m_hadToStartEMon;
        WingmanSoftwareVersion m_wingmanVersion;
        BOOL m_currentVersionSupportsGetSetProperties;

        BOOL ControllerPropertiesAreEqual(CONST ControllerPropertiesData properties1, CONST ControllerPropertiesData properties2, CONST BOOL ignoreWheelRange = FALSE);
        VOID SetDefaults();
        HRESULT GetASync(CONST DWORD controllerPID);
        BOOL IsMultiturnCapable(CONST DWORD controllerPID);
        VOID SendSetMessage(CONST DWORD controllerPID, CONST ControllerPropertiesData properties);
    };
}

#endif // LOGI_CONTROLLER_PROPERTIES_H_INCLUDED_

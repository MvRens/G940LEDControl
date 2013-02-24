unit ConfigConversion;

interface
uses
  Profile,
  Settings;

  { Version 0.x: registry -> 1.x: XML }
  function ConvertProfile0To1: TProfile;
  function ConvertSettings0To1: TSettings;


implementation
uses
  System.SysUtils,
  Winapi.Windows,

  X2UtPersistIntf,
  X2UtPersistRegistry,

  FSXResources,
  LEDColorIntf,
  StaticResources;


const
  V0_FUNCTION_NONE = 0;
  V0_FUNCTION_OFF = 1;
  V0_FUNCTION_RED = 2;
  V0_FUNCTION_AMBER = 3;
  V0_FUNCTION_GREEN = 4;
  V0_FUNCTIONPROVIDER_OFFSET = V0_FUNCTION_GREEN;


  V0_FUNCTIONFSX_GEAR = V0_FUNCTIONPROVIDER_OFFSET + 1;
  V0_FUNCTIONFSX_LANDINGLIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 2;
  V0_FUNCTIONFSX_INSTRUMENTLIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 3;
  V0_FUNCTIONFSX_PARKINGBRAKE = V0_FUNCTIONPROVIDER_OFFSET + 4;
  V0_FUNCTIONFSX_ENGINE = V0_FUNCTIONPROVIDER_OFFSET + 5;

  V0_FUNCTIONFSX_EXITDOOR = V0_FUNCTIONPROVIDER_OFFSET + 6;
  V0_FUNCTIONFSX_STROBELIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 7;
  V0_FUNCTIONFSX_NAVLIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 8;
  V0_FUNCTIONFSX_BEACONLIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 9;
  V0_FUNCTIONFSX_FLAPS = V0_FUNCTIONPROVIDER_OFFSET + 10;
  V0_FUNCTIONFSX_BATTERYMASTER = V0_FUNCTIONPROVIDER_OFFSET + 11;
  V0_FUNCTIONFSX_AVIONICSMASTER = V0_FUNCTIONPROVIDER_OFFSET + 12;

  V0_FUNCTIONFSX_SPOILERS = V0_FUNCTIONPROVIDER_OFFSET + 13;

  V0_FUNCTIONFSX_PRESSURIZATIONDUMPSWITCH = V0_FUNCTIONPROVIDER_OFFSET + 14;
  V0_FUNCTIONFSX_ENGINEANTIICE = V0_FUNCTIONPROVIDER_OFFSET + 15;
  V0_FUNCTIONFSX_AUTOPILOT = V0_FUNCTIONPROVIDER_OFFSET + 16;
  V0_FUNCTIONFSX_FUELPUMP = V0_FUNCTIONPROVIDER_OFFSET + 17;

  V0_FUNCTIONFSX_TAILHOOK = V0_FUNCTIONPROVIDER_OFFSET + 18;

  V0_FUNCTIONFSX_AUTOPILOT_AMBER = V0_FUNCTIONPROVIDER_OFFSET + 19;
  V0_FUNCTIONFSX_AUTOPILOT_HEADING = V0_FUNCTIONPROVIDER_OFFSET + 20;
  V0_FUNCTIONFSX_AUTOPILOT_APPROACH = V0_FUNCTIONPROVIDER_OFFSET + 21;
  V0_FUNCTIONFSX_AUTOPILOT_BACKCOURSE = V0_FUNCTIONPROVIDER_OFFSET + 22;
  V0_FUNCTIONFSX_AUTOPILOT_ALTITUDE = V0_FUNCTIONPROVIDER_OFFSET + 23;
  V0_FUNCTIONFSX_AUTOPILOT_NAV = V0_FUNCTIONPROVIDER_OFFSET + 24;

  V0_FUNCTIONFSX_TAXILIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 25;
  V0_FUNCTIONFSX_RECOGNITIONLIGHTS = V0_FUNCTIONPROVIDER_OFFSET + 26;

  V0_FUNCTIONFSX_DEICE = V0_FUNCTIONPROVIDER_OFFSET + 27;



procedure ConvertProfileFunction0To1(AOldFunction: Integer; AButton: TProfileButton);

  procedure SetButton(const AProviderUID, AFunctionUID: string);
  begin
    AButton.ProviderUID := AProviderUID;
    AButton.FunctionUID := AFunctionUID;
  end;


begin
  { Default states are handled by the specific functions }
  case AOldFunction of
    { Static }
    V0_FUNCTION_OFF:                            SetButton(StaticProviderUID, StaticFunctionUID[lcOff]);
    V0_FUNCTION_RED:                            SetButton(StaticProviderUID, StaticFunctionUID[lcRed]);
    V0_FUNCTION_AMBER:                          SetButton(StaticProviderUID, StaticFunctionUID[lcAmber]);
    V0_FUNCTION_GREEN:                          SetButton(StaticProviderUID, StaticFunctionUID[lcGreen]);

    { FSX }
    V0_FUNCTIONFSX_GEAR:                        SetButton(FSXProviderUID, FSXFunctionUIDGear);
    V0_FUNCTIONFSX_LANDINGLIGHTS:               SetButton(FSXProviderUID, FSXFunctionUIDLandingLights);
    V0_FUNCTIONFSX_INSTRUMENTLIGHTS:            SetButton(FSXProviderUID, FSXFunctionUIDInstrumentLights);
    V0_FUNCTIONFSX_PARKINGBRAKE:                SetButton(FSXProviderUID, FSXFunctionUIDParkingBrake);
    V0_FUNCTIONFSX_ENGINE:                      SetButton(FSXProviderUID, FSXFunctionUIDEngine);

    V0_FUNCTIONFSX_EXITDOOR:                    SetButton(FSXProviderUID, FSXFunctionUIDExitDoor);
    V0_FUNCTIONFSX_STROBELIGHTS:                SetButton(FSXProviderUID, FSXFunctionUIDStrobeLights);
    V0_FUNCTIONFSX_NAVLIGHTS:                   SetButton(FSXProviderUID, FSXFunctionUIDNavLights);
    V0_FUNCTIONFSX_BEACONLIGHTS:                SetButton(FSXProviderUID, FSXFunctionUIDBeaconLights);
    V0_FUNCTIONFSX_FLAPS:                       SetButton(FSXProviderUID, FSXFunctionUIDFlaps);
    V0_FUNCTIONFSX_BATTERYMASTER:               SetButton(FSXProviderUID, FSXFunctionUIDBatteryMaster);
    V0_FUNCTIONFSX_AVIONICSMASTER:              SetButton(FSXProviderUID, FSXFunctionUIDAvionicsMaster);
    V0_FUNCTIONFSX_SPOILERS:                    SetButton(FSXProviderUID, FSXFunctionUIDSpoilers);
    V0_FUNCTIONFSX_PRESSURIZATIONDUMPSWITCH:    SetButton(FSXProviderUID, FSXFunctionUIDPressDumpSwitch);
    V0_FUNCTIONFSX_ENGINEANTIICE:               SetButton(FSXProviderUID, FSXFunctionUIDEngineAntiIce);
    V0_FUNCTIONFSX_AUTOPILOT:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilot);
        AButton.SetStateColor(FSXStateUIDOn, lcGreen);
        AButton.SetStateColor(FSXStateUIDOff, lcRed);
      end;

    V0_FUNCTIONFSX_TAILHOOK:                    SetButton(FSXProviderUID, FSXFunctionUIDTailHook);
    V0_FUNCTIONFSX_AUTOPILOT_AMBER:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilot);
        AButton.SetStateColor(FSXStateUIDOn, lcAmber);
        AButton.SetStateColor(FSXStateUIDOff, lcOff);
      end;

    V0_FUNCTIONFSX_AUTOPILOT_HEADING:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilotHeading);
        AButton.SetStateColor(FSXStateUIDOn, lcAmber);
        AButton.SetStateColor(FSXStateUIDOff, lcOff);
      end;

    V0_FUNCTIONFSX_AUTOPILOT_APPROACH:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilotApproach);
        AButton.SetStateColor(FSXStateUIDOn, lcAmber);
        AButton.SetStateColor(FSXStateUIDOff, lcOff);
      end;

    V0_FUNCTIONFSX_AUTOPILOT_BACKCOURSE:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilotBackcourse);
        AButton.SetStateColor(FSXStateUIDOn, lcAmber);
        AButton.SetStateColor(FSXStateUIDOff, lcOff);
      end;

    V0_FUNCTIONFSX_AUTOPILOT_ALTITUDE:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilotAltitude);
        AButton.SetStateColor(FSXStateUIDOn, lcAmber);
        AButton.SetStateColor(FSXStateUIDOff, lcOff);
      end;

    V0_FUNCTIONFSX_AUTOPILOT_NAV:
      begin
        { The new default is Green / Off }
        SetButton(FSXProviderUID, FSXFunctionUIDAutoPilotNav);
        AButton.SetStateColor(FSXStateUIDOn, lcAmber);
        AButton.SetStateColor(FSXStateUIDOff, lcOff);
      end;

    V0_FUNCTIONFSX_TAXILIGHTS:                  SetButton(FSXProviderUID, FSXFunctionUIDTaxiLights);
    V0_FUNCTIONFSX_RECOGNITIONLIGHTS:           SetButton(FSXProviderUID, FSXFunctionUIDRecognitionLights);
    V0_FUNCTIONFSX_DEICE:                       SetButton(FSXProviderUID, FSXFunctionUIDDeIce);
  end;
end;


function ConvertProfile0To1: TProfile;
const
  KEY_SETTINGS = '\Software\X2Software\G940LEDControl\';
  SECTION_DEFAULTPROFILE = 'DefaultProfile';
  SECTION_FSX = 'FSX';

var
  registryReader: TX2UtPersistRegistry;
  reader: IX2PersistReader;
  buttonIndex: Integer;
  value: Integer;

begin
  Result := nil;

  registryReader := TX2UtPersistRegistry.Create;
  try
    registryReader.RootKey := HKEY_CURRENT_USER;
    registryReader.Key := KEY_SETTINGS;

    reader := registryReader.CreateReader;

    if reader.BeginSection(SECTION_DEFAULTPROFILE) then
    try
      if reader.BeginSection(SECTION_FSX) then
      try
        for buttonIndex := 0 to 7 do
        begin
          if reader.ReadInteger('Function' + IntToStr(buttonIndex), value) then
          begin
            if not Assigned(Result) then
              Result := TProfile.Create;

            ConvertProfileFunction0To1(value, Result.Buttons[buttonIndex]);
          end;
        end;
      finally
        reader.EndSection;
      end;
    finally
      reader.EndSection;
    end;
  finally
    FreeAndNil(registryReader);
  end;
end;


function ConvertSettings0To1: TSettings;
const
  KEY_SETTINGS = '\Software\X2Software\G940LEDControl\';
  SECTION_SETTINGS = 'Settings';

var
  registryReader: TX2UtPersistRegistry;
  reader: IX2PersistReader;
  value: Boolean;

begin
  Result := nil;

  registryReader := TX2UtPersistRegistry.Create;
  try
    registryReader.RootKey := HKEY_CURRENT_USER;
    registryReader.Key := KEY_SETTINGS;

    reader := registryReader.CreateReader;

    if reader.BeginSection(SECTION_SETTINGS) then
    try
      if reader.ReadBoolean('CheckUpdates', value) then
      begin
        Result := TSettings.Create;
        Result.CheckUpdates := value;
      end;
    finally
      reader.EndSection;
    end;
  finally
    FreeAndNil(registryReader);
  end;
end;

end.

unit ConfigConversion;

interface
uses
  Profile;

  { Version 0.x: registry -> 1.x: XML }
  function ConvertProfile0To1: TProfile;


implementation
uses
  System.SysUtils,
  Winapi.Windows,

  X2UtPersistIntf,
  X2UtPersistRegistry,

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
  V0_FUNCTIONFSX_CARBHEAT = V0_FUNCTIONPROVIDER_OFFSET + 15;
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

  // TODO 27 (de-ice)



procedure ConvertProfileFunction0To1(AOldFunction: Integer; AButton: TProfileButton);

  procedure SetButton(const AProviderUID, AFunctionUID: string);
  begin
    AButton.ProviderUID := AProviderUID;
    AButton.FunctionUID := AFunctionUID;
  end;


begin
  case AOldFunction of
    { Static }
    V0_FUNCTION_OFF:    SetButton(StaticProviderUID, StaticFunctionUID[lcOff]);
    V0_FUNCTION_RED:    SetButton(StaticProviderUID, StaticFunctionUID[lcRed]);
    V0_FUNCTION_AMBER:  SetButton(StaticProviderUID, StaticFunctionUID[lcAmber]);
    V0_FUNCTION_GREEN:  SetButton(StaticProviderUID, StaticFunctionUID[lcGreen]);

    { FSX }
    {
    V0_FUNCTIONFSX_GEAR:
    V0_FUNCTIONFSX_LANDINGLIGHTS:
    V0_FUNCTIONFSX_INSTRUMENTLIGHTS:
    V0_FUNCTIONFSX_PARKINGBRAKE:
    V0_FUNCTIONFSX_ENGINE:

    V0_FUNCTIONFSX_EXITDOOR:
    V0_FUNCTIONFSX_STROBELIGHTS:
    V0_FUNCTIONFSX_NAVLIGHTS:
    V0_FUNCTIONFSX_BEACONLIGHTS:
    V0_FUNCTIONFSX_FLAPS:
    V0_FUNCTIONFSX_BATTERYMASTER:
    V0_FUNCTIONFSX_AVIONICSMASTER:
    V0_FUNCTIONFSX_SPOILERS:
    V0_FUNCTIONFSX_PRESSURIZATIONDUMPSWITCH:
    V0_FUNCTIONFSX_CARBHEAT:
    V0_FUNCTIONFSX_AUTOPILOT:
    V0_FUNCTIONFSX_FUELPUMP:
    V0_FUNCTIONFSX_TAILHOOK:
    V0_FUNCTIONFSX_AUTOPILOT_AMBER:
    V0_FUNCTIONFSX_AUTOPILOT_HEADING:
    V0_FUNCTIONFSX_AUTOPILOT_APPROACH:
    V0_FUNCTIONFSX_AUTOPILOT_BACKCOURSE:
    V0_FUNCTIONFSX_AUTOPILOT_ALTITUDE:
    V0_FUNCTIONFSX_AUTOPILOT_NAV:
    V0_FUNCTIONFSX_TAXILIGHTS:
    V0_FUNCTIONFSX_RECOGNITIONLIGHTS:
    }
  else
    SetButton(StaticProviderUID, StaticFunctionUID[lcGreen]);
  end;
end;


function ConvertProfile0To1: TProfile;
const
  KEY_SETTINGS = '\Software\X2Software\G940LEDControl\';
  SECTION_DEFAULTPROFILE = 'DefaultProfile';
  SECTION_FSX = 'FSX';
  SECTION_SETTINGS = 'Settings';

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

    // TODO auto update settings
    //ReadAutoUpdate(reader);
  finally
    FreeAndNil(registryReader);
  end;
end;

end.

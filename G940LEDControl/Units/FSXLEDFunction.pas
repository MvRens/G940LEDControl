unit FSXLEDFunction;

interface
uses
  FSXLEDFunctionProvider,
  LEDFunction,
  LEDFunctionIntf;


type
  TCustomFSXOnOffFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
  end;

  TCustomFSXInvertedOnOffFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
  end;

  { Systems }
  TCustomFSXSystemsFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
  end;

  TFSXBatteryMasterFunction = class(TCustomFSXOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXDeIceFunction = class(TCustomFSXInvertedOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXExitDoorFunction = class(TCustomFSXSystemsFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXGearFunction = class(TCustomFSXSystemsFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXParkingBrakeFunction = class(TCustomFSXInvertedOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXPressDumpSwitchFunction = class(TCustomFSXInvertedOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXTailHookFunction = class(TCustomFSXSystemsFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { Engines }
  TFSXEngineAntiIceFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXEngineFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { Control surfaces }
  TFSXFlapsFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXSpoilersFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { Lights }
  TCustomFSXLightFunction = class(TCustomFSXOnOffFunction)
  protected
    function GetCategoryName: string; override;

    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): TCustomLEDFunctionWorker; override;
  protected
    function GetLightMask: Integer; virtual; abstract;
  end;

  TFSXLandingLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXInstrumentLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXBeaconLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXNavLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXStrobeLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXTaxiLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXRecognitionLightsFunction = class(TCustomFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXAllLightsFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { Autopilot }
  TCustomFSXAutoPilotFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetCategoryName: string; override;
  end;

  TFSXAutoPilotFunction = class(TCustomFSXAutoPilotFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXAutoPilotHeadingFunction = class(TCustomFSXAutoPilotFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXAutoPilotApproachFunction = class(TCustomFSXAutoPilotFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXAutoPilotBackcourseFunction = class(TCustomFSXAutoPilotFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXAutoPilotAltitudeFunction = class(TCustomFSXAutoPilotFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXAutoPilotNavFunction = class(TCustomFSXAutoPilotFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { Radios }
  TFSXAvionicsMasterFunction = class(TCustomFSXOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


implementation
uses
  FSXLEDFunctionWorker,
  FSXResources,
  FSXSimConnectIntf,
  LEDColorIntf,
  LEDState;


{ TFSXOnOffFunction }
procedure TCustomFSXOnOffFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDOn,   FSXStateDisplayNameOn,    lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDOff,  FSXStateDisplayNameOff,   lcRed));
end;


{ TCustomFSXInvertedOnOffFunction }
procedure TCustomFSXInvertedOnOffFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDOn,   FSXStateDisplayNameOn,    lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDOff,  FSXStateDisplayNameOff,   lcGreen));
end;


{ TCustomFSXSystemsFunction }
function TCustomFSXSystemsFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;


{ TFSXBatteryMasterFunction }
function TFSXBatteryMasterFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;


function TFSXBatteryMasterFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXBatteryMasterFunctionWorker;
end;


{ TFSXDeIceFunction }
function TFSXDeIceFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;


function TFSXDeIceFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXDeIceFunctionWorker;
end;


{ TFSXExitDoorFunction }
procedure TFSXExitDoorFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDExitDoorClosed,   FSXStateDisplayNameExitDoorClosed,  lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDExitDoorBetween,  FSXStateDisplayNameExitDoorBetween, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDExitDoorOpen,     FSXStateDisplayNameExitDoorOpen,    lcRed));
end;


function TFSXExitDoorFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXExitDoorFunctionWorker;
end;


{ TFSXGearFunction }
procedure TFSXGearFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDGearNotRetractable, FSXStateDisplayNameGearNotRetractable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDGearRetracted,      FSXStateDisplayNameGearRetracted,       lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDGearBetween,        FSXStateDisplayNameGearBetween,         lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDGearExtended,       FSXStateDisplayNameGearExtended,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDGearSpeedExceeded,  FSXStateDisplayNameGearSpeedExceeded,   lcFlashingAmberNormal));
  RegisterState(TLEDState.Create(FSXStateUIDGearDamageBySpeed,  FSXStateDisplayNameGearDamageBySpeed,   lcFlashingRedFast));
end;


function TFSXGearFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXGearFunctionWorker;
end;


{ TFSXParkingBrakeFunction }
function TFSXParkingBrakeFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;

function TFSXParkingBrakeFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXParkingBrakeFunctionWorker;
end;


{ TFSXPressDumpSwitchFunction }
function TFSXPressDumpSwitchFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;

function TFSXPressDumpSwitchFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXPressDumpSwitchFunctionWorker;
end;


{ TFSXTailHookFunction }
procedure TFSXTailHookFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDTailHookRetracted,  FSXStateDisplayNameTailHookRetracted, lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDTailHookBetween,    FSXStateDisplayNameTailHookBetween,   lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDTailHookExtended,   FSXStateDisplayNameTailHookExtended,  lcRed));
end;


function TFSXTailHookFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXTailHookFunctionWorker;
end;


{ TFSXEngineAntiIceFunction }
function TFSXEngineAntiIceFunction.GetCategoryName: string;
begin
  Result := FSXCategoryEngines;
end;


procedure TFSXEngineAntiIceFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDEngineAntiIceNoEngines, FSXStateDisplayNameEngineAntiIceNoEngines,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAntiIceAll,       FSXStateDisplayNameEngineAntiIceAll,        lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAntiIcePartial,   FSXStateDisplayNameEngineAntiIcePartial,    lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAntiIceNone,      FSXStateDisplayNameEngineAntiIceNone,       lcGreen));
end;


function TFSXEngineAntiIceFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXEngineAntiIceFunctionWorker;
end;


{ TFSXEngineFunction }
function TFSXEngineFunction.GetCategoryName: string;
begin
  Result := FSXCategoryEngines;
end;


procedure TFSXEngineFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDEngineNoEngines,        FSXStateDisplayNameEngineNoEngines,         lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAllRunning,       FSXStateDisplayNameEngineAllRunning,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDEnginePartiallyRunning, FSXStateDisplayNameEnginePartiallyRunning,  lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAllOff,           FSXStateDisplayNameEngineAllOff,            lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDEngineFailed,           FSXStateDisplayNameEngineFailed,            lcFlashingRedNormal));
  RegisterState(TLEDState.Create(FSXStateUIDEngineOnFire,           FSXStateDisplayNameEngineOnFire,            lcFlashingRedFast));
end;


function TFSXEngineFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXEngineFunctionWorker;
end;


{ TFSXFlapsFunction }
function TFSXFlapsFunction.GetCategoryName: string;
begin
  Result := FSXCategoryControlSurfaces;
end;


procedure TFSXFlapsFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDFlapsNotAvailable,  FSXStateDisplayNameFlapsNotAvailable,   lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsRetracted,     FSXStateDisplayNameFlapsRetracted,      lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsBetween,       FSXStateDisplayNameFlapsBetween,        lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsExtended,      FSXStateDisplayNameFlapsExtended,       lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsSpeedExceeded, FSXStateDisplayNameFlapsSpeedExceeded,  lcFlashingAmberNormal));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsDamageBySpeed, FSXStateDisplayNameFlapsDamageBySpeed,  lcFlashingRedFast));
end;


function TFSXFlapsFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXFlapsFunctionWorker;
end;


{ TFSXSpoilersFunction }
function TFSXSpoilersFunction.GetCategoryName: string;
begin
  Result := FSXCategoryControlSurfaces;
end;


procedure TFSXSpoilersFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersNotAvailable, FSXStateDisplayNameSpoilersNotAvailable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersRetracted,    FSXStateDisplayNameSpoilersRetracted,     lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersBetween,      FSXStateDisplayNameSpoilersBetween,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersExtended,     FSXStateDisplayNameSpoilersExtended,      lcRed));
end;


function TFSXSpoilersFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXSpoilersFunctionWorker;
end;


{ TFSXLightFunction }
function TCustomFSXLightFunction.GetCategoryName: string;
begin
  Result := FSXCategoryLights;
end;


function TCustomFSXLightFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXLightStatesFunctionWorker;
end;


function TCustomFSXLightFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string): TCustomLEDFunctionWorker;
begin
  Result := inherited DoCreateWorker(ASettings, APreviousState);
  (Result as TFSXLightStatesFunctionWorker).StateMask := GetLightMask;
end;


{ TFSXLandingLightsFunction }
function TFSXLandingLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_LANDING;
end;


{ TFSXInstrumentLightsFunction }
function TFSXInstrumentLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_PANEL;
end;


{ TFSXBeaconLightsFunction }
function TFSXBeaconLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_BEACON;
end;


{ TFSXNavLightsFunction }
function TFSXNavLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_NAV;
end;


{ TFSXStrobeLightsFunction }
function TFSXStrobeLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_STROBE;
end;


{ TFSXTaxiLightsFunction }
function TFSXTaxiLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_TAXI;
end;


{ TFSXRecognitionLightsFunction }
function TFSXRecognitionLightsFunction.GetLightMask: Integer;
begin
  Result := FSX_LIGHTON_RECOGNITION;
end;


{ TFSXAllLightsFunction }
procedure TFSXAllLightsFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDOn,       FSXStateDisplayNameOn,      lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDPartial,  FSXStateDisplayNamePartial, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDOff,      FSXStateDisplayNameOff,     lcRed));
end;


function TFSXAllLightsFunction.GetCategoryName: string;
begin
  Result := FSXCategoryLights;
end;


function TFSXAllLightsFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAllLightsFunctionWorker;
end;


{ TCustomFSXAutoPilotFunction }
function TCustomFSXAutoPilotFunction.GetCategoryName: string;
begin
  Result := FSXCategoryAutoPilot;
end;


procedure TCustomFSXAutoPilotFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDAutoPilotNotAvailable,  FSXStateDisplayNameAutoPilotNotAvailable, lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDOn,                     FSXStateDisplayNameOn,                    lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDOff,                    FSXStateDisplayNameOff,                   lcOff));
end;


{ TFSXAutoPilotFunction }
function TFSXAutoPilotFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoPilotFunctionWorker;
end;


{ TFSXAutoPilotHeadingFunction }
function TFSXAutoPilotHeadingFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoPilotHeadingFunctionWorker;
end;


{ TFSXAutoPilotApproachFunction }
function TFSXAutoPilotApproachFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoPilotApproachFunctionWorker;
end;


{ TFSXAutoPilotBackcourseFunction }
function TFSXAutoPilotBackcourseFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoPilotBackcourseFunctionWorker;
end;


{ TFSXAutoPilotAltitudeFunction }
function TFSXAutoPilotAltitudeFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoPilotAltitudeFunctionWorker;
end;


{ TFSXAutoPilotNavFunction }
function TFSXAutoPilotNavFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoPilotNavFunctionWorker;
end;


{ TFSXAvionicsMasterFunction }
function TFSXAvionicsMasterFunction.GetCategoryName: string;
begin
  Result := FSXCategoryRadios;
end;


function TFSXAvionicsMasterFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAvionicsMasterFunctionWorker;
end;

end.

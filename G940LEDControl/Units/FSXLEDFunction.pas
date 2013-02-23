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


  { Misc }
  TFSXEngineFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXGearFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXParkingBrakeFunction = class(TCustomFSXOnOffFunction)
  protected
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXExitDoorFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXTailHookFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXFlapsFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXSpoilersFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXBatteryMasterFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXAvionicsMasterFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXPressDumpSwitchFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXEngineAntiIceFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXFuelPumpFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXDeIceFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;


  { Lights }
  TCustomFSXLightFunction = class(TCustomFSXOnOffFunction)
  protected
    function GetCategoryName: string; override;

    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker; override;
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


  { Autopilot }
  TCustomFSXAutoPilotFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
  end;

  TFSXAutoPilotFunction = class(TCustomFSXAutoPilotFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXAutoPilotHeadingFunction = class(TCustomFSXAutoPilotFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXAutoPilotApproachFunction = class(TCustomFSXAutoPilotFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXAutoPilotBackcourseFunction = class(TCustomFSXAutoPilotFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXAutoPilotAltitudeFunction = class(TCustomFSXAutoPilotFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
  end;

  TFSXAutoPilotNavFunction = class(TCustomFSXAutoPilotFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
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


{ TFSXEngineFunction }
procedure TFSXEngineFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDEngineNoEngines,        FSXStateDisplayNameEngineNoEngines,         lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAllRunning,       FSXStateDisplayNameEngineAllRunning,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDEnginePartiallyRunning, FSXStateDisplayNameEnginePartiallyRunning,  lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDEngineAllOff,           FSXStateDisplayNameEngineAllOff,            lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDEngineFailed,           FSXStateDisplayNameEngineFailed,            lcFlashingRedNormal));
  RegisterState(TLEDState.Create(FSXStateUIDEngineOnFire,           FSXStateDisplayNameEngineOnFire,            lcFlashingRedFast));
end;


function TFSXEngineFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXEngineFunctionWorker;
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


function TFSXGearFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXGearFunctionWorker;
end;


{ TFSXParkingBrakeFunction }
function TFSXParkingBrakeFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXParkingBrakeFunctionWorker;
end;


{ TFSXExitDoorFunction }
procedure TFSXExitDoorFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDExitDoorClosed,   FSXStateDisplayNameExitDoorClosed,  lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDExitDoorBetween,  FSXStateDisplayNameExitDoorBetween, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDExitDoorOpen,     FSXStateDisplayNameExitDoorOpen,    lcRed));
end;


function TFSXExitDoorFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXExitDoorFunctionWorker;
end;


{ TFSXTailHookFunction }
procedure TFSXTailHookFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDTailHookRetracted,  FSXStateDisplayNameTailHookRetracted, lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDTailHookBetween,    FSXStateDisplayNameTailHookBetween,   lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDTailHookExtended,   FSXStateDisplayNameTailHookExtended,  lcRed));
end;


function TFSXTailHookFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXTailHookFunctionWorker;
end;


{ TFSXFlapsFunction }
procedure TFSXFlapsFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDFlapsNotAvailable,  FSXStateDisplayNameFlapsNotAvailable, lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsRetracted,     FSXStateDisplayNameFlapsRetracted,    lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsBetween,       FSXStateDisplayNameFlapsBetween,      lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsExtended,      FSXStateDisplayNameFlapsExtended,     lcRed));
end;


function TFSXFlapsFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXFlapsFunctionWorker;
end;


{ TFSXSpoilersFunction }
procedure TFSXSpoilersFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersNotAvailable, FSXStateDisplayNameSpoilersNotAvailable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersRetracted,    FSXStateDisplayNameSpoilersRetracted,     lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersBetween,      FSXStateDisplayNameSpoilersBetween,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersExtended,     FSXStateDisplayNameSpoilersExtended,      lcRed));
end;


function TFSXSpoilersFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXSpoilersFunctionWorker;
end;


{ TFSXBatteryMasterFunction }
procedure TFSXBatteryMasterFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXBatteryMasterFunction.RegisterStates
end;


function TFSXBatteryMasterFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXBatteryMasterFunctionWorker;
end;


{ TFSXAvionicsMasterFunction }
procedure TFSXAvionicsMasterFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAvionicsMasterFunction.RegisterStates
end;


function TFSXAvionicsMasterFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAvionicsMasterFunctionWorker;
end;


{ TFSXPressDumpSwitchFunction }
procedure TFSXPressDumpSwitchFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXPressDumpSwitchFunction.RegisterStates
end;


function TFSXPressDumpSwitchFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXPressDumpSwitchFunctionWorker;
end;


{ TFSXEngineAntiIceFunction }
procedure TFSXEngineAntiIceFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXEngineAntiIceFunction.RegisterStates
end;


function TFSXEngineAntiIceFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXEngineAntiIceFunctionWorker;
end;


{ TFSXFuelPumpFunction }
procedure TFSXFuelPumpFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXFuelPumpFunction.RegisterStates
end;


function TFSXFuelPumpFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXFuelPumpFunctionWorker;
end;


{ TFSXDeIceFunction }
procedure TFSXDeIceFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXDeIceFunction.RegisterStates
end;


function TFSXDeIceFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXDeIceFunctionWorker;
end;


{ TFSXLightFunction }
function TCustomFSXLightFunction.GetCategoryName: string;
begin
  Result := FSXCategoryLights;
end;


function TCustomFSXLightFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXLightStatesFunctionWorker;
end;


function TCustomFSXLightFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker;
begin
  Result := inherited DoCreateWorker(ASettings);
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


{ TCustomFSXAutoPilotFunction }
function TCustomFSXAutoPilotFunction.GetCategoryName: string;
begin
  Result := FSXCategoryAutoPilot;
end;


{ TFSXAutoPilotFunction }
procedure TFSXAutoPilotFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotFunction.RegisterStates
end;


function TFSXAutoPilotFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAutoPilotFunctionWorker;
end;


{ TFSXAutoPilotHeadingFunction }
procedure TFSXAutoPilotHeadingFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotHeadingFunction.RegisterState
end;


function TFSXAutoPilotHeadingFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAutoPilotHeadingFunctionWorker;
end;


{ TFSXAutoPilotApproachFunction }
procedure TFSXAutoPilotApproachFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotApproachFunction.RegisterStates
end;


function TFSXAutoPilotApproachFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAutoPilotApproachFunctionWorker;
end;


{ TFSXAutoPilotBackcourseFunction }
procedure TFSXAutoPilotBackcourseFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotBackcourseFunction.RegisterStates
end;


function TFSXAutoPilotBackcourseFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAutoPilotBackcourseFunctionWorker;
end;


{ TFSXAutoPilotAltitudeFunction }
procedure TFSXAutoPilotAltitudeFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotAltitudeFunction.RegisterStates
end;


function TFSXAutoPilotAltitudeFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAutoPilotAltitudeFunctionWorker;
end;


{ TFSXAutoPilotNavFunction }
procedure TFSXAutoPilotNavFunction.RegisterStates;
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotNavFunction.RegisterStates
end;


function TFSXAutoPilotNavFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXAutoPilotNavFunctionWorker;
end;

end.

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

  TCustomFSXGearFunction = class(TCustomFSXSystemsFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
    procedure InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker); override;
  protected
    function GetGearVariableName: string; virtual; abstract;
    function GetGearPercentageFloat: Boolean; virtual; abstract;
  end;

  TFSXGearFunction = class(TCustomFSXGearFunction)
  protected
    function GetGearVariableName: string; override;
    function GetGearPercentageFloat: Boolean; override;
  end;

  TFSXLeftGearFunction = class(TCustomFSXGearFunction)
  protected
    function GetGearVariableName: string; override;
    function GetGearPercentageFloat: Boolean; override;
  end;

  TFSXRightGearFunction = class(TCustomFSXGearFunction)
  protected
    function GetGearVariableName: string; override;
    function GetGearPercentageFloat: Boolean; override;
  end;

  TFSXCenterGearFunction = class(TCustomFSXGearFunction)
  protected
    function GetGearVariableName: string; override;
    function GetGearPercentageFloat: Boolean; override;
  end;

  TFSXTailGearFunction = class(TCustomFSXGearFunction)
  protected
    function GetGearVariableName: string; override;
    function GetGearPercentageFloat: Boolean; override;
  end;

  TFSXParkingBrakeFunction = class(TCustomFSXInvertedOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXAutoBrakeFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
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

  TFSXTailWheelLockFunction = class(TCustomFSXSystemsFunction)
  protected
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXCustomFloatFunction = class(TCustomFSXSystemsFunction)
  protected
    procedure RegisterStates; override;
  end;

  TFSXFloatLeftFunction = class(TFSXCustomFloatFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXFloatRightFunction = class(TFSXCustomFloatFunction)
  protected
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { Instruments }
  TFSXPitotOnOffFunction = class(TCustomFSXOnOffFunction)
  protected
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXPitotWarningFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
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

  TFSXThrottleFunction = class(TCustomFSXFunction)
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

  TFSXFlapsHandleIndexFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXFlapsHandlePercentageFunction = class(TCustomFSXFunction)
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

  TFSXSpoilersArmedFunction = class(TCustomFSXFunction)
  protected
    function GetCategoryName: string; override;
    procedure RegisterStates; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;

  TFSXWaterRudderFunction = class(TCustomFSXFunction)
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
    procedure InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker); override;
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


  { Fuel }
  TFSXFuelFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
    function GetCategoryName: string; override;
    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
  end;


  { ATC }
  TFSXATCVisibilityFunction = class(TCustomMultiStateLEDFunction)
  protected
    procedure RegisterStates; override;

    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;

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
procedure TCustomFSXGearFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDGearNotRetractable, FSXStateDisplayNameGearNotRetractable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDGearRetracted,      FSXStateDisplayNameGearRetracted,       lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDGearBetween,        FSXStateDisplayNameGearBetween,         lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDGearExtended,       FSXStateDisplayNameGearExtended,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDGearSpeedExceeded,  FSXStateDisplayNameGearSpeedExceeded,   lcFlashingAmberNormal));
  RegisterState(TLEDState.Create(FSXStateUIDGearDamageBySpeed,  FSXStateDisplayNameGearDamageBySpeed,   lcFlashingRedFast));
end;


function TCustomFSXGearFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXGearFunctionWorker;
end;


procedure TCustomFSXGearFunction.InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker);
var
  gearFunctionWorker: TFSXGearFunctionWorker;

begin
  gearFunctionWorker := (AWorker as TFSXGearFunctionWorker);
  gearFunctionWorker.GearVariableName := GetGearVariableName;
  gearFunctionWorker.GearPercentageFloat := GetGearPercentageFloat;

  // Note: inherited sets SimConnect, which triggers RegisterVariables
  inherited InitializeWorker(AWorker);
end;


{ TFSXGearFunction }
function TFSXGearFunction.GetGearVariableName: string;
begin
  Result := 'GEAR TOTAL PCT EXTENDED';
end;

function TFSXGearFunction.GetGearPercentageFloat: Boolean;
begin
  Result :=  True;
end;


{ TFSXLefGearFunction }
function TFSXLeftGearFunction.GetGearVariableName: string;
begin
  Result := 'GEAR LEFT POSITION';
end;


function TFSXLeftGearFunction.GetGearPercentageFloat: Boolean;
begin
  Result :=  False;
end;


{ TFSXRightGearFunction }
function TFSXRightGearFunction.GetGearVariableName: string;
begin
  Result := 'GEAR RIGHT POSITION';
end;


function TFSXRightGearFunction.GetGearPercentageFloat: Boolean;
begin
  Result :=  False;
end;


{ TFSXCenterGearFunction }
function TFSXCenterGearFunction.GetGearVariableName: string;
begin
  Result := 'GEAR CENTER POSITION';
end;


function TFSXCenterGearFunction.GetGearPercentageFloat: Boolean;
begin
  Result := False;
end;


{ TFSXTailGearFunction }
function TFSXTailGearFunction.GetGearVariableName: string;
begin
  Result := 'GEAR TAIL POSITION';
end;


function TFSXTailGearFunction.GetGearPercentageFloat: Boolean;
begin
  Result := False;
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


{ TFSXAutoBrakeFunction }
function TFSXAutoBrakeFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;

procedure TFSXAutoBrakeFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDAutoBrake0, FSXStateDisplayNameAutoBrake0,  lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDAutoBrake1, FSXStateDisplayNameAutoBrake1,  lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDAutoBrake2, FSXStateDisplayNameAutoBrake2,  lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDAutoBrake3, FSXStateDisplayNameAutoBrake3,  lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDAutoBrake4, FSXStateDisplayNameAutoBrake4,  lcRed));
end;

function TFSXAutoBrakeFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXAutoBrakeFunctionWorker;
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


{ TFSXTailWheelLockFunction }
procedure TFSXTailWheelLockFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDTailWheelLocked,    FSXStateDisplayNameTailWheelLocked,   lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDTailWheelUnlocked,  FSXStateDisplayNameTailWheelUnlocked, lcRed));
end;


function TFSXTailWheelLockFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXTailWheelLockFunctionWorker;
end;


{ TFSXCustomFloatFunction }
procedure TFSXCustomFloatFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDFloatRetracted, FSXStateDisplayNameFloatRetracted,  lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDFloatBetween,   FSXStateDisplayNameFloatBetween,    lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFloatExtended,  FSXStateDisplayNameFloatExtended,   lcGreen));
end;


{ TFSXFloatLeftFunction }
function TFSXFloatLeftFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXFloatLeftFunctionWorker;
end;


{ TFSXFloatRightFunction }
function TFSXFloatRightFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXFloatRightFunctionWorker;
end;


{ TFSXPitotOnOffFunction }
function TFSXPitotOnOffFunction.GetCategoryName: string;
begin
  Result := FSXCategoryInstruments;
end;


function TFSXPitotOnOffFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXPitotOnOffFunctionWorker;
end;


{ TFSXPitotWarningFunction }
function TFSXPitotWarningFunction.GetCategoryName: string;
begin
  Result := FSXCategoryInstruments;
end;


procedure TFSXPitotWarningFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDPitotOffIceNone,    FSXStateDisplayNamePitotOffIceNone, lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOffIce25to50,  FSXStateDisplayNamePitotOffIce25to50, lcFlashingAmberNormal));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOffIce50to75,  FSXStateDisplayNamePitotOffIce50to75, lcFlashingAmberFast));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOffIce75to100, FSXStateDisplayNamePitotOffIce75to100, lcFlashingAmberFast));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOffIceFull,    FSXStateDisplayNamePitotOffIceFull, lcFlashingRedFast));

  RegisterState(TLEDState.Create(FSXStateUIDPitotOnIceFull,     FSXStateDisplayNamePitotOnIceFull, lcFlashingRedNormal));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOnIce75to100,  FSXStateDisplayNamePitotOnIce75to100, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOnIce50to75,   FSXStateDisplayNamePitotOnIce50to75, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOnIce25to50,   FSXStateDisplayNamePitotOnIce25to50, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDPitotOnIceNone,     FSXStateDisplayNamePitotOnIceNone, lcGreen));
end;


function TFSXPitotWarningFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXPitotWarningFunctionWorker;
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


{ TFSXThrottleFunction }
function TFSXThrottleFunction.GetCategoryName: string;
begin
  Result := FSXCategoryEngines;
end;


procedure TFSXThrottleFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDThrottleNoEngines,  FSXStateDisplayNameThrottleNoThrottles, lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDThrottleOff,        FSXStateDisplayNameThrottleOff, lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDThrottlePartial,    FSXStateDisplayNameThrottlePartial, lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDThrottleFull,       FSXStateDisplayNameThrottleFull, lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDThrottleReverse,    FSXStateDisplayNameThrottleReverse, lcFlashingAmberNormal));
end;


function TFSXThrottleFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXThrottleFunctionWorker;
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


{ TFSXFlapsHandleIndexFunction }
function TFSXFlapsHandleIndexFunction.GetCategoryName: string;
begin
  Result := FSXCategoryControlSurfaces;
end;


procedure TFSXFlapsHandleIndexFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndexNotAvailable, FSXStateDisplayNameFlapsHandleIndexNotAvailable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex0,            FSXStateDisplayNameFlapsHandleIndex0,             lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex1,            FSXStateDisplayNameFlapsHandleIndex1,             lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex2,            FSXStateDisplayNameFlapsHandleIndex2,             lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex3,            FSXStateDisplayNameFlapsHandleIndex3,             lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex4,            FSXStateDisplayNameFlapsHandleIndex4,             lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex5,            FSXStateDisplayNameFlapsHandleIndex5,             lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex6,            FSXStateDisplayNameFlapsHandleIndex6,             lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandleIndex7,            FSXStateDisplayNameFlapsHandleIndex7,             lcAmber));
end;


function TFSXFlapsHandleIndexFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXFlapsHandleIndexFunctionWorker;
end;


{ TFSXFlapsHandlePercentageFunction }
function TFSXFlapsHandlePercentageFunction.GetCategoryName: string;
begin
  Result := FSXCategoryControlSurfaces;
end;


procedure TFSXFlapsHandlePercentageFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentageNotAvailable,  FSXStateDisplayNameFlapsHandlePercentageNotAvailable, lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage0To10,         FSXStateDisplayNameFlapsHandlePercentage0To10,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage10To20,        FSXStateDisplayNameFlapsHandlePercentage10To20,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage20To30,        FSXStateDisplayNameFlapsHandlePercentage20To30,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage30To40,        FSXStateDisplayNameFlapsHandlePercentage30To40,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage40To50,        FSXStateDisplayNameFlapsHandlePercentage40To50,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage50To60,        FSXStateDisplayNameFlapsHandlePercentage50To60,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage60To70,        FSXStateDisplayNameFlapsHandlePercentage60To70,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage70To80,        FSXStateDisplayNameFlapsHandlePercentage70To80,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage80To90,        FSXStateDisplayNameFlapsHandlePercentage80To90,       lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFlapsHandlePercentage90To100,       FSXStateDisplayNameFlapsHandlePercentage90To100,      lcRed));
end;


function TFSXFlapsHandlePercentageFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXFlapsHandlePercentageFunctionWorker;
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


{ TFSXSpoilersArmedFunction }
function TFSXSpoilersArmedFunction.GetCategoryName: string;
begin
  Result := FSXCategoryControlSurfaces;
end;


procedure TFSXSpoilersArmedFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDSpoilersNotAvailable, FSXStateDisplayNameSpoilersNotAvailable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDOn,                   FSXStateDisplayNameOn,                    lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDOff,                  FSXStateDisplayNameOff,                   lcGreen));
end;


function TFSXSpoilersArmedFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXSpoilersArmedFunctionWorker;
end;


{ TFSXWaterRudderFunction }
function TFSXWaterRudderFunction.GetCategoryName: string;
begin
  Result := FSXCategoryControlSurfaces;
end;


procedure TFSXWaterRudderFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDWaterRudderRetracted, FSXStateDisplayNameWaterRudderRetracted,  lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDWaterRudderBetween,   FSXStateDisplayNameWaterRudderBetween,    lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDWaterRudderExtended,  FSXStateDisplayNameWaterRudderExtended,   lcRed));
end;


function TFSXWaterRudderFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXWaterRudderFunctionWorker;
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


procedure TCustomFSXLightFunction.InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker);
begin
  (AWorker as TFSXLightStatesFunctionWorker).StateMask := GetLightMask;

  // Note: inherited sets SimConnect, which triggers RegisterVariables
  inherited InitializeWorker(AWorker);
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


{ TFSXFuelFunction }
procedure TFSXFuelFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDFuelNotAvailable, FSXStateDisplayNameFuelNotAvailable,  lcOff));
  RegisterState(TLEDState.Create(FSXStateUIDFuelEmpty,        FSXStateDisplayNameFuelEmpty,         lcFlashingRedFast));
  RegisterState(TLEDState.Create(FSXStateUIDFuel0to1,         FSXStateDisplayNameFuel0to1,          lcFlashingRedNormal));
  RegisterState(TLEDState.Create(FSXStateUIDFuel1to2,         FSXStateDisplayNameFuel1to2,          lcFlashingRedNormal));
  RegisterState(TLEDState.Create(FSXStateUIDFuel2to5,         FSXStateDisplayNameFuel2to5,          lcRed));
  RegisterState(TLEDState.Create(FSXStateUIDFuel5to10,        FSXStateDisplayNameFuel5to10,         lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFuel10to20,       FSXStateDisplayNameFuel10to20,        lcAmber));
  RegisterState(TLEDState.Create(FSXStateUIDFuel20to50,       FSXStateDisplayNameFuel20to50,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDFuel50to75,       FSXStateDisplayNameFuel50to75,        lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDFuel75to100,      FSXStateDisplayNameFuel75to100,       lcGreen));
end;


function TFSXFuelFunction.GetCategoryName: string;
begin
  Result := FSXCategorySystems;
end;


function TFSXFuelFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXFuelFunctionWorker;
end;


{ TFSXATCFunction }
procedure TFSXATCVisibilityFunction.RegisterStates;
begin
  RegisterState(TLEDState.Create(FSXStateUIDATCHidden,  FSXStateDisplayNameATCHidden,   lcGreen));
  RegisterState(TLEDState.Create(FSXStateUIDATCVisible, FSXStateDisplayNameATCVisible,  lcFlashingAmberNormal));
end;


function TFSXATCVisibilityFunction.GetCategoryName: string;
begin
  Result := FSXCategoryATC;
end;


function TFSXATCVisibilityFunction.GetDisplayName: string;
begin
  Result := FSXFunctionDisplayNameATCVisibility;
end;


function TFSXATCVisibilityFunction.GetUID: string;
begin
  Result := FSXFunctionUIDATCVisibility;
end;


function TFSXATCVisibilityFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXATCVisibilityFunctionWorker;
end;

end.

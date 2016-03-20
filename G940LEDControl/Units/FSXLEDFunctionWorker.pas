unit FSXLEDFunctionWorker;

interface
uses
  OtlTaskControl,

  FSXLEDFunctionProvider,
  FSXSimConnectIntf,
  LEDFunction,
  LEDFunctionIntf;


type
  TCustomFSXOnOffFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure HandleData(AData: Pointer); override;
  end;


  { Systems }
  TFSXBatteryMasterFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXDeIceFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXExitDoorFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXGearFunctionWorker = class(TCustomFSXFunctionWorker)
  private
    FGearVariableName: string;
    FGearPercentageFloat: Boolean;
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  public
    property GearVariableName: string read FGearVariableName write FGearVariableName;
    property GearPercentageFloat: Boolean read FGearPercentageFloat write FGearPercentageFloat;
  end;

  TFSXParkingBrakeFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXAutoBrakeFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXPressDumpSwitchFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXTailHookFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXTailWheelLockFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXCustomFloatFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXFloatLeftFunctionWorker = class(TFSXCustomFloatFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXFloatRightFunctionWorker = class(TFSXCustomFloatFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;


  { Instruments }
  TFSXPitotOnOffFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;

  TFSXPitotWarningFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  { Engines }
  TFSXEngineAntiIceFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXEngineFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXThrottleFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  { Control surfaces }
  TFSXFlapsFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXFlapsHandleIndexFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXFlapsHandlePercentageFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXSpoilersFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXSpoilersArmedFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXWaterRudderFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  { Lights }
  TFSXLightStatesFunctionWorker = class(TCustomFSXFunctionWorker)
  private
    FStateMask: Integer;
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  public
    property StateMask: Integer read FStateMask write FStateMask;
  end;


  TFSXAllLightsFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  { Autopilot }
  PAutoPilotData = ^TAutoPilotData;
  TAutoPilotData = packed record
    AutoPilotAvailable: Cardinal;
    AutoPilotMaster: Cardinal;
    AutoPilotHeading: Cardinal;
    AutoPilotApproach: Cardinal;
    AutoPilotBackcourse: Cardinal;
    AutoPilotAltitude: Cardinal;
    AutoPilotNav: Cardinal;
  end;


  TCustomFSXAutoPilotFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;

    procedure SetOnOffState(AState: Cardinal); virtual;
    procedure HandleAutoPilotData(AData: PAutoPilotData); virtual; abstract;
  end;


  TFSXAutoPilotFunctionWorker = class(TCustomFSXAutoPilotFunctionWorker)
  protected
    procedure HandleAutoPilotData(AData: PAutoPilotData); override;
  end;


  TFSXAutoPilotHeadingFunctionWorker = class(TCustomFSXAutoPilotFunctionWorker)
  protected
    procedure HandleAutoPilotData(AData: PAutoPilotData); override;
  end;


  TFSXAutoPilotApproachFunctionWorker = class(TCustomFSXAutoPilotFunctionWorker)
  protected
    procedure HandleAutoPilotData(AData: PAutoPilotData); override;
  end;


  TFSXAutoPilotBackcourseFunctionWorker = class(TCustomFSXAutoPilotFunctionWorker)
  protected
    procedure HandleAutoPilotData(AData: PAutoPilotData); override;
  end;


  TFSXAutoPilotAltitudeFunctionWorker = class(TCustomFSXAutoPilotFunctionWorker)
  protected
    procedure HandleAutoPilotData(AData: PAutoPilotData); override;
  end;


  TFSXAutoPilotNavFunctionWorker = class(TCustomFSXAutoPilotFunctionWorker)
  protected
    procedure HandleAutoPilotData(AData: PAutoPilotData); override;
  end;


  { Radios }
  TFSXAvionicsMasterFunctionWorker = class(TCustomFSXOnOffFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
  end;


  { Fuel }
  TFSXFuelFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  { ATC }
  TFSXATCVisibilityFunctionWorker = class(TCustomLEDMultiStateFunctionWorker)
  private
    FMonitorTask: IOmniTaskControl;
  public
    constructor Create(const AProviderUID: string; const AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''); override;
    destructor Destroy; override;
  end;


implementation
uses
  System.Math,
  System.StrUtils,
  System.SysUtils,
  Winapi.Windows,

  OtlTask,

  FSXResources,
  LEDStateIntf,
  SimConnect;


{ TCustomFSXOnOffFunctionWorker }
procedure TCustomFSXOnOffFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
end;


{ TFSXBatteryMasterFunctionWorker }
procedure TFSXBatteryMasterFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('ELECTRICAL MASTER BATTERY', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


{ TFSXDeIceFunctionWorker }
procedure TFSXDeIceFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('STRUCTURAL DEICE SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


{ TFSXExitDoorFunctionWorker }
procedure TFSXExitDoorFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('CANOPY OPEN', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXExitDoorFunctionWorker.HandleData(AData: Pointer);
begin
  case Trunc(PDouble(AData)^) of
    0..5:     SetCurrentState(FSXStateUIDExitDoorClosed);
    95..100:  SetCurrentState(FSXStateUIDExitDoorOpen);
  else        SetCurrentState(FSXStateUIDExitDoorBetween);
  end;
end;


{ TFSXGearFunctionWorker }
procedure TFSXGearFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('IS GEAR RETRACTABLE',  FSX_UNIT_BOOL,    SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable(GearVariableName,       FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
  ADefinition.AddVariable('GEAR DAMAGE BY SPEED', FSX_UNIT_BOOL,    SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('GEAR SPEED EXCEEDED',  FSX_UNIT_BOOL,    SIMCONNECT_DATAType_INT32);
end;


procedure TFSXGearFunctionWorker.HandleData(AData: Pointer);
type
  PGearData = ^TGearData;
  TGearData = packed record
    IsGearRetractable: Cardinal;
    PercentageExtended: Double;
    DamageBySpeed: Integer;
    SpeedExceeded: Integer;
  end;

var
  gearData: PGearData;
  gearExtended: Double;

begin
  gearData := AData;

  if gearData^.DamageBySpeed <> 0 then
    SetCurrentState(FSXStateUIDGearDamageBySpeed)

  else if gearData^.SpeedExceeded <> 0 then
    SetCurrentState(FSXStateUIDGearSpeedExceeded)

  else if gearData^.IsGearRetractable <> 0 then
  begin
    if GearPercentageFloat then
      gearExtended := gearData^.PercentageExtended * 100
    else
      gearExtended := gearData^.PercentageExtended;

    case Trunc(gearExtended) of
      0:        SetCurrentState(FSXStateUIDGearRetracted);
      95..100:  SetCurrentState(FSXStateUIDGearExtended);
    else        SetCurrentState(FSXStateUIDGearBetween);
    end;
  end else
    SetCurrentState(FSXStateUIDGearNotRetractable);
end;


{ TFSXCustomFloatFunctionWorker }
procedure TFSXCustomFloatFunctionWorker.HandleData(AData: Pointer);
type
  PFloatData = ^TFloatData;
  TFloatData = packed record
    PercentageExtended: Double;
  end;

var
  floatData: PFloatData;

begin
  floatData := AData;

  case Trunc(floatData^.PercentageExtended) of
    0:        SetCurrentState(FSXStateUIDFloatRetracted);
    95..100:  SetCurrentState(FSXStateUIDFloatExtended);
  else        SetCurrentState(FSXStateUIDFloatBetween);
  end;
end;


{ TFSXFloatLeftFunctionWorker }
procedure TFSXFloatLeftFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('RETRACT LEFT FLOAT EXTENDED', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


{ TFSXFloatRightFunctionWorker }
procedure TFSXFloatRightFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('RETRACT RIGHT FLOAT EXTENDED', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


{ TFSXParkingBrakeFunctionWorker }
procedure TFSXParkingBrakeFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('BRAKE PARKING INDICATOR', FSX_UNIT_BOOL, SIMCONNECT_DATATYPE_INT32);
end;


{ TFSXAutoBrakeFunctionWorker }
procedure TFSXAutoBrakeFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('AUTO BRAKE SWITCH CB', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);
end;

procedure TFSXAutoBrakeFunctionWorker.HandleData(AData: Pointer);
type
  PAutoBrakeData = ^TAutoBrakeData;
  TAutoBrakeData = packed record
    Position: Cardinal;
  end;

var
  autoBrakeData: PAutoBrakeData;

begin
  autoBrakeData := AData;

  case autoBrakeData^.Position of
    0:  SetCurrentState(FSXStateUIDAutoBrake0);
    1:  SetCurrentState(FSXStateUIDAutoBrake1);
    2:  SetCurrentState(FSXStateUIDAutoBrake2);
    3:  SetCurrentState(FSXStateUIDAutoBrake3);
  else
        SetCurrentState(FSXStateUIDAutoBrake4);
  end;
end;


{ TFSXPressDumpSwitchFunctionWorker }
procedure TFSXPressDumpSwitchFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('PRESSURIZATION DUMP SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


{ TFSXTailHookFunctionWorker }
procedure TFSXTailHookFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('TAILHOOK POSITION', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXTailHookFunctionWorker.HandleData(AData: Pointer);
begin
  case Trunc(PDouble(AData)^) of
    0..5:     SetCurrentState(FSXStateUIDTailHookRetracted);
    95..100:  SetCurrentState(FSXStateUIDTailHookBetween);
  else        SetCurrentState(FSXStateUIDTailHookExtended);
  end;
end;


{ TFSXTailWheelLockFunctionWorker }
procedure TFSXTailWheelLockFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('TAILWHEEL LOCK ON', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


{ TFSXPitotOnOffFunctionWorker }
procedure TFSXPitotOnOffFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('PITOT HEAT', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


{ TFSXPitotWarningFunctionWorker }
procedure TFSXPitotWarningFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('PITOT HEAT', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('PITOT ICE PCT', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXPitotWarningFunctionWorker.HandleData(AData: Pointer);
type
  PPitotData = ^TPitotData;
  TPitotData = packed record
    HeatActive: Cardinal;
    IcePercentage: Double;
  end;

var
  pitotData: PPitotData;
  heatActive: Boolean;

begin
  pitotData := AData;
  heatActive := (pitotData^.HeatActive <> 0);

  case Trunc(pitotData^.IcePercentage) of
    25..49: SetCurrentState(IfThen(heatActive, FSXStateUIDPitotOnIce25to50, FSXStateUIDPitotOffIce25to50));
    50..74: SetCurrentState(IfThen(heatActive, FSXStateUIDPitotOnIce50to75, FSXStateUIDPitotOffIce50to75));
    75..99: SetCurrentState(IfThen(heatActive, FSXStateUIDPitotOnIce75to100, FSXStateUIDPitotOffIce75to100));
    100:    SetCurrentState(IfThen(heatActive, FSXStateUIDPitotOnIceFull, FSXStateUIDPitotOffIceFull));
  else      SetCurrentState(IfThen(heatActive, FSXStateUIDPitotOnIceNone, FSXStateUIDPitotOffIceNone));
  end;
end;


{ TFSXEngineAntiIceFunctionWorker }
procedure TFSXEngineAntiIceFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
var
  engineIndex: Integer;

begin
  ADefinition.AddVariable('NUMBER OF ENGINES', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

  for engineIndex := 1 to FSX_MAX_ENGINES do
    ADefinition.AddVariable(Format('ENG ANTI ICE:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXEngineAntiIceFunctionWorker.HandleData(AData: Pointer);
type
  PAntiIceData = ^TAntiIceData;
  TAntiIceData = packed record
    NumberOfEngines: Integer;
    EngineAntiIce: array[1..FSX_MAX_ENGINES] of Integer;
  end;

var
  antiIceData: PAntiIceData;
  engineCount: Integer;
  antiIceCount: Integer;
  engineIndex: Integer;

begin
  antiIceData := AData;
  engineCount := Min(antiIceData^.NumberOfEngines, FSX_MAX_ENGINES);
  antiIceCount := 0;

  for engineIndex := 1 to engineCount do
  begin
    if antiIceData^.EngineAntiIce[engineIndex] <> 0 then
      Inc(antiIceCount);
  end;

  if engineCount > 0 then
  begin
    if antiIceCount = 0 then
      SetCurrentState(FSXStateUIDEngineAntiIceNone)
    else if antiIceCount = engineCount then
      SetCurrentState(FSXStateUIDEngineAntiIceAll)
    else
      SetCurrentState(FSXStateUIDEngineAntiIcePartial);
  end else
    SetCurrentState(FSXStateUIDEngineAntiIceNoEngines);
end;



{ TFSXEngineFunctionWorker }
procedure TFSXEngineFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
var
  engineIndex: Integer;

begin
  ADefinition.AddVariable('NUMBER OF ENGINES', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

  for engineIndex := 1 to FSX_MAX_ENGINES do
    ADefinition.AddVariable(Format('GENERAL ENG COMBUSTION:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

  for engineIndex := 1 to FSX_MAX_ENGINES do
    ADefinition.AddVariable(Format('ENG FAILED:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

  for engineIndex := 1 to FSX_MAX_ENGINES do
    ADefinition.AddVariable(Format('ENG ON FIRE:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXEngineFunctionWorker.HandleData(AData: Pointer);
type
  PEngineData = ^TEngineData;
  TEngineData = packed record
    NumberOfEngines: Integer;
    Combustion: array[1..FSX_MAX_ENGINES] of Integer;
    Failed: array[1..FSX_MAX_ENGINES] of Integer;
    OnFire: array[1..FSX_MAX_ENGINES] of Integer;
  end;

var
  engineData: PEngineData;
  engineCount: Integer;
  engineIndex: Integer;
  hasFire: Boolean;
  hasFailure: Boolean;
  runningCount: Integer;

begin
  engineData := AData;

  if engineData^.NumberOfEngines > 0 then
  begin
    engineCount := Min(engineData^.NumberOfEngines, FSX_MAX_ENGINES);
    hasFire := False;
    hasFailure := False;
    runningCount := 0;

    for engineIndex := 1 to engineCount do
    begin
      if engineData^.OnFire[engineIndex] <> 0 then
        hasFire := True;

      if engineData^.Failed[engineIndex] <> 0 then
        hasFailure := True;

      if engineData^.Combustion[engineIndex] <> 0 then
        Inc(runningCount);
    end;

    if hasFire then
      SetCurrentState(FSXStateUIDEngineOnFire)

    else if hasFailure then
      SetCurrentState(FSXStateUIDEngineFailed)

    else if runningCount = 0 then
      SetCurrentState(FSXStateUIDEngineAllOff)

    else if runningCount = engineCount then
      SetCurrentState(FSXStateUIDEngineAllRunning)

    else
      SetCurrentState(FSXStateUIDEnginePartiallyRunning);
  end else
    SetCurrentState(FSXStateUIDEngineNoEngines);
end;


{ TFSXThrottleFunctionWorker }
procedure TFSXThrottleFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
var
  engineIndex: Integer;

begin
  ADefinition.AddVariable('NUMBER OF ENGINES', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

  for engineIndex := 1 to FSX_MAX_ENGINES do
    ADefinition.AddVariable(Format('GENERAL ENG THROTTLE LEVER POSITION:%d', [engineIndex]), FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXThrottleFunctionWorker.HandleData(AData: Pointer);
type
  PThrottleData = ^TThrottleData;
  TThrottleData = packed record
    NumberOfEngines: Integer;
    Position: array[1..FSX_MAX_ENGINES] of Double;
  end;

var
  throttleData: PThrottleData;
  reverse: Boolean;
  totalPosition: Double;
  engineIndex: Integer;

begin
  throttleData := AData;

  if throttleData^.NumberOfEngines > 0 then
  begin
    reverse := False;
    totalPosition := 0;

    for engineIndex := 1 to throttleData^.NumberOfEngines do
    begin
      if throttleData^.Position[engineIndex] < 0 then
      begin
        reverse := True;
        break;
      end else
        totalPosition := totalPosition + throttleData^.Position[engineIndex];
    end;

    if reverse then
      SetCurrentState(FSXStateUIDThrottleReverse)
    else
      case Trunc(totalPosition / throttleData^.NumberOfEngines) of
        0..5:     SetCurrentState(FSXStateUIDThrottleOff);
        95..100:  SetCurrentState(FSXStateUIDThrottleFull);
      else        SetCurrentState(FSXStateUIDThrottlePartial);
      end;
  end else
    SetCurrentState(FSXStateUIDThrottleNoEngines);
end;


{ TFSXFlapsFunctionWorker }
procedure TFSXFlapsFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('FLAPS AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('FLAPS HANDLE PERCENT', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
  ADefinition.AddVariable('FLAP DAMAGE BY SPEED', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('FLAP SPEED EXCEEDED', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXFlapsFunctionWorker.HandleData(AData: Pointer);
type
  PFlapsData = ^TFlapsData;
  TFlapsData = packed record
    FlapsAvailable: Cardinal;
    FlapsHandlePercent: Double;
    DamageBySpeed: Integer;
    SpeedExceeded: Integer;
  end;

var
  flapsData: PFlapsData;

begin
  flapsData := AData;

  if flapsData^.FlapsAvailable <> 0 then
  begin
    if flapsData^.DamageBySpeed <> 0 then
      SetCurrentState(FSXStateUIDFlapsDamageBySpeed)
    else if flapsData^.SpeedExceeded <> 0 then
      SetCurrentState(FSXStateUIDFlapsSpeedExceeded)
    else
      case Trunc(flapsData^.FlapsHandlePercent) of
        0..5:     SetCurrentState(FSXStateUIDFlapsRetracted);
        95..100:  SetCurrentState(FSXStateUIDFlapsExtended);
      else        SetCurrentState(FSXStateUIDFlapsBetween);
      end;
  end else
    SetCurrentState(FSXStateUIDFlapsNotAvailable);
end;


{ TFSXFlapsHandleIndexFunctionWorker }
procedure TFSXFlapsHandleIndexFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('FLAPS AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('FLAPS HANDLE INDEX', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('FLAPS NUM HANDLE POSITIONS', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXFlapsHandleIndexFunctionWorker.HandleData(AData: Pointer);
type
  PFlapsData = ^TFlapsData;
  TFlapsData = packed record
    FlapsAvailable: Cardinal;
    FlapsHandleIndex: Cardinal;
    FlapsNumHandles: Cardinal;
  end;

var
  flapsData: PFlapsData;

begin
  flapsData := AData;

  if flapsData^.FlapsAvailable <> 0 then
  begin
    case flapsData^.FlapsHandleIndex of
      0:  SetCurrentState(FSXStateUIDFlapsHandleIndex0);
      1:  SetCurrentState(FSXStateUIDFlapsHandleIndex1);
      2:  SetCurrentState(FSXStateUIDFlapsHandleIndex2);
      3:  SetCurrentState(FSXStateUIDFlapsHandleIndex3);
      4:  SetCurrentState(FSXStateUIDFlapsHandleIndex4);
      5:  SetCurrentState(FSXStateUIDFlapsHandleIndex5);
      6:  SetCurrentState(FSXStateUIDFlapsHandleIndex6);
    else
          SetCurrentState(FSXStateUIDFlapsHandleIndex7);
    end;
  end else
    SetCurrentState(FSXStateUIDFlapsHandleIndexNotAvailable);
end;


{ TFSXFlapsHandlePercentageFunctionWorker }
procedure TFSXFlapsHandlePercentageFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('FLAPS AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('FLAPS HANDLE PERCENT', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXFlapsHandlePercentageFunctionWorker.HandleData(AData: Pointer);
type
  PFlapsData = ^TFlapsData;
  TFlapsData = packed record
    FlapsAvailable: Cardinal;
    FlapsHandlePercent: Double;
  end;

var
  flapsData: PFlapsData;

begin
  flapsData := AData;

  if flapsData^.FlapsAvailable <> 0 then
  begin
    case Trunc(flapsData^.FlapsHandlePercent) of
      0..9:     SetCurrentState(FSXStateUIDFlapsHandlePercentage0To10);
      10..19:   SetCurrentState(FSXStateUIDFlapsHandlePercentage10To20);
      20..29:   SetCurrentState(FSXStateUIDFlapsHandlePercentage20To30);
      30..39:   SetCurrentState(FSXStateUIDFlapsHandlePercentage30To40);
      40..49:   SetCurrentState(FSXStateUIDFlapsHandlePercentage40To50);
      50..59:   SetCurrentState(FSXStateUIDFlapsHandlePercentage50To60);
      60..69:   SetCurrentState(FSXStateUIDFlapsHandlePercentage60To70);
      70..79:   SetCurrentState(FSXStateUIDFlapsHandlePercentage70To80);
      80..89:   SetCurrentState(FSXStateUIDFlapsHandlePercentage80To90);
    else
                SetCurrentState(FSXStateUIDFlapsHandlePercentage90To100);
    end;
  end else
    SetCurrentState(FSXStateUIDFlapsHandlePercentageNotAvailable);
end;


{ TFSXSpoilersFunctionWorker }
procedure TFSXSpoilersFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('SPOILER AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('SPOILERS HANDLE POSITION', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXSpoilersFunctionWorker.HandleData(AData: Pointer);
type
  PSpoilersData = ^TSpoilersData;
  TSpoilersData = packed record
    SpoilersAvailable: Cardinal;
    SpoilersHandlePercent: Double;
  end;

var
  spoilersData: PSpoilersData;

begin
  spoilersData := AData;

  if spoilersData^.SpoilersAvailable <> 0 then
  begin
    case Trunc(SpoilersData^.SpoilersHandlePercent) of
      0..5:     SetCurrentState(FSXStateUIDSpoilersRetracted);
      95..100:  SetCurrentState(FSXStateUIDSpoilersExtended);
    else        SetCurrentState(FSXStateUIDSpoilersBetween);
    end;
  end else
    SetCurrentState(FSXStateUIDSpoilersNotAvailable);
end;


{ TFSXSpoilersArmedFunctionWorker }
procedure TFSXSpoilersArmedFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('SPOILER AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('SPOILERS ARMED', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXSpoilersArmedFunctionWorker.HandleData(AData: Pointer);
type
  PSpoilersArmedData = ^TSpoilersArmedData;
  TSpoilersArmedData = packed record
    SpoilersAvailable: Cardinal;
    SpoilersArmed: Cardinal;
  end;

var
  spoilersArmedData: PSpoilersArmedData;

begin
  spoilersArmedData := AData;

  if spoilersArmedData^.SpoilersAvailable <> 0 then
  begin
    if spoilersArmedData^.SpoilersArmed <> 0 then
      SetCurrentState(FSXStateUIDOn)
    else
      SetCurrentState(FSXStateUIDOff);
  end else
    SetCurrentState(FSXStateUIDSpoilersNotAvailable);
end;


{ TFSXWaterRudderFunctionWorker }
procedure TFSXWaterRudderFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('WATER RUDDER HANDLE POSITION', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXWaterRudderFunctionWorker.HandleData(AData: Pointer);
type
  PWaterRudderData = ^TWaterRudderData;
  TWaterRudderData = packed record
    WaterRudderHandlePercent: Double;
  end;

var
  waterRudderData: PWaterRudderData;

begin
  waterRudderData := AData;

  case Trunc(WaterRudderData^.WaterRudderHandlePercent) of
    0..5:     SetCurrentState(FSXStateUIDWaterRudderRetracted);
    95..100:  SetCurrentState(FSXStateUIDWaterRudderExtended);
  else        SetCurrentState(FSXStateUIDWaterRudderBetween);
  end;
end;


{ TFSXLightStatesFunctionWorker }
procedure TFSXLightStatesFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('LIGHT ON STATES', FSX_UNIT_MASK, SIMCONNECT_DATATYPE_INT32);
end;


procedure TFSXLightStatesFunctionWorker.HandleData(AData: Pointer);
begin
  if (PCardinal(AData)^ and StateMask) <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
end;


{ TFSXAllLightsFunctionWorker }
procedure TFSXAllLightsFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('LIGHT ON STATES', FSX_UNIT_MASK, SIMCONNECT_DATATYPE_INT32);
end;


procedure TFSXAllLightsFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ = FSX_LIGHTON_ALL then
    SetCurrentState(FSXStateUIDOn)
  else if PCardinal(AData)^ > 0 then
    SetCurrentState(FSXStateUIDPartial)
  else
    SetCurrentState(FSXStateUIDOff);
end;


{ TCustomFSXAutoPilotFunctionWorker }
procedure TCustomFSXAutoPilotFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('AUTOPILOT AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('AUTOPILOT MASTER', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('AUTOPILOT HEADING LOCK', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('AUTOPILOT APPROACH HOLD', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('AUTOPILOT BACKCOURSE HOLD', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('AUTOPILOT ALTITUDE LOCK', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('AUTOPILOT NAV1 LOCK', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TCustomFSXAutoPilotFunctionWorker.HandleData(AData: Pointer);
var
  autoPilotData: PAutoPilotData;

begin
  autoPilotData := AData;

  if autoPilotData^.AutoPilotAvailable <> 0 then
    HandleAutoPilotData(autoPilotData)
  else
    SetCurrentState(FSXStateUIDOff);
end;


procedure TCustomFSXAutoPilotFunctionWorker.SetOnOffState(AState: Cardinal);
begin
  if AState <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
end;


{ TFSXAutoPilotFunctionWorker }
procedure TFSXAutoPilotFunctionWorker.HandleAutoPilotData(AData: PAutoPilotData);
begin
  SetOnOffState(AData^.AutoPilotMaster);
end;


{ TFSXAutoPilotHeadingFunctionWorker }
procedure TFSXAutoPilotHeadingFunctionWorker.HandleAutoPilotData(AData: PAutoPilotData);
begin
  SetOnOffState(AData^.AutoPilotHeading);
end;


{ TFSXAutoPilotApproachFunctionWorker }
procedure TFSXAutoPilotApproachFunctionWorker.HandleAutoPilotData(AData: PAutoPilotData);
begin
  SetOnOffState(AData^.AutoPilotApproach);
end;


{ TFSXAutoPilotBackcourseFunctionWorker }
procedure TFSXAutoPilotBackcourseFunctionWorker.HandleAutoPilotData(AData: PAutoPilotData);
begin
  SetOnOffState(AData^.AutoPilotBackcourse);
end;


{ TFSXAutoPilotAltitudeFunctionWorker }
procedure TFSXAutoPilotAltitudeFunctionWorker.HandleAutoPilotData(AData: PAutoPilotData);
begin
  SetOnOffState(AData^.AutoPilotAltitude);
end;


{ TFSXAutoPilotNavFunctionWorker }
procedure TFSXAutoPilotNavFunctionWorker.HandleAutoPilotData(AData: PAutoPilotData);
begin
  SetOnOffState(AData^.AutoPilotNav);
end;


{ TFSXAvionicsMasterFunctionWorker }
procedure TFSXAvionicsMasterFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('AVIONICS MASTER SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


{ TFSXFuelFunctionWorker }
procedure TFSXFuelFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('FUEL TOTAL CAPACITY', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_FLOAT64);
  ADefinition.AddVariable('FUEL TOTAL QUANTITY', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_FLOAT64);
end;


procedure TFSXFuelFunctionWorker.HandleData(AData: Pointer);
type
  PFuelData = ^TFuelData;
  TFuelData = packed record
    TotalCapacity: Double;
    TotalQuantity: Double;
  end;

var
  fuelData: PFuelData;
  percentage: Integer;

begin
  fuelData := AData;

  if fuelData^.TotalCapacity > 0 then
  begin
    percentage := Ceil(fuelData^.TotalQuantity / fuelData^.TotalCapacity * 100);
    case percentage of
      0:      SetCurrentState(FSXStateUIDFuelEmpty);
      1:      SetCurrentState(FSXStateUIDFuel0to1);
      2:      SetCurrentState(FSXStateUIDFuel1to2);
      3..5:   SetCurrentState(FSXStateUIDFuel2to5);
      6..10:  SetCurrentState(FSXStateUIDFuel5to10);
      11..20: SetCurrentState(FSXStateUIDFuel10to20);
      21..50: SetCurrentState(FSXStateUIDFuel20to50);
      51..75: SetCurrentState(FSXStateUIDFuel50to75);
    else
              SetCurrentState(FSXStateUIDFuel75to100);
    end;
  end else
    SetCurrentState(FSXStateUIDFuelNotAvailable);
end;


type
  TFSXATCVisibilityStateChanged = reference to procedure(AVisible: Boolean);

  TFSXATCVisibilityTask = class(TOmniWorker)
  private
    FOnStateChanged: TFSXATCVisibilityStateChanged;
    FVisible: Boolean;
  public
    constructor Create(AOnStateChanged: TFSXATCVisibilityStateChanged);
    procedure Run;
  end;


{ TFSXATCVisibilityFunctionWorker }
constructor TFSXATCVisibilityFunctionWorker.Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string);
begin
  inherited Create(AProviderUID, AFunctionUID, AStates, ASettings, APreviousState);

  FMonitorTask := CreateTask(TFSXATCVisibilityTask.Create(
    procedure(AVisible: Boolean)
    begin
      if AVisible then
        SetCurrentState(FSXStateUIDATCVisible)
      else
        SetCurrentState(FSXStateUIDATCHidden);
    end))
    .SetTimer(1, MSecsPerSec, @TFSXATCVisibilityTask.Run)
    .Run;
end;


destructor TFSXATCVisibilityFunctionWorker.Destroy;
begin
  FMonitorTask.Terminate;
  FMonitorTask := nil;

  inherited Destroy;
end;


{ TFSXATCVisibilityTask }
constructor TFSXATCVisibilityTask.Create(AOnStateChanged: TFSXATCVisibilityStateChanged);
begin
  inherited Create;

  FOnStateChanged := AOnStateChanged;
  FVisible := False;
end;


procedure TFSXATCVisibilityTask.Run;
const
  ClassNameMainWindow = 'FS98MAIN';
  ClassNameChildWindow = 'FS98CHILD';
  ClassNameFloatWindow = 'FS98FLOAT';
  WindowTitleATC = 'ATC Menu';

var
  visible: Boolean;
  mainWindow: THandle;
  atcWindow: THandle;

begin
  { Docked }
  atcWindow := 0;
  mainWindow := FindWindow(ClassNameMainWindow, nil);
  if mainWindow <> 0 then
    atcWindow := FindWindowEx(mainWindow, 0, ClassNameChildWindow, WindowTitleATC);

  { Undocked }
  if atcWindow = 0 then
    atcWindow := FindWindow(ClassNameFloatWindow, WindowTitleATC);


  visible := (atcWindow <> 0) and IsWindowVisible(atcWindow);

  if visible <> FVisible then
  begin
    FVisible := visible;
    FOnStateChanged(visible);
  end;
end;

end.

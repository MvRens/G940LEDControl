unit FSXLEDFunctionWorker;

interface
uses
  FSXLEDFunctionProvider,
  FSXSimConnectIntf;


type
  { Systems }
  TFSXBatteryMasterFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXDeIceFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXExitDoorFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXGearFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXParkingBrakeFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXPressDumpSwitchFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXTailHookFunctionWorker = class(TCustomFSXFunctionWorker)
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


  { Control surfaces }
  TFSXFlapsFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXSpoilersFunctionWorker = class(TCustomFSXFunctionWorker)
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
  TFSXAvionicsMasterFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


implementation
uses
  System.Math,
  System.SysUtils,

  FSXResources,
  LEDStateIntf,
  SimConnect;


{ TFSXBatteryMasterFunctionWorker }
procedure TFSXBatteryMasterFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('ELECTRICAL MASTER BATTERY', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXBatteryMasterFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
end;


{ TFSXDeIceFunctionWorker }
procedure TFSXDeIceFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('STRUCTURAL DEICE SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXDeIceFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
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
  ADefinition.AddVariable('IS GEAR RETRACTABLE',     FSX_UNIT_BOOL,    SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('GEAR TOTAL PCT EXTENDED', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
  ADefinition.AddVariable('GEAR DAMAGE BY SPEED',    FSX_UNIT_BOOL,    SIMCONNECT_DATAType_INT32);
  ADefinition.AddVariable('GEAR SPEED EXCEEDED',     FSX_UNIT_BOOL,    SIMCONNECT_DATAType_INT32);
end;


procedure TFSXGearFunctionWorker.HandleData(AData: Pointer);
type
  PGearData = ^TGearData;
  TGearData = packed record
    IsGearRetractable: Cardinal;
    TotalPctExtended: Double;
    DamageBySpeed: Integer;
    SpeedExceeded: Integer;
  end;

var
  gearData: PGearData;

begin
  gearData := AData;

  if gearData^.DamageBySpeed <> 0 then
    SetCurrentState(FSXStateUIDGearDamageBySpeed)

  else if gearData^.SpeedExceeded <> 0 then
    SetCurrentState(FSXStateUIDGearSpeedExceeded)

  else if gearData^.IsGearRetractable <> 0 then
  begin
    case Trunc(gearData ^.TotalPctExtended * 100) of
      0:        SetCurrentState(FSXStateUIDGearRetracted);
      95..100:  SetCurrentState(FSXStateUIDGearExtended);
    else        SetCurrentState(FSXStateUIDGearBetween);
    end;
  end else
    SetCurrentState(FSXStateUIDGearNotRetractable);
end;


{ TFSXParkingBrakeFunctionWorker }
procedure TFSXParkingBrakeFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('BRAKE PARKING INDICATOR', FSX_UNIT_BOOL, SIMCONNECT_DATATYPE_INT32);
end;


procedure TFSXParkingBrakeFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
end;


{ TFSXPressDumpSwitchFunctionWorker }
procedure TFSXPressDumpSwitchFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  ADefinition.AddVariable('PRESSURIZATION DUMP SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
end;


procedure TFSXPressDumpSwitchFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
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
  SpoilersData := AData;

  if SpoilersData^.SpoilersAvailable <> 0 then
  begin
    case Trunc(SpoilersData^.SpoilersHandlePercent) of
      0..5:     SetCurrentState(FSXStateUIDSpoilersRetracted);
      95..100:  SetCurrentState(FSXStateUIDSpoilersExtended);
    else        SetCurrentState(FSXStateUIDSpoilersBetween);
    end;
  end else
    SetCurrentState(FSXStateUIDSpoilersNotAvailable);
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


procedure TFSXAvionicsMasterFunctionWorker.HandleData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    SetCurrentState(FSXStateUIDOn)
  else
    SetCurrentState(FSXStateUIDOff);
end;

end.

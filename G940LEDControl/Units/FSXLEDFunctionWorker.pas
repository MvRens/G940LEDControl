unit FSXLEDFunctionWorker;

interface
uses
  FSXLEDFunctionProvider,
  FSXSimConnectIntf;


type
  { Misc }
  TFSXEngineFunctionWorker = class(TCustomFSXFunctionWorker)
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

  TFSXExitDoorFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;

  TFSXTailHookFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


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


  TFSXBatteryMasterFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXAvionicsMasterFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXPressDumpSwitchFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXEngineAntiIceFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXFuelPumpFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXDeIceFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXLightStatesFunctionWorker = class(TCustomFSXFunctionWorker)
  private
    FStateMask: Integer;
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  public
    property StateMask: Integer read FStateMask write FStateMask;
  end;


  TFSXAutoPilotFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXAutoPilotHeadingFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXAutoPilotApproachFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXAutoPilotBackcourseFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXAutoPilotAltitudeFunctionWorker = class(TCustomFSXFunctionWorker)
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  end;


  TFSXAutoPilotNavFunctionWorker = class(TCustomFSXFunctionWorker)
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


{ TFSXTailHookFunctionWorker }
procedure TFSXTailHookFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXTailHookFunctionWorker.RegisterVariables
end;


procedure TFSXTailHookFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXTailHookFunctionWorker.HandleData
end;


{ TFSXFlapsFunctionWorker }
procedure TFSXFlapsFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXFlapsFunctionWorker.RegisterVariables
end;


procedure TFSXFlapsFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXFlapsFunctionWorker.HandleData
end;


{ TFSXSpoilersFunctionWorker }
procedure TFSXSpoilersFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXSpoilersFunctionWorker.RegisterVariables
end;


procedure TFSXSpoilersFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXSpoilersFunctionWorker.HandleData
end;


{ TFSXBatteryMasterFunctionWorker }
procedure TFSXBatteryMasterFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXBatteryMasterFunctionWorker.RegisterVariables
end;


procedure TFSXBatteryMasterFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXBatteryMasterFunctionWorker.HandleData
end;


{ TFSXAvionicsMasterFunctionWorker }
procedure TFSXAvionicsMasterFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAvionicsMasterFunctionWorker.RegisterVariables
end;


procedure TFSXAvionicsMasterFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAvionicsMasterFunctionWorker.HandleData
end;


{ TFSXPressDumpSwitchFunctionWorker }
procedure TFSXPressDumpSwitchFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXPressDumpSwitchFunctionWorker.RegisterVariables
end;


procedure TFSXPressDumpSwitchFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXPressDumpSwitchFunctionWorker.HandleData
end;


{ TFSXEngineAntiIceFunctionWorker }
procedure TFSXEngineAntiIceFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXEngineAntiIceFunctionWorker.RegisterVariables
end;


procedure TFSXEngineAntiIceFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXEngineAntiIceFunctionWorker.HandleData
end;


{ TFSXFuelPumpFunctionWorker }
procedure TFSXFuelPumpFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXFuelPumpFunctionWorker.RegisterVariables
end;


procedure TFSXFuelPumpFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXFuelPumpFunctionWorker.HandleData
end;


{ TFSXDeIceFunctionWorker }
procedure TFSXDeIceFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXDeIceFunctionWorker.RegisterVariables
end;


procedure TFSXDeIceFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXDeIceFunctionWorker.HandleData
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


{ TFSXAutoPilotFunctionWorker }
procedure TFSXAutoPilotFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotFunctionWorker.RegisterVariables
end;


procedure TFSXAutoPilotFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotFunctionWorker.HandleData
end;


{ TFSXAutoPilotHeadingFunctionWorker }
procedure TFSXAutoPilotHeadingFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotHeadingFunctionWorker.RegisterVariables
end;


procedure TFSXAutoPilotHeadingFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotHeadingFunctionWorker.HandleData
end;


{ TFSXAutoPilotApproachFunctionWorker }
procedure TFSXAutoPilotApproachFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotApproachFunctionWorker.RegisterVariables
end;


procedure TFSXAutoPilotApproachFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotApproachFunctionWorker.HandleData
end;


{ TFSXAutoPilotBackcourseFunctionWorker }
procedure TFSXAutoPilotBackcourseFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotBackcourseFunctionWorker.RegisterVariables
end;


procedure TFSXAutoPilotBackcourseFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotBackcourseFunctionWorker.HandleData
end;


{ TFSXAutoPilotAltitudeFunctionWorker }
procedure TFSXAutoPilotAltitudeFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotAltitudeFunctionWorker.RegisterVariables
end;


procedure TFSXAutoPilotAltitudeFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotAltitudeFunctionWorker.HandleData
end;


{ TFSXAutoPilotNavFunctionWorker }
procedure TFSXAutoPilotNavFunctionWorker.RegisterVariables(ADefinition: IFSXSimConnectDefinition);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotNavFunctionWorker.RegisterVariables
end;


procedure TFSXAutoPilotNavFunctionWorker.HandleData(AData: Pointer);
begin
  // #ToDo1 -cEmpty -oMvR: 22-2-2013: TFSXAutoPilotNavFunctionWorker.HandleData
end;

end.

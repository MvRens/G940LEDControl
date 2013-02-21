unit FSXLEDFunction;

interface
uses
  FSXLEDFunctionProvider,
  LEDFunction,
  LEDFunctionIntf;


type
  { Base classes }
  TFSXOnOffFunction = class(TCustomFSXFunction)
  protected
    procedure RegisterStates; override;
  end;


  { Function implementations }
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


  TFSXLightFunction = class(TFSXOnOffFunction)
  protected
    function GetCategoryName: string; override;

    function GetWorkerClass: TCustomLEDFunctionWorkerClass; override;
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker; override;
  protected
    function GetLightMask: Integer; virtual; abstract;
  end;

  TFSXLandingLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXInstrumentLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXBeaconLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXNavLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXStrobeLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXTaxiLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;

  TFSXRecognitionLightsFunction = class(TFSXLightFunction)
  protected
    function GetLightMask: Integer; override;
  end;


implementation
uses
  System.Math,
  System.SysUtils,

  FSXSimConnectIntf,
  FSXResources,
  LEDColorIntf,
  LEDState,
  LEDStateIntf,
  SimConnect;


type
  { Worker implementations }
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

  TFSXLightStatesFunctionWorker = class(TCustomFSXFunctionWorker)
  private
    FStateMask: Integer;
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); override;
    procedure HandleData(AData: Pointer); override;
  public
    property StateMask: Integer read FStateMask write FStateMask;
  end;


{ TFSXOnOffFunction }
procedure TFSXOnOffFunction.RegisterStates;
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


{ TFSXLightFunction }
function TFSXLightFunction.GetCategoryName: string;
begin
  Result := FSXCategoryLights;
end;


function TFSXLightFunction.GetWorkerClass: TCustomLEDFunctionWorkerClass;
begin
  Result := TFSXLightStatesFunctionWorker;
end;


function TFSXLightFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker;
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

end.

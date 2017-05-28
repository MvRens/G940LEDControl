unit FSXLEDFunctionProvider;

interface
uses
  Generics.Collections,
  System.SyncObjs,
  System.Types,

  X2Log.Intf,
  Lua,

  FSXLEDFunctionProviderIntf,
  FSXSimConnectIntf,
  LEDFunction,
  LEDFunctionIntf,
  LEDStateIntf,
  LuaLEDFunctionProvider;


type
  TFSXLEDFunctionWorker = class;


  TFSXLEDFunctionProvider = class(TCustomLuaLEDFunctionProvider, IFSXLEDFunctionProvider, IFSXSimConnectObserver)
  private
    FSimConnect: TInterfacedObject;
    FSimConnectLock: TCriticalSection;
    FProfileMenuSimConnect: IFSXSimConnectProfileMenu;
    FScriptSimConnect: TObject;
  protected
    function GetUID: string; override;
    function CreateLuaLEDFunction(AInfo: ILuaTable; AOnSetup: ILuaFunction): TCustomLuaLEDFunction; override;

    procedure InitInterpreter; override;
    procedure SetupWorker(AWorker: TFSXLEDFunctionWorker; AOnSetup: ILuaFunction);

    { IFSXSimConnectObserver }
    procedure ObserveDestroy(Sender: IFSXSimConnect);

    { IFSXLEDFunctionProvider }
    procedure SetProfileMenu(AEnabled: Boolean; ACascaded: Boolean);
  public
    constructor Create(const AScriptFolders: TStringDynArray);
    destructor Destroy; override;

    function GetSimConnect: IFSXSimConnect;
  end;


  TFSXLEDFunction = class(TCustomLuaLEDFunction)
  private
    FProvider: TFSXLEDFunctionProvider;
  protected
    function GetDefaultCategoryName: string; override;

    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; override;
    procedure InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker); override;

    property Provider: TFSXLEDFunctionProvider read FProvider;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider; AInfo: ILuaTable; AOnSetup: ILuaFunction);
  end;


  TFSXLEDFunctionWorker = class(TCustomLuaLEDFunctionWorker)
  private
    FDataHandler: IFSXSimConnectDataHandler;
    FDefinitionID: TList<Cardinal>;
  protected
    property DataHandler: IFSXSimConnectDataHandler read FDataHandler;
    property DefinitionID: TList<Cardinal> read FDefinitionID;
  protected
    procedure AddDefinition(ADefinition: IFSXSimConnectDefinition);

    procedure HandleData(AData: Pointer); virtual; abstract;
  public
    constructor Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''); override;
    destructor Destroy; override;
  end;


implementation
uses
  System.Classes,
  System.SysUtils,

  X2Log.Global,

  FSXLEDFunction,
  FSXResources,
  FSXSimConnectClient,
  LEDFunctionRegistry,
  SimConnect;


type
  TCustomFSXFunctionWorkerDataHandler = class(TInterfacedObject, IFSXSimConnectDataHandler)
  private
    FWorker: TFSXLEDFunctionWorker;
  protected
    { IFSXSimConnectDataHandler }
    procedure HandleData(AData: Pointer);

    property Worker: TFSXLEDFunctionWorker read FWorker;
  public
    constructor Create(AWorker: TFSXLEDFunctionWorker);
  end;


  TLuaSimConnect = class(TPersistent)
  private
    FProvider: TFSXLEDFunctionProvider;
  protected
    property Provider: TFSXLEDFunctionProvider read FProvider;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider);
  published
    procedure Monitor(Context: ILuaContext);
  end;


type
  TLuaSimConnectType = record
    TypeName: string;
    Units: string;
    DataType: SIMCONNECT_DATAType;
  end;

const
  LuaSimConnectTypes: array[0..4] of TLuaSimConnectType =
                      (
                        ( TypeName: 'Bool'; Units: FSX_UNIT_BOOL; DataType: SIMCONNECT_DATAType_INT32 ),
                        ( TypeName: 'Percent'; Units: FSX_UNIT_PERCENT; DataType: SIMCONNECT_DATAType_FLOAT64 ),
                        ( TypeName: 'Integer'; Units: FSX_UNIT_NUMBER; DataType: SIMCONNECT_DATAType_INT32 ),
                        ( TypeName: 'Float'; Units: FSX_UNIT_NUMBER; DataType: SIMCONNECT_DATAType_FLOAT64 ),
                        ( TypeName: 'Mask'; Units: FSX_UNIT_MASK; DataType: SIMCONNECT_DATATYPE_INT32 )
                      );


function GetUnits(const AType: string; out AUnits: string; out ADataType: SIMCONNECT_DATAType): Boolean;
var
  typeIndex: Integer;

begin
  for typeIndex := Low(LuaSimConnectTypes) to High(LuaSimConnectTypes) do
    if SameText(AType, LuaSimConnectTypes[typeIndex].TypeName) then
    begin
      AUnits := LuaSimConnectTypes[typeIndex].Units;
      ADataType := LuaSimConnectTypes[typeIndex].DataType;
      Exit(True);
    end;

  Result := False;
end;


{ TFSXLEDFunctionProvider }
constructor TFSXLEDFunctionProvider.Create(const AScriptFolders: TStringDynArray);
begin
  FSimConnectLock := TCriticalSection.Create;
  FScriptSimConnect := TLuaSimConnect.Create(Self);

  inherited Create(AScriptFolders);
end;


destructor TFSXLEDFunctionProvider.Destroy;
begin
  FreeAndNil(FScriptSimConnect);
  FreeAndNil(FSimConnectLock);

  inherited Destroy;
end;


(*
procedure TFSXLEDFunctionProvider.RegisterFunctions;
begin
  inherited RegisterFunctions;

  { Systems }
  RegisterFunction(TFSXBatteryMasterFunction.Create(        Self, FSXFunctionDisplayNameBatteryMaster,          FSXFunctionUIDBatteryMaster));
  RegisterFunction(TFSXDeIceFunction.Create(                Self, FSXFunctionDisplayNameDeIce,                  FSXFunctionUIDDeIce));
  RegisterFunction(TFSXExitDoorFunction.Create(             Self, FSXFunctionDisplayNameExitDoor,               FSXFunctionUIDExitDoor));
  RegisterFunction(TFSXGearFunction.Create(                 Self, FSXFunctionDisplayNameGear,                   FSXFunctionUIDGear));
  RegisterFunction(TFSXLeftGearFunction.Create(             Self, FSXFunctionDisplayNameLeftGear,               FSXFunctionUIDLeftGear));
  RegisterFunction(TFSXRightGearFunction.Create(            Self, FSXFunctionDisplayNameRightGear,              FSXFunctionUIDRightGear));
  RegisterFunction(TFSXCenterGearFunction.Create(           Self, FSXFunctionDisplayNameCenterGear,             FSXFunctionUIDCenterGear));
  RegisterFunction(TFSXTailGearFunction.Create(             Self, FSXFunctionDisplayNameTailGear,               FSXFunctionUIDTailGear));
  RegisterFunction(TFSXParkingBrakeFunction.Create(         Self, FSXFunctionDisplayNameParkingBrake,           FSXFunctionUIDParkingBrake));
  RegisterFunction(TFSXAutoBrakeFunction.Create(            Self, FSXFunctionDisplayNameAutoBrake,              FSXFunctionUIDAutoBrake));
  RegisterFunction(TFSXPressDumpSwitchFunction.Create(      Self, FSXFunctionDisplayNamePressDumpSwitch,        FSXFunctionUIDPressDumpSwitch));
  RegisterFunction(TFSXTailHookFunction.Create(             Self, FSXFunctionDisplayNameTailHook,               FSXFunctionUIDTailHook));
  RegisterFunction(TFSXTailWheelLockFunction.Create(        Self, FSXFunctionDisplayNameTailWheelLock,          FSXFunctionUIDTailWheelLock));
  RegisterFunction(TFSXFloatLeftFunction.Create(            Self, FSXFunctionDisplayNameFloatLeft,              FSXFunctionUIDFloatLeft));
  RegisterFunction(TFSXFloatRightFunction.Create(           Self, FSXFunctionDisplayNameFloatRight,             FSXFunctionUIDFloatRight));

  { Instruments }
  RegisterFunction(TFSXPitotOnOffFunction.Create(           Self, FSXFunctionDisplayNamePitotOnOff,             FSXFunctionUIDPitotOnOff));
  RegisterFunction(TFSXPitotWarningFunction.Create(         Self, FSXFunctionDisplayNamePitotWarning,           FSXFunctionUIDPitotWarning));

  { Engines }
  RegisterFunction(TFSXEngineAntiIceFunction.Create(        Self, FSXFunctionDisplayNameEngineAntiIce,          FSXFunctionUIDEngineAntiIce));
  RegisterFunction(TFSXEngineFunction.Create(               Self, FSXFunctionDisplayNameEngine,                 FSXFunctionUIDEngine));
  RegisterFunction(TFSXThrottleFunction.Create(             Self, FSXFunctionDisplayNameThrottle,               FSXFunctionUIDThrottle));

  { Control surfaces }
  RegisterFunction(TFSXFlapsFunction.Create(                Self, FSXFunctionDisplayNameFlaps,                  FSXFunctionUIDFlaps));
  RegisterFunction(TFSXFlapsHandleIndexFunction.Create(     Self, FSXFunctionDisplayNameFlapsHandleIndex,       FSXFunctionUIDFlapsHandleIndex));
  RegisterFunction(TFSXFlapsHandlePercentageFunction.Create(Self, FSXFunctionDisplayNameFlapsHandlePercentage,  FSXFunctionUIDFlapsHandlePercentage));
  RegisterFunction(TFSXSpoilersFunction.Create(             Self, FSXFunctionDisplayNameSpoilers,               FSXFunctionUIDSpoilers));
  RegisterFunction(TFSXSpoilersArmedFunction.Create(        Self, FSXFunctionDisplayNameSpoilersArmed,          FSXFunctionUIDSpoilersArmed));
  RegisterFunction(TFSXWaterRudderFunction.Create(          Self, FSXFunctionDisplayNameWaterRudder,            FSXFunctionUIDWaterRudder));

  { Lights }
  RegisterFunction(TFSXBeaconLightsFunction.Create(         Self, FSXFunctionDisplayNameBeaconLights,           FSXFunctionUIDBeaconLights));
  RegisterFunction(TFSXInstrumentLightsFunction.Create(     Self, FSXFunctionDisplayNameInstrumentLights,       FSXFunctionUIDInstrumentLights));
  RegisterFunction(TFSXLandingLightsFunction.Create(        Self, FSXFunctionDisplayNameLandingLights,          FSXFunctionUIDLandingLights));
  RegisterFunction(TFSXNavLightsFunction.Create(            Self, FSXFunctionDisplayNameNavLights,              FSXFunctionUIDNavLights));
  RegisterFunction(TFSXRecognitionLightsFunction.Create(    Self, FSXFunctionDisplayNameRecognitionLights,      FSXFunctionUIDRecognitionLights));
  RegisterFunction(TFSXStrobeLightsFunction.Create(         Self, FSXFunctionDisplayNameStrobeLights,           FSXFunctionUIDStrobeLights));
  RegisterFunction(TFSXTaxiLightsFunction.Create(           Self, FSXFunctionDisplayNameTaxiLights,             FSXFunctionUIDTaxiLights));
  RegisterFunction(TFSXAllLightsFunction.Create(            Self, FSXFunctionDisplayNameAllLights,              FSXFunctionUIDAllLights));

  { Autopilot }
  RegisterFunction(TFSXAutoPilotFunction.Create(            Self, FSXFunctionDisplayNameAutoPilot,              FSXFunctionUIDAutoPilot));
  RegisterFunction(TFSXAutoPilotAltitudeFunction.Create(    Self, FSXFunctionDisplayNameAutoPilotAltitude,      FSXFunctionUIDAutoPilotAltitude));
  RegisterFunction(TFSXAutoPilotApproachFunction.Create(    Self, FSXFunctionDisplayNameAutoPilotApproach,      FSXFunctionUIDAutoPilotApproach));
  RegisterFunction(TFSXAutoPilotBackcourseFunction.Create(  Self, FSXFunctionDisplayNameAutoPilotBackcourse,    FSXFunctionUIDAutoPilotBackcourse));
  RegisterFunction(TFSXAutoPilotHeadingFunction.Create(     Self, FSXFunctionDisplayNameAutoPilotHeading,       FSXFunctionUIDAutoPilotHeading));
  RegisterFunction(TFSXAutoPilotNavFunction.Create(         Self, FSXFunctionDisplayNameAutoPilotNav,           FSXFunctionUIDAutoPilotNav));
  RegisterFunction(TFSXAutoPilotAirspeedFunction.Create(    Self, FSXFunctionDisplayNameAutoPilotAirspeed,      FSXFunctionUIDAutoPilotAirspeed));

  { Radios }
  RegisterFunction(TFSXAvionicsMasterFunction.Create(       Self, FSXFunctionDisplayNameAvionicsMaster,         FSXFunctionUIDAvionicsMaster));

  { Fuel }
  RegisterFunction(TFSXFuelFunction.Create(                 Self, FSXFunctionDisplayNameFuel,                   FSXFunctionUIDFuel));

  { ATC }
  RegisterFunction(TFSXATCVisibilityFunction.Create(FSXProviderUID));
end;
*)

function TFSXLEDFunctionProvider.CreateLuaLEDFunction(AInfo: ILuaTable; AOnSetup: ILuaFunction): TCustomLuaLEDFunction;
begin
  Result := TFSXLEDFunction.Create(Self, AInfo, AOnSetup);
end;


procedure TFSXLEDFunctionProvider.InitInterpreter;
var
  simConnectType: ILuaTable;
  typeIndex: Integer;

begin
  inherited InitInterpreter;

  Interpreter.RegisterFunctions(FScriptSimConnect, 'SimConnect');

  simConnectType := TLuaTable.Create;
  for typeIndex := Low(LuaSimConnectTypes) to High(LuaSimConnectTypes) do
    simConnectType.SetValue(LuaSimConnectTypes[typeIndex].TypeName, LuaSimConnectTypes[typeIndex].TypeName);

  Interpreter.SetGlobalVariable('SimConnectType', simConnectType);
end;


procedure TFSXLEDFunctionProvider.SetupWorker(AWorker: TFSXLEDFunctionWorker; AOnSetup: ILuaFunction);
begin
  AOnSetup.Call([AWorker.UID]);
end;


function TFSXLEDFunctionProvider.GetUID: string;
begin
  Result := FSXProviderUID;
end;


procedure TFSXLEDFunctionProvider.ObserveDestroy(Sender: IFSXSimConnect);
begin
  FSimConnectLock.Acquire;
  try
    FSimConnect := nil;
  finally
    FSimConnectLock.Release;
  end;
end;


function TFSXLEDFunctionProvider.GetSimConnect: IFSXSimConnect;
begin
  FSimConnectLock.Acquire;
  try
    if not Assigned(FSimConnect) then
    begin
      { Keep an object reference so we don't increment the reference count.
        We'll know when it's gone through the ObserveDestroy. }
      FSimConnect := TFSXSimConnectInterface.Create(TX2GlobalLog.Category('FSX SimConnect'));
      (FSimConnect as IFSXSimConnect).Attach(Self);
    end;

    Result := (FSimConnect as IFSXSimConnect);
  finally
    FSimConnectLock.Release;
  end;
end;


procedure TFSXLEDFunctionProvider.SetProfileMenu(AEnabled: Boolean; ACascaded: Boolean);
begin
  if AEnabled and (not Assigned(FProfileMenuSimConnect)) then
    FProfileMenuSimConnect := (GetSimConnect as IFSXSimConnectProfileMenu);

  if Assigned(FProfileMenuSimConnect) then
    FProfileMenuSimConnect.SetProfileMenu(AEnabled, ACascaded);

  if not AEnabled then
    FProfileMenuSimConnect := nil;
end;



{ TFSXLEDFunction }
constructor TFSXLEDFunction.Create(AProvider: TFSXLEDFunctionProvider; AInfo: ILuaTable; AOnSetup: ILuaFunction);
begin
  inherited Create(AProvider, AInfo, AOnSetup);

  FProvider := AProvider;
end;


function TFSXLEDFunction.GetDefaultCategoryName: string;
begin
  Result := FSXCategory;
end;


function TFSXLEDFunction.GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass;
begin
  Result := TFSXLEDFunctionWorker;
end;


procedure TFSXLEDFunction.InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker);
var
  worker: TFSXLEDFunctionWorker;

begin
  worker := (AWorker as TFSXLEDFunctionWorker);
  worker.Provider := Provider;

  Provider.SetupWorker(worker, Setup);
end;


{ TFSXLEDFunctionWorker }
constructor TFSXLEDFunctionWorker.Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string);
begin
  { We can't pass ourselves as the Data Handler, as it would keep a reference to
    this worker from the SimConnect interface. That'd mean the worker never
    gets destroyed, and SimConnect never shuts down. Hence this proxy class. }
  FDataHandler := TCustomFSXFunctionWorkerDataHandler.Create(Self);
  FDefinitionID := TList<Cardinal>.Create;

  inherited Create(AProviderUID, AFunctionUID, AStates, ASettings, APreviousState);
end;


destructor TFSXLEDFunctionWorker.Destroy;
var
  simConnect: IFSXSimConnect;
  id: Cardinal;

begin
  if Assigned(Provider) and (DefinitionID.Count > 0) then
  begin
    simConnect := (Provider as TFSXLEDFunctionProvider).GetSimConnect;

    for id in DefinitionID do
      simConnect.RemoveDefinition(id, DataHandler);
  end;

  FreeAndNil(FDefinitionID);

  inherited Destroy;
end;


procedure TFSXLEDFunctionWorker.AddDefinition(ADefinition: IFSXSimConnectDefinition);
begin
  DefinitionID.Add((Provider as TFSXLEDFunctionProvider).GetSimConnect.AddDefinition(ADefinition, DataHandler));
end;


{ TCustomFSXFunctionWorkerDataHandler }
constructor TCustomFSXFunctionWorkerDataHandler.Create(AWorker: TFSXLEDFunctionWorker);
begin
  inherited Create;

  FWorker := AWorker;
end;


procedure TCustomFSXFunctionWorkerDataHandler.HandleData(AData: Pointer);
begin
  Worker.HandleData(AData);
end;


{ TLuaSimConnect }
constructor TLuaSimConnect.Create(AProvider: TFSXLEDFunctionProvider);
begin
  inherited Create;

  FProvider := AProvider;
end;


procedure TLuaSimConnect.Monitor(Context: ILuaContext);
var
  workerID: string;
  variables: ILuaTable;
  onData: ILuaFunction;
  worker: TCustomLuaLEDFunctionWorker;
  definition: IFSXSimConnectDefinition;
  variable: TLuaKeyValuePair;
  info: ILuaTable;
  units: string;
  dataType: SIMCONNECT_DATAType;

begin
  if Context.Parameters.Count < 3 then
    raise ELuaScriptError.Create('Not enough parameters for SimConnect.Monitor');

  if Context.Parameters[0].VariableType <> VariableString then
    raise ELuaScriptError.Create('Context expected for SimConnect.Monitor parameter 1');

  if Context.Parameters[1].VariableType <> VariableTable then
    raise ELuaScriptError.Create('Table expected for SimConnect.Monitor parameter 2');

  if Context.Parameters[2].VariableType <> VariableFunction then
    raise ELuaScriptError.Create('Function expected for SimConnect.Monitor parameter 3');

  workerID := Context.Parameters[0].AsString;
  variables := Context.Parameters[1].AsTable;
  onData := Context.Parameters[2].AsFunction;

  worker := Provider.FindWorker(workerID);
  if not Assigned(worker) then
    raise ELuaScriptError.Create('Context expected for SimConnect.Monitor parameter 1');

  definition := Provider.GetSimConnect.CreateDefinition;

  for variable in variables do
  begin
    if variable.Value.VariableType = VariableTable then
    begin
      info := variable.Value.AsTable;
      if info.HasValue('variable') and
         info.HasValue('type') and
         GetUnits(info.GetValue('type').AsString, units, dataType) then
      begin
        definition.AddVariable(info.GetValue('variable').AsString, units, dataType);
      end;
    end;
  end;

  (worker as TFSXLEDFunctionWorker).AddDefinition(definition);
end;

end.

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
  protected
    function GetUID: string; override;
    function CreateLuaLEDFunction(AInfo: ILuaTable; AOnSetup: ILuaFunction): TCustomLuaLEDFunction; override;

    procedure InitInterpreter; override;
    procedure ScriptOnSimConnect(Context: ILuaContext);
    procedure ScriptFSXWindowVisible(Context: ILuaContext);

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

  TFSXDefinition = record
    ID: Cardinal;
    DataHandler: IFSXSimConnectDataHandler;
  end;

  TFSXLEDFunctionWorker = class(TCustomLuaLEDFunctionWorker)
  private
    FDefinitions: TList<TFSXDefinition>;
  protected
    property Definitions: TList<TFSXDefinition> read FDefinitions;
  protected
    procedure AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);

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
  TLuaSimConnectDataType = (
                             // Native types
                             Float64, Float32, Int64, Int32, StringValue,

                             // Preprocessed types (for scripting convenience)
                             Bool,

                             // Structures
                             XYZ, LatLonAlt, Waypoint
                           );


  TLuaSimConnectVariable = record
    Name: string;
    DataType: TLuaSimConnectDataType;
  end;


  TFSXFunctionWorkerDataHandler = class(TInterfacedObject, IFSXSimConnectDataHandler)
  private
    FOnData: ILuaFunction;
    FWorkerID: string;
    FVariables: TList<TLuaSimConnectVariable>;
  protected
    { IFSXSimConnectDataHandler }
    procedure HandleData(AData: Pointer);

    property OnData: ILuaFunction read FOnData;
    property Variables: TList<TLuaSimConnectVariable> read FVariables;
    property WorkerID: string read FWorkerID;
  public
    constructor Create(AVariables: TList<TLuaSimConnectVariable>; const AWorkerID: string; AOnData: ILuaFunction);
    destructor Destroy; override;
  end;


const
  LuaSimConnectDataTypes: array[TLuaSimConnectDataType] of string =
                          (
                            'Float64', 'Float32', 'Int64', 'Int32', 'String',
                            'Bool',
                            'XYZ', 'LatLonAlt', 'Waypoint'
                          );


function GetDataType(const ATypeName: string; out ADataType: TLuaSimConnectDataType): Boolean;
var
  dataType: TLuaSimConnectDataType;

begin
  for dataType := Low(TLuaSimConnectDataType) to High(TLuaSimConnectDataType) do
    if SameText(ATypeName, LuaSimConnectDataTypes[dataType]) then
    begin
      ADataType := dataType;
      Exit(True);
    end;

  Result := False;
end;


{ TFSXLEDFunctionProvider }
constructor TFSXLEDFunctionProvider.Create(const AScriptFolders: TStringDynArray);
begin
  FSimConnectLock := TCriticalSection.Create;

  inherited Create(AScriptFolders);
end;


destructor TFSXLEDFunctionProvider.Destroy;
begin
  inherited Destroy;

  FreeAndNil(FSimConnectLock);
end;


function TFSXLEDFunctionProvider.CreateLuaLEDFunction(AInfo: ILuaTable; AOnSetup: ILuaFunction): TCustomLuaLEDFunction;
begin
  Result := TFSXLEDFunction.Create(Self, AInfo, AOnSetup);
end;


procedure TFSXLEDFunctionProvider.InitInterpreter;
var
  simConnectDataType: ILuaTable;
  dataType: TLuaSimConnectDataType;

begin
  inherited InitInterpreter;

  Interpreter.RegisterFunction('OnSimConnect', ScriptOnSimConnect);
  Interpreter.RegisterFunction('FSXWindowVisible', ScriptFSXWindowVisible);

  simConnectDataType := TLuaTable.Create;
  for dataType := Low(TLuaSimConnectDataType) to High(TLuaSimConnectDataType) do
    simConnectDataType.SetValue(LuaSimConnectDataTypes[dataType], LuaSimConnectDataTypes[dataType]);

  Interpreter.SetGlobalVariable('SimConnectDataType', simConnectDataType);
end;


procedure TFSXLEDFunctionProvider.ScriptOnSimConnect(Context: ILuaContext);
var
  workerID: string;
  variables: ILuaTable;
  onData: ILuaFunction;
  worker: TCustomLuaLEDFunctionWorker;
  definition: IFSXSimConnectDefinition;
  variable: TLuaKeyValuePair;
  info: ILuaTable;
  dataType: TLuaSimConnectDataType;
  simConnectDataType: SIMCONNECT_DATAType;
  units: string;
  luaVariables: TList<TLuaSimConnectVariable>;
  luaVariable: TLuaSimConnectVariable;

begin
  CheckParameters('OnSimConnect', Context.Parameters, [VariableString, VariableTable, VariableFunction]);

  workerID := Context.Parameters[0].AsString;
  variables := Context.Parameters[1].AsTable;
  onData := Context.Parameters[2].AsFunction;

  worker := FindWorker(workerID);
  if not Assigned(worker) then
    raise ELuaScriptError.Create('OnSimConnect: invalid context');

  definition := GetSimConnect.CreateDefinition;

  luaVariables := TList<TLuaSimConnectVariable>.Create;
  try
    for variable in variables do
    begin
      if variable.Value.VariableType = VariableTable then
      begin
        info := variable.Value.AsTable;
        if info.HasValue('variable') then
        begin
          luaVariable.Name := variable.Key.AsString;
          units := '';
          simConnectDataType := SIMCONNECT_DATAType_FLOAT64;

          if info.HasValue('type') and GetDataType(info.GetValue('type').AsString, dataType) then
          begin
            luaVariable.DataType := dataType;

            case dataType of
              Float32: simConnectDataType := SIMCONNECT_DATAType_FLOAT32;
              Int64: simConnectDataType := SIMCONNECT_DATAType_INT64;
              Int32,
              Bool:
                begin
                  simConnectDataType := SIMCONNECT_DATAType_INT32;
                  units := 'bool';
                end;

              // TODO change to STRINGV
              StringValue: simConnectDataType := SIMCONNECT_DATAType_STRING256;
              XYZ: simConnectDataType := SIMCONNECT_DATAType_XYZ;
              LatLonAlt: simConnectDataType := SIMCONNECT_DATAType_LATLONALT;
              Waypoint: simConnectDataType := SIMCONNECT_DATAType_WAYPOINT;
            end;

            if info.HasValue('units') then
              units := info.GetValue('units').AsString
            else if not (dataType in [Bool, StringValue, XYZ, LatLonAlt, Waypoint]) then
              raise ELuaScriptError.CreateFmt('OnSimConnect: missing units for variable %s', [variable.Key.AsString]);
          end else
          begin
            if not info.HasValue('units') then
              raise ELuaScriptError.CreateFmt('OnSimConnect: missing units or type for variable %s', [variable.Key.AsString]);

            units := info.GetValue('units').AsString;
          end;

          luaVariables.Add(luaVariable);
          definition.AddVariable(info.GetValue('variable').AsString, units, simConnectDataType);
        end;
      end;
    end;

    (worker as TFSXLEDFunctionWorker).AddDefinition(definition, TFSXFunctionWorkerDataHandler.Create(luaVariables, worker.UID, onData));
  finally
    FreeAndNil(luaVariables);
  end;
end;


procedure TFSXLEDFunctionProvider.ScriptFSXWindowVisible(Context: ILuaContext);
const
  ClassNameMainWindow = 'FS98MAIN';
  ClassNameChildWindow = 'FS98CHILD';
  ClassNameFloatWindow = 'FS98FLOAT';

var
  windowTitle: string;

begin
  CheckParameters('FSXWindowVisible', Context.Parameters, [VariableString]);
  windowTitle := Context.Parameters[0].AsString;

  Context.Result.Push(
    { Docked }
    WindowVisible(ClassNameChildWindow, windowTitle, ClassNameMainWindow, '') or

    { Undocked }
    WindowVisible(ClassNameFloatWindow, windowTitle, '', ''));
end;


// #ToDo1 -oMvR: 4-6-2017: move up to LuaLEDFunctionProvider
procedure TFSXLEDFunctionProvider.SetupWorker(AWorker: TFSXLEDFunctionWorker; AOnSetup: ILuaFunction);
begin
  try
    AOnSetup.Call([AWorker.UID]);
  except
    on E:Exception do
      TX2GlobalLog.Category('Lua').Exception(E);
  end;
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
  FDefinitions := TList<TFSXDefinition>.Create;

  inherited Create(AProviderUID, AFunctionUID, AStates, ASettings, APreviousState);
end;


destructor TFSXLEDFunctionWorker.Destroy;
var
  simConnect: IFSXSimConnect;
  definition: TFSXDefinition;

begin
  if Assigned(Provider) and (Definitions.Count > 0) then
  begin
    simConnect := (Provider as TFSXLEDFunctionProvider).GetSimConnect;

    for definition in Definitions do
      simConnect.RemoveDefinition(definition.ID, definition.DataHandler);
  end;

  FreeAndNil(FDefinitions);

  inherited Destroy;
end;


procedure TFSXLEDFunctionWorker.AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);
var
  definition: TFSXDefinition;

begin
  definition.DataHandler := ADataHandler;
  definition.ID := (Provider as TFSXLEDFunctionProvider).GetSimConnect.AddDefinition(ADefinition, ADataHandler);

  Definitions.Add(definition);
end;


{ TFSXFunctionWorkerDataHandler }
constructor TFSXFunctionWorkerDataHandler.Create(AVariables: TList<TLuaSimConnectVariable>; const AWorkerID: string; AOnData: ILuaFunction);
begin
  inherited Create;

  FWorkerID := AWorkerID;
  FOnData := AOnData;

  FVariables := TList<TLuaSimConnectVariable>.Create;
  FVariables.AddRange(AVariables);
end;


destructor TFSXFunctionWorkerDataHandler.Destroy;
begin
  FreeAndNil(FVariables);

  inherited Destroy;
end;


procedure TFSXFunctionWorkerDataHandler.HandleData(AData: Pointer);
var
  data: ILuaTable;
  dataPointer: PByte;
  variableIndex: Integer;
  variable: TLuaSimConnectVariable;
  value: string;
  structure: ILuaTable;
  flags: ILuaTable;
  xyzData: ^SIMCONNECT_DATA_XYZ;
  latLonAltData: ^SIMCONNECT_DATA_LATLONALT;
  waypointData: ^SIMCONNECT_DATA_WAYPOINT;

begin
  data := TLuaTable.Create;
  dataPointer := AData;

  for variableIndex := 0 to Pred(Variables.Count) do
  begin
    variable := Variables[variableIndex];

    case variable.DataType of
      Float64:
        begin
          data.SetValue(variable.Name, PDouble(dataPointer)^);
          Inc(dataPointer, SizeOf(Double));
        end;

      Float32:
        begin
          data.SetValue(variable.Name, PSingle(dataPointer)^);
          Inc(dataPointer, SizeOf(Single));
        end;

      Int64:
        begin
          data.SetValue(variable.Name, PInt64(dataPointer)^);
          Inc(dataPointer, SizeOf(Int64));
        end;

      Int32:
        begin
          data.SetValue(variable.Name, PInteger(dataPointer)^);
          Inc(dataPointer, SizeOf(Integer));
        end;

      StringValue:
        begin
          // TODO change to STRINGV
          //SimConnect_RetrieveString()

          SetString(value, PChar(dataPointer), 256);
          data.SetValue(variable.Name, value);

          Inc(dataPointer, 256);
        end;

      Bool:
        begin
          data.SetValue(variable.Name, (PInteger(dataPointer)^ <> 0));
          Inc(dataPointer, SizeOf(Integer));
        end;

      XYZ:
        begin
          xyzData := AData;

          structure := TLuaTable.Create;
          structure.SetValue('X', xyzData^.x);
          structure.SetValue('Y', xyzData^.y);
          structure.SetValue('Z', xyzData^.z);

          data.SetValue(variable.Name, structure);
          Inc(dataPointer, SizeOf(SIMCONNECT_DATA_XYZ));
        end;

      LatLonAlt:
        begin
          latLonAltData := AData;

          structure := TLuaTable.Create;
          structure.SetValue('Latitude', latLonAltData^.Latitude);
          structure.SetValue('Longitude', latLonAltData^.Longitude);
          structure.SetValue('Altitude', latLonAltData^.Altitude);

          data.SetValue(variable.Name, structure);
          Inc(dataPointer, SizeOf(SIMCONNECT_DATA_LATLONALT));
        end;

      Waypoint:
        begin
          waypointData := AData;

          structure := TLuaTable.Create;
          structure.SetValue('Latitude', waypointData^.Latitude);
          structure.SetValue('Longitude', waypointData^.Longitude);
          structure.SetValue('Altitude', waypointData^.Altitude);
          structure.SetValue('KtsSpeed', waypointData^.ktsSpeed);
          structure.SetValue('PercentThrottle', waypointData^.percentThrottle);

          flags := TLuaTable.Create;
          flags.SetValue('SpeedRequested', (waypointData^.Flags and SIMCONNECT_WAYPOINT_SPEED_REQUESTED) <> 0);
          flags.SetValue('ThrottleRequested', (waypointData^.Flags and SIMCONNECT_WAYPOINT_THROTTLE_REQUESTED) <> 0);
          flags.SetValue('ComputeVerticalSpeed', (waypointData^.Flags and SIMCONNECT_WAYPOINT_COMPUTE_VERTICAL_SPEED) <> 0);
          flags.SetValue('IsAGL', (waypointData^.Flags and SIMCONNECT_WAYPOINT_ALTITUDE_IS_AGL) <> 0);
          flags.SetValue('OnGround', (waypointData^.Flags and SIMCONNECT_WAYPOINT_ON_GROUND) <> 0);
          flags.SetValue('Reverse', (waypointData^.Flags and SIMCONNECT_WAYPOINT_REVERSE) <> 0);
          flags.SetValue('WrapToFirst', (waypointData^.Flags and SIMCONNECT_WAYPOINT_WRAP_TO_FIRST) <> 0);

          structure.SetValue('Flags', flags);

          data.SetValue(variable.Name, structure);
          Inc(dataPointer, SizeOf(SIMCONNECT_DATA_WAYPOINT));
        end;
    end;
  end;

  try
    OnData.Call([WorkerID, data]);
  except
    on E:Exception do
      TX2GlobalLog.Category('Lua').Exception(E);
  end;
end;

end.

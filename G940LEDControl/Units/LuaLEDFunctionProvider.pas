unit LuaLEDFunctionProvider;

interface
uses
  System.Generics.Collections,
  System.SysUtils,
  System.Types,

  LEDFunction,
  LEDFunctionIntf,
  LEDStateIntf,
  Lua;

type
  ELuaScriptError = class(Exception);

  TCustomLuaLEDFunctionWorker = class;


  TCustomLuaLEDFunction = class(TCustomMultiStateLEDFunction)
  private
    FCategoryName: string;
    FDisplayName: string;
    FUID: string;
    FScriptStates: ILuaTable;
    FSetup: ILuaFunction;
  protected
    procedure RegisterStates; override;

    function GetDefaultCategoryName: string; virtual;

    { ILEDFunction }
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;

    property ScriptStates: ILuaTable read FScriptStates;
    property Setup: ILuaFunction read FSetup;
  public
    constructor Create(AProvider: ILEDFunctionProvider; AInfo: ILuaTable; ASetup: ILuaFunction);
  end;


  TCustomLuaLEDFunctionProvider = class(TCustomLEDFunctionProvider)
  private
    FInterpreter: TLua;
    FScriptFolders: TStringDynArray;
    FWorkers: TDictionary<string, TCustomLuaLEDFunctionWorker>;
    FScriptLog: TObject;
  protected
    function CreateLuaLEDFunction(AInfo: ILuaTable; ASetup: ILuaFunction): TCustomLuaLEDFunction; virtual; abstract;

    procedure ScriptRegisterFunction(Context: ILuaContext);
    procedure ScriptSetState(Context: ILuaContext);

    procedure InitInterpreter; virtual;
    procedure RegisterFunctions; override;

    procedure RegisterWorker(AWorker: TCustomLuaLEDFunctionWorker);
    procedure UnregisterWorker(AWorker: TCustomLuaLEDFunctionWorker);
    function FindWorker(const AUID: string): TCustomLuaLEDFunctionWorker;

    property Interpreter: TLua read FInterpreter;
    property ScriptFolders: TStringDynArray read FScriptFolders;
    property Workers: TDictionary<string, TCustomLuaLEDFunctionWorker> read FWorkers;
  public
    constructor Create(const AScriptFolders: TStringDynArray);
    destructor Destroy; override;
  end;


  TCustomLuaLEDFunctionWorker = class(TCustomLEDMultiStateFunctionWorker)
  private
    FProvider: TCustomLuaLEDFunctionProvider;
    FUID: string;

    procedure SetProvider(const Value: TCustomLuaLEDFunctionProvider);
  protected
    property Provider: TCustomLuaLEDFunctionProvider read FProvider write SetProvider;
  public
    constructor Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''); override;
    destructor Destroy; override;

    property UID: string read FUID;
  end;


implementation
uses
  System.Classes,
  System.IOUtils,

  Lua.API,
  X2Log.Intf,
  X2Log.Global,

  LEDColorIntf,
  LEDState;


type
  TLuaLog = class(TPersistent)
  private
    FInterpreter: TLua;
  protected
    procedure AppendVariable(ABuilder: TStringBuilder; AVariable: ILuaVariable);
    procedure AppendTable(ABuilder: TStringBuilder; ATable: ILuaTable);

    procedure Log(AContext: ILuaContext; ALevel: TX2LogLevel);

    property Interpreter: TLua read FInterpreter;
  public
    constructor Create(AInterpreter: TLua);
  published
    procedure Verbose(Context: ILuaContext);
    procedure Info(Context: ILuaContext);
    procedure Warning(Context: ILuaContext);
    procedure Error(Context: ILuaContext);
  end;


const
  LuaLEDColors: array[TLEDColor] of string =
                (
                  'Off', 'Green', 'Amber', 'Red',
                  'FlashingGreenFast', 'FlashingGreenNormal',
                  'FlashingAmberFast', 'FlashingAmberNormal',
                  'FlashingRedFast', 'FlashingRedNormal'
                );


function GetLEDColor(const AValue: string; ADefault: TLEDColor = lcOff): TLEDColor;
var
  color: TLEDColor;

begin
  for color := Low(TLEDColor) to High(TLEDColor) do
    if SameText(AValue, LuaLEDColors[color]) then
      exit(color);

  Result := ADefault;
end;



{ TCustomLuaLEDFunctionProvider }
constructor TCustomLuaLEDFunctionProvider.Create(const AScriptFolders: TStringDynArray);
begin
  FWorkers := TDictionary<string, TCustomLuaLEDFunctionWorker>.Create;
  FInterpreter := TLua.Create;
  FScriptFolders := AScriptFolders;
  FScriptLog := TLuaLog.Create(FInterpreter);

  InitInterpreter;

  inherited Create;
end;


destructor TCustomLuaLEDFunctionProvider.Destroy;
begin
  FreeAndNil(FInterpreter);
  FreeAndNil(FScriptLog);
  FreeAndNil(FWorkers);

  inherited Destroy;
end;


procedure TCustomLuaLEDFunctionProvider.InitInterpreter;
var
  table: ILuaTable;
  color: TLEDColor;

begin
  Interpreter.RegisterFunction('RegisterFunction', ScriptRegisterFunction);
  Interpreter.RegisterFunction('SetState', ScriptSetState);

  Interpreter.RegisterFunctions(FScriptLog, 'Log');

  table := TLuaTable.Create;
  for color := Low(TLEDColor) to High(TLEDColor) do
    table.SetValue(LuaLEDColors[color], LuaLEDColors[color]);

  Interpreter.SetGlobalVariable('LEDColor', table);

  // #ToDo1 -oMvR: 29-5-2017: Timer
  // #ToDo1 -oMvR: 29-5-2017: FindWindow / FindFSXWindow
end;


procedure TCustomLuaLEDFunctionProvider.ScriptRegisterFunction(Context: ILuaContext);
var
  info: ILuaTable;
  setup: ILuaFunction;

begin
  if Context.Parameters.Count < 2 then
    raise ELuaScriptError.Create('Not enough parameters for RegisterFunction');

  if Context.Parameters[0].VariableType <> VariableTable then
    raise ELuaScriptError.Create('Table expected for RegisterFunction parameter 1');

  if Context.Parameters[1].VariableType <> VariableFunction then
    raise ELuaScriptError.Create('Function expected for RegisterFunction parameter 2');

  info := Context.Parameters[0].AsTable;
  setup := Context.Parameters[1].AsFunction;

  if not info.HasValue('uid') then
    raise ELuaScriptError.Create('"uid" value is required for RegisterFunction parameter 1');

  RegisterFunction(CreateLuaLEDFunction(info, setup));
end;


procedure TCustomLuaLEDFunctionProvider.ScriptSetState(Context: ILuaContext);
var
  workerID: string;
  worker: TCustomLuaLEDFunctionWorker;
  stateUID: string;

begin
  if Context.Parameters.Count < 2 then
    raise ELuaScriptError.Create('Not enough parameters for SetState');

  if Context.Parameters[0].VariableType <> VariableString then
    raise ELuaScriptError.Create('Context expected for SetState parameter 1');

  if Context.Parameters[1].VariableType <> VariableString then
    raise ELuaScriptError.Create('State expected for SetState parameter 2');

  workerID := Context.Parameters[0].AsString;
  stateUID := Context.Parameters[1].AsString;

  worker := FindWorker(workerID);
  if not Assigned(worker) then
    raise ELuaScriptError.Create('Context expected for SetState parameter 1');

  worker.SetCurrentState(stateUID);
end;


procedure TCustomLuaLEDFunctionProvider.RegisterFunctions;
var
  scriptFolder: string;
  scriptFile: string;

begin
  for scriptFolder in ScriptFolders do
    if TDirectory.Exists(scriptFolder) then
      for scriptFile in TDirectory.GetFiles(ScriptFolder, '*.lua') do
      try
        Interpreter.LoadFromFile(scriptFile);
      except
        on E:Exception do
          Exception.RaiseOuterException(ELuaScriptError.CreateFmt('Error while loading script %s: %s', [scriptFile, E.Message]));
      end;
end;


procedure TCustomLuaLEDFunctionProvider.RegisterWorker(AWorker: TCustomLuaLEDFunctionWorker);
begin
  Workers.Add(AWorker.UID, AWorker);
end;


procedure TCustomLuaLEDFunctionProvider.UnregisterWorker(AWorker: TCustomLuaLEDFunctionWorker);
begin
  Workers.Remove(AWorker.UID);
end;


function TCustomLuaLEDFunctionProvider.FindWorker(const AUID: string): TCustomLuaLEDFunctionWorker;
begin
  if not Workers.TryGetValue(AUID, Result) then
    Result := nil;
end;



{ TCustomLuaLEDFunction }
constructor TCustomLuaLEDFunction.Create(AProvider: ILEDFunctionProvider; AInfo: ILuaTable; ASetup: ILuaFunction);
begin
  FCategoryName := GetDefaultCategoryName;
  FDisplayName := 'Unknown function';
  FSetup := ASetup;

  FUID := AInfo.GetValue('uid').AsString;

  if AInfo.HasValue('category') then
    FCategoryName := AInfo.GetValue('category').AsString;

  if AInfo.HasValue('displayName') then
    FDisplayName := AInfo.GetValue('displayName').AsString;

  FScriptStates := nil;
  if AInfo.HasValue('states') then
    FScriptStates := AInfo.GetValue('states').AsTable;

  // #ToDo1 -oMvR: 28-5-2017: application filter?

  inherited Create(AProvider.GetUID);
end;


function TCustomLuaLEDFunction.GetCategoryName: string;
begin
  Result := FCategoryName;
end;


function TCustomLuaLEDFunction.GetDisplayName: string;
begin
  Result := FDisplayName;
end;


function TCustomLuaLEDFunction.GetUID: string;
begin
  Result := FUID;
end;


procedure TCustomLuaLEDFunction.RegisterStates;
var
  state: TLuaKeyValuePair;
  displayName: string;
  defaultColor: TLEDColor;
  info: ILuaTable;

begin
  if not Assigned(ScriptStates) then
    exit;

  for state in ScriptStates do
  begin
    displayName := state.Key.AsString;
    defaultColor := lcOff;

    if state.Value.VariableType = VariableTable then
    begin
      info := state.Value.AsTable;
      if info.HasValue('displayName') then
        displayName := info.GetValue('displayName').AsString;

      if info.HasValue('default') then
        defaultColor := GetLEDColor(info.GetValue('default').AsString);
    end;

    RegisterState(TLEDState.Create(state.Key.AsString, displayName, defaultColor));
  end;
end;


function TCustomLuaLEDFunction.GetDefaultCategoryName: string;
begin
  Result := 'Other';
end;


{ TCustomLuaLEDFunctionWorker }
constructor TCustomLuaLEDFunctionWorker.Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string);
var
  workerGUID: TGUID;

begin
  if CreateGUID(workerGUID) <> 0 then
    RaiseLastOSError;

  FUID := GUIDToString(workerGUID);

  inherited Create(AProviderUID, AFunctionUID, AStates, ASettings, APreviousState);
end;

destructor TCustomLuaLEDFunctionWorker.Destroy;
begin
  SetProvider(nil);

  inherited Destroy;
end;


procedure TCustomLuaLEDFunctionWorker.SetProvider(const Value: TCustomLuaLEDFunctionProvider);
begin
  if Value <> FProvider then
  begin
    if Assigned(FProvider) then
      FProvider.UnregisterWorker(Self);

    FProvider := Value;

    if Assigned(FProvider) then
      FProvider.RegisterWorker(Self);
  end;
end;


{ TLuaLog }
constructor TLuaLog.Create(AInterpreter: TLua);
begin
  inherited Create;

  FInterpreter := AInterpreter;
end;


procedure TLuaLog.AppendVariable(ABuilder: TStringBuilder; AVariable: ILuaVariable);
begin
  case AVariable.VariableType of
    VariableBoolean:
      if AVariable.AsBoolean then
        ABuilder.Append('true')
      else
        ABuilder.Append('false');

    VariableTable:
      AppendTable(ABuilder, AVariable.AsTable);
  else
    ABuilder.Append(AVariable.AsString);
  end;
end;


procedure TLuaLog.AppendTable(ABuilder: TStringBuilder; ATable: ILuaTable);
var
  firstItem: Boolean;
  item: TLuaKeyValuePair;

begin
  ABuilder.Append('{ ');
  firstItem := True;

  for item in ATable do
  begin
    if firstItem then
      firstItem := False
    else
      ABuilder.Append(', ');

    AppendVariable(ABuilder, item.Key);
    ABuilder.Append(' = ');
    AppendVariable(ABuilder, item.Value);
  end;

  ABuilder.Append(' }');
end;


procedure TLuaLog.Log(AContext: ILuaContext; ALevel: TX2LogLevel);
var
  debug: lua_Debug;
  fileName: string;
  msg: TStringBuilder;
  parameter: ILuaVariable;

begin
  fileName := 'Lua';

  if Interpreter.HasState and (lua_getstack(Interpreter.State, 1, debug) <> 0) then
  begin
    lua_getinfo(Interpreter.State, 'Sl', debug);
    fileName := fileName + ' - ' + string(debug.source)
  end;

  msg := TStringBuilder.Create;
  try
    for parameter in AContext.Parameters do
    begin
      AppendVariable(msg, parameter);
      msg.Append(' ');
    end;

    TX2GlobalLog.Log(ALevel, msg.ToString, fileName);
  finally
    FreeAndNil(msg);
  end;
end;


procedure TLuaLog.Verbose(Context: ILuaContext);
begin
  Log(Context, TX2LogLevel.Verbose);
end;


procedure TLuaLog.Info(Context: ILuaContext);
begin
  Log(Context, TX2LogLevel.Info);
end;


procedure TLuaLog.Warning(Context: ILuaContext);
begin
  Log(Context, TX2LogLevel.Warning);
end;


procedure TLuaLog.Error(Context: ILuaContext);
begin
  Log(Context, TX2LogLevel.Error);
end;

end.

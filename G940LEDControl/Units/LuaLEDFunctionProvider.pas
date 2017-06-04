unit LuaLEDFunctionProvider;

interface
uses
  System.Generics.Collections,
  System.SysUtils,
  System.Types,

  OtlTask,
  OtlTaskControl,
  X2Log.Intf,

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

    procedure CheckParameters(const AFunctionName: string; AParameters: ILuaReadParameters; AExpectedTypes: array of TLuaVariableType);
    procedure AppendVariable(ABuilder: TStringBuilder; AVariable: ILuaVariable);
    procedure AppendTable(ABuilder: TStringBuilder; ATable: ILuaTable);

    procedure DoLog(AContext: ILuaContext; ALevel: TX2LogLevel);
    procedure DoLogMessage(AContext: ILuaContext; ALevel: TX2LogLevel; const AMessage: string);

    procedure ScriptRegisterFunction(Context: ILuaContext);
    procedure ScriptSetState(Context: ILuaContext);
    procedure ScriptOnTimer(Context: ILuaContext);
    procedure ScriptWindowVisible(Context: ILuaContext);

    function WindowVisible(const AClassName, AWindowTitle, AParentClassName, AParentWindowTitle: string): Boolean;

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
    FTasks: TList<IOmniTaskControl>;

    procedure SetProvider(const Value: TCustomLuaLEDFunctionProvider);
  protected
    procedure AddTask(ATask: IOmniTaskControl);

    property Provider: TCustomLuaLEDFunctionProvider read FProvider write SetProvider;
    property Tasks: TList<IOmniTaskControl> read FTasks;
  public
    constructor Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''); override;
    destructor Destroy; override;

    property UID: string read FUID;
  end;


implementation
uses
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  Winapi.Windows,

  Lua.API,
  X2Log.Global,

  LEDColorIntf,
  LEDState;


type
  TLuaLogProc = reference to procedure(AContext: ILuaContext; ALevel: TX2LogLevel);

  TLuaLog = class(TPersistent)
  private
    FOnLog: TLuaLogProc;
  protected
    property OnLog: TLuaLogProc read FOnLog;
  public
    constructor Create(AOnLog: TLuaLogProc);
  published
    procedure Verbose(Context: ILuaContext);
    procedure Info(Context: ILuaContext);
    procedure Warning(Context: ILuaContext);
    procedure Error(Context: ILuaContext);
  end;


  TLuaTimerTask = class(TOmniWorker)
  private
    FOnTimer: TProc;
  protected
    property OnTimer: TProc read FOnTimer;
  public
    constructor Create(AOnTimer: TProc);

    procedure Run;
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
  FScriptLog := TLuaLog.Create(DoLog);

  InitInterpreter;

  inherited Create;
end;


destructor TCustomLuaLEDFunctionProvider.Destroy;
begin
  inherited Destroy;

  FreeAndNil(FInterpreter);
  FreeAndNil(FScriptLog);
  FreeAndNil(FWorkers);
end;


procedure TCustomLuaLEDFunctionProvider.InitInterpreter;
var
  requirePath: TStringBuilder;
  scriptFolder: string;
  table: ILuaTable;
  color: TLEDColor;

begin
  requirePath := TStringBuilder.Create;
  try
    for scriptFolder in ScriptFolders do
    begin
      if requirePath.Length > 0 then
        requirePath.Append(';');

      requirePath.Append(IncludeTrailingPathDelimiter(scriptFolder)).Append('?;')
                 .Append(IncludeTrailingPathDelimiter(scriptFolder)).Append('?.lua');
    end;

    Interpreter.SetRequirePath(requirePath.ToString);
    Interpreter.GetRequirePath;
  finally
    FreeAndNil(requirePath);
  end;

  Interpreter.RegisterFunction('RegisterFunction', ScriptRegisterFunction);
  Interpreter.RegisterFunction('SetState', ScriptSetState);
  Interpreter.RegisterFunction('OnTimer', ScriptOnTimer);
  Interpreter.RegisterFunction('WindowVisible', ScriptWindowVisible);

  Interpreter.RegisterFunctions(FScriptLog, 'Log');

  table := TLuaTable.Create;
  for color := Low(TLEDColor) to High(TLEDColor) do
    table.SetValue(LuaLEDColors[color], LuaLEDColors[color]);

  Interpreter.SetGlobalVariable('LEDColor', table);
end;


procedure TCustomLuaLEDFunctionProvider.CheckParameters(const AFunctionName: string; AParameters: ILuaReadParameters; AExpectedTypes: array of TLuaVariableType);
const
  VariableTypeName: array[TLuaVariableType] of string =
                    (
                      'None', 'Boolean', 'Integer',
                      'Number', 'UserData', 'String',
                      'Table', 'Function'
                    );

var
  parameterIndex: Integer;

begin
  if AParameters.Count < Length(AExpectedTypes) then
    raise ELuaScriptError.CreateFmt('%s: expected at least %d parameter%s', [AFunctionName, Length(AExpectedTypes), IfThen(Length(AExpectedTypes) <> 1, 's', '')]);

  for parameterIndex := 0 to High(AExpectedTypes) do
    if AParameters[parameterIndex].VariableType <> AExpectedTypes[parameterIndex] then
      raise ELuaScriptError.CreateFmt('%s: expected %s for parameter %d, got %s',
                                      [AFunctionName, VariableTypeName[AExpectedTypes[parameterIndex]],
                                       Succ(parameterIndex), VariableTypeName[AParameters[parameterIndex].VariableType]]);
end;


procedure TCustomLuaLEDFunctionProvider.AppendVariable(ABuilder: TStringBuilder; AVariable: ILuaVariable);
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


procedure TCustomLuaLEDFunctionProvider.AppendTable(ABuilder: TStringBuilder; ATable: ILuaTable);
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


procedure TCustomLuaLEDFunctionProvider.DoLog(AContext: ILuaContext; ALevel: TX2LogLevel);
var
  msg: TStringBuilder;
  parameter: ILuaVariable;

begin
  msg := TStringBuilder.Create;
  try
    for parameter in AContext.Parameters do
    begin
      AppendVariable(msg, parameter);
      msg.Append(' ');
    end;

    DoLogMessage(AContext, ALevel, msg.ToString);
  finally
    FreeAndNil(msg);
  end;
end;


procedure TCustomLuaLEDFunctionProvider.DoLogMessage(AContext: ILuaContext; ALevel: TX2LogLevel; const AMessage: string);
var
  debug: lua_Debug;
  fileName: string;

begin
  fileName := 'Lua';

  if Interpreter.HasState and (lua_getstack(Interpreter.State, 1, debug) <> 0) then
  begin
    lua_getinfo(Interpreter.State, 'Sl', debug);
    fileName := fileName + ' - ' + string(debug.source)
  end;

  TX2GlobalLog.Log(ALevel, AMessage, filename);
end;


procedure TCustomLuaLEDFunctionProvider.ScriptRegisterFunction(Context: ILuaContext);
var
  info: ILuaTable;
  setup: ILuaFunction;

begin
  CheckParameters('RegisterFunction', Context.Parameters, [VariableTable, VariableFunction]);

  info := Context.Parameters[0].AsTable;
  setup := Context.Parameters[1].AsFunction;

  if not info.HasValue('uid') then
    raise ELuaScriptError.Create('RegisterFunction: "uid" value is required');

  DoLogMessage(Context, TX2LogLevel.Info, Format('Registering function: %s', [info.GetValue('uid').AsString]));
  RegisterFunction(CreateLuaLEDFunction(info, setup));
end;


procedure TCustomLuaLEDFunctionProvider.ScriptSetState(Context: ILuaContext);
var
  workerID: string;
  worker: TCustomLuaLEDFunctionWorker;
  stateUID: string;

begin
  CheckParameters('SetState', Context.Parameters, [VariableString, VariableString]);

  workerID := Context.Parameters[0].AsString;
  stateUID := Context.Parameters[1].AsString;

  worker := FindWorker(workerID);
  if not Assigned(worker) then
    raise ELuaScriptError.Create('SetState: invalid context');

  DoLogMessage(Context, TX2LogLevel.Info, Format('Setting state for %s to: %s', [worker.GetFunctionUID, stateUID]));
  worker.SetCurrentState(stateUID);
end;


procedure TCustomLuaLEDFunctionProvider.ScriptOnTimer(Context: ILuaContext);
var
  workerID: string;
  interval: Integer;
  timerCallback: ILuaFunction;
  worker: TCustomLuaLEDFunctionWorker;

begin
  CheckParameters('OnTimer', Context.Parameters, [VariableString, VariableNumber, VariableFunction]);

  workerID := Context.Parameters[0].AsString;
  interval := Context.Parameters[1].AsInteger;
  timerCallback := Context.Parameters[2].AsFunction;

  worker := FindWorker(workerID);
  if not Assigned(worker) then
    raise ELuaScriptError.Create('OnTimer: invalid context');

  DoLogMessage(Context, TX2LogLevel.Info, Format('Adding timer for %s, interval: %d', [worker.GetFunctionUID, interval]));
  worker.AddTask(CreateTask(TLuaTimerTask.Create(
    procedure
    begin
      try
        timerCallback.Call([workerID]);
      except
        on E:Exception do
          TX2GlobalLog.Category('Lua').Exception(E);
      end;
    end))
    .SetTimer(1, MSecsPerSec, @TLuaTimerTask.Run)
    .Run);
end;


procedure TCustomLuaLEDFunctionProvider.ScriptWindowVisible(Context: ILuaContext);
var
  className: string;
  windowTitle: string;
  parentClassName: string;
  parentWindowTitle: string;

begin
  if Context.Parameters.Count = 0 then
    raise ELuaScriptError.Create('WindowVisible: expected at least 1 parameter');

  className := '';
  windowTitle := '';
  parentClassName := '';
  parentWindowTitle := '';

  if Context.Parameters.Count >= 1 then className := Context.Parameters[0].AsString;
  if Context.Parameters.Count >= 2 then windowTitle := Context.Parameters[1].AsString;
  if Context.Parameters.Count >= 3 then parentClassName := Context.Parameters[2].AsString;
  if Context.Parameters.Count >= 4 then parentWindowTitle := Context.Parameters[3].AsString;

  Context.Result.Push(WindowVisible(className, windowTitle, parentClassName, parentWindowTitle));
end;


function TCustomLuaLEDFunctionProvider.WindowVisible(const AClassName, AWindowTitle, AParentClassName, AParentWindowTitle: string): Boolean;

  function GetNilPChar(const AValue: string): PChar;
  begin
    if Length(AValue) > 0 then
      Result := PChar(AValue)
    else
      Result := nil;
  end;

var
  parentWindow: THandle;
  childWindow: THandle;
  window: THandle;

begin
  Result := False;

  if (Length(AParentClassName) > 0) or (Length(AParentWindowTitle) > 0) then
  begin
    parentWindow := FindWindow(GetNilPChar(AParentClassName), GetNilPChar(AParentWindowTitle));
    if parentWindow <> 0 then
    begin
      childWindow := FindWindowEx(parentWindow, 0, GetNilPChar(AClassName), GetNilPChar(AWindowTitle));
      Result := (childWindow <> 0) and IsWindowVisible(childWindow);
    end;
  end else
  begin
    window := FindWindow(GetNilPChar(AClassName), GetNilPChar(AWindowTitle));
    Result := (window <> 0) and IsWindowVisible(window);
  end;
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
var
  task: IOmniTaskControl;

begin
  if Assigned(Tasks) then
  begin
    for task in Tasks do
    begin
      task.Stop;
      task.WaitFor(INFINITE);
    end;

    FreeAndNil(FTasks);
  end;

  SetProvider(nil);

  inherited Destroy;
end;


procedure TCustomLuaLEDFunctionWorker.AddTask(ATask: IOmniTaskControl);
begin
  if not Assigned(Tasks) then
    FTasks := TList<IOmniTaskControl>.Create;

  Tasks.Add(ATask);
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
constructor TLuaLog.Create(AOnLog: TLuaLogProc);
begin
  inherited Create;

  FOnLog := AOnLog;
end;


procedure TLuaLog.Verbose(Context: ILuaContext);
begin
  OnLog(Context, TX2LogLevel.Verbose);
end;


procedure TLuaLog.Info(Context: ILuaContext);
begin
  OnLog(Context, TX2LogLevel.Info);
end;


procedure TLuaLog.Warning(Context: ILuaContext);
begin
  OnLog(Context, TX2LogLevel.Warning);
end;


procedure TLuaLog.Error(Context: ILuaContext);
begin
  OnLog(Context, TX2LogLevel.Error);
end;


{ TLuaTimerTask }
constructor TLuaTimerTask.Create(AOnTimer: TProc);
begin
  inherited Create;

  FOnTimer := AOnTimer;
end;


procedure TLuaTimerTask.Run;
begin
  FOnTimer();
end;

end.

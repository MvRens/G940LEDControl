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
  protected
    function CreateLuaLEDFunction(AInfo: ILuaTable; ASetup: ILuaFunction): TCustomLuaLEDFunction; virtual; abstract;

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
  System.IOUtils,

  LEDColorIntf,
  LEDState;


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

  InitInterpreter;

  inherited Create;
end;


destructor TCustomLuaLEDFunctionProvider.Destroy;
begin
  FreeAndNil(FInterpreter);
  FreeAndNil(FWorkers);

  inherited Destroy;
end;


procedure TCustomLuaLEDFunctionProvider.InitInterpreter;
var
  table: ILuaTable;
  color: TLEDColor;

begin
  Interpreter.RegisterFunction('RegisterFunction',
    procedure(Context: ILuaContext)
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
    end);

  table := TLuaTable.Create;
  for color := Low(TLEDColor) to High(TLEDColor) do
    table.SetValue(LuaLEDColors[color], LuaLEDColors[color]);

  Interpreter.SetGlobalVariable('LEDColor', table);

  // #ToDo1 -oMvR: 28-5-2017: SetState
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

end.

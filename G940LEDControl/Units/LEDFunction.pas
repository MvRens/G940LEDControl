unit LEDFunction;

interface
uses
  System.Classes,
  System.SyncObjs,

  LEDFunctionIntf,
  LEDStateIntf;


type
  TCustomLEDFunctionWorker = class;
  TCustomLEDMultiStateFunctionWorker = class;
  TCustomLEDMultiStateFunctionWorkerClass = class of TCustomLEDMultiStateFunctionWorker;


  TCustomLEDFunctionProvider = class(TInterfacedObject, ILEDFunctionProvider)
  private
    FFunctions: TInterfaceList;
  protected
    procedure RegisterFunctions; virtual; abstract;
    function RegisterFunction(AFunction: ILEDFunction): ILEDFunction; virtual;
  protected
    { ILEDFunctionProvider }
    function GetUID: string; virtual; abstract;
    function GetEnumerator: ILEDFunctionEnumerator; virtual;

    function Find(const AFunctionUID: string): ILEDFunction; virtual;
  public
    constructor Create;
    destructor Destroy; override;
  end;


  TCustomLEDFunction = class(TInterfacedObject, ILEDFunction)
  protected
    { ILEDFunction }
    function GetCategoryName: string; virtual; abstract;
    function GetDisplayName: string; virtual; abstract;
    function GetUID: string; virtual; abstract;

    function CreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): ILEDFunctionWorker; virtual; abstract;
  end;


  TCustomMultiStateLEDFunction = class(TCustomLEDFunction, ILEDMultiStateFunction)
  private
    FStates: TInterfaceList;
    FProviderUID: string;
  protected
    procedure RegisterStates; virtual; abstract;
    function RegisterState(AState: ILEDState): ILEDState; virtual;

    function GetWorkerClass: TCustomLEDMultiStateFunctionWorkerClass; virtual; abstract;
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): TCustomLEDFunctionWorker; virtual;
    procedure InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker); virtual;
  protected
    function CreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): ILEDFunctionWorker; override;

    { ILEDMultiStateFunction }
    function GetEnumerator: ILEDStateEnumerator; virtual;
  public
    constructor Create(const AProviderUID: string);
    destructor Destroy; override;
  end;


  TCustomLEDFunctionWorker = class(TInterfacedObject, ILEDFunctionWorker)
  private
    FObservers: TInterfaceList;
    FProviderUID: string;
    FFunctionUID: string;
  protected
    procedure NotifyObservers; virtual;

    property Observers: TInterfaceList read FObservers;
  protected
    { ILEDFunctionWorker }
    procedure Attach(AObserver: ILEDFunctionObserver); virtual;
    procedure Detach(AObserver: ILEDFunctionObserver); virtual;

    function GetProviderUID: string; virtual;
    function GetFunctionUID: string; virtual;

    function GetCurrentState: ILEDStateWorker; virtual; abstract;
  public
    constructor Create(const AProviderUID, AFunctionUID: string);
    destructor Destroy; override;
  end;


  TCustomLEDMultiStateFunctionWorker = class(TCustomLEDFunctionWorker)
  private
    FStates: TInterfaceList;
    FCurrentStateLock: TCriticalSection;
    FCurrentState: ILEDStateWorker;
  protected
    procedure RegisterStates(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings); virtual;
    function FindState(const AUID: string): ILEDStateWorker; virtual;

    procedure SetCurrentState(const AUID: string; ANotifyObservers: Boolean = True); overload; virtual;
    procedure SetCurrentState(AState: ILEDStateWorker; ANotifyObservers: Boolean = True); overload; virtual;

    property States: TInterfaceList read FStates;
  protected
    function GetCurrentState: ILEDStateWorker; override;
  public
    constructor Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''); virtual;
    destructor Destroy; override;
  end;


  TLEDFunctionEnumerator = class(TInterfacedObject, ILEDFunctionEnumerator)
  private
    FList: TInterfaceList;
    FIndex: Integer;
  protected
    { ILEDFunctionEnumerator }
    function GetCurrent: ILEDFunction; virtual;
    function MoveNext: Boolean; virtual;
  public
    constructor Create(AList: TInterfaceList);
  end;


  TLEDStateEnumerator = class(TInterfacedObject, ILEDStateEnumerator)
  private
    FList: TInterfaceList;
    FIndex: Integer;
  protected
    { ILEDStateEnumerator }
    function GetCurrent: ILEDState; virtual;
    function MoveNext: Boolean; virtual;
  public
    constructor Create(AList: TInterfaceList);
  end;



implementation
uses
  System.SysUtils,

  LEDColorIntf,
  LEDColorPool,
  LEDState;


{ TCustomMultiStateLEDFunction }
constructor TCustomMultiStateLEDFunction.Create(const AProviderUID: string);
begin
  inherited Create;

  FStates := TInterfaceList.Create;
  FProviderUID := AProviderUID;

  RegisterStates;
end;


destructor TCustomMultiStateLEDFunction.Destroy;
begin
  FreeAndNil(FStates);

  inherited Destroy;
end;


function TCustomMultiStateLEDFunction.RegisterState(AState: ILEDState): ILEDState;
begin
  Result := AState as ILEDState;
  FStates.Add(Result);
end;


function TCustomMultiStateLEDFunction.GetEnumerator: ILEDStateEnumerator;
begin
  Result := TLEDStateEnumerator.Create(FStates);
end;


function TCustomMultiStateLEDFunction.CreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string): ILEDFunctionWorker;
begin
  Result := DoCreateWorker(ASettings, APreviousState);
end;


function TCustomMultiStateLEDFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string): TCustomLEDFunctionWorker;
var
  worker: TCustomLEDMultiStateFunctionWorker;

begin
  worker := GetWorkerClass.Create(FProviderUID, GetUID, Self, ASettings, APreviousState);
  InitializeWorker(worker);

  Result := worker;
end;


procedure TCustomMultiStateLEDFunction.InitializeWorker(AWorker: TCustomLEDMultiStateFunctionWorker);
begin
end;


{ TCustomLEDFunctionWorker }
constructor TCustomLEDFunctionWorker.Create(const AProviderUID, AFunctionUID: string);
begin
  inherited Create;

  FObservers := TInterfaceList.Create;
  FProviderUID := AProviderUID;
  FFunctionUID := AFunctionUID;
end;


destructor TCustomLEDFunctionWorker.Destroy;
begin
  FreeAndNil(FObservers);

  inherited Destroy;
end;


procedure TCustomLEDFunctionWorker.Attach(AObserver: ILEDFunctionObserver);
begin
  { TInterfaceList is thread-safe }
  Observers.Add(AObserver as ILEDFunctionObserver);
end;


procedure TCustomLEDFunctionWorker.Detach(AObserver: ILEDFunctionObserver);
begin
  Observers.Remove(AObserver as ILEDFunctionObserver);
end;


function TCustomLEDFunctionWorker.GetProviderUID: string;
begin
  Result := FProviderUID;
end;


function TCustomLEDFunctionWorker.GetFunctionUID: string;
begin
  Result := FFunctionUID;
end;


procedure TCustomLEDFunctionWorker.NotifyObservers;
var
  observer: IInterface;

begin
  for observer in Observers do
    (observer as ILEDFunctionObserver).ObserveUpdate(Self);
end;


{ TCustomLEDMultiStateFunctionWorker }
constructor TCustomLEDMultiStateFunctionWorker.Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string);
begin
  inherited Create(AProviderUID, AFunctionUID);

  FCurrentStateLock := TCriticalSection.Create;

  FStates := TInterfaceList.Create;
  RegisterStates(AStates, ASettings);

  if Length(APreviousState) > 0 then
    FCurrentState := FindState(APreviousState);

  { Make sure we have a default state }
  if (not Assigned(FCurrentState)) and (States.Count > 0) then
    SetCurrentState((States[0] as ILEDStateWorker), False);
end;


destructor TCustomLEDMultiStateFunctionWorker.Destroy;
begin
  FreeAndNil(FCurrentStateLock);
  FreeAndNil(FStates);

  inherited Destroy;
end;


procedure TCustomLEDMultiStateFunctionWorker.RegisterStates(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings);
var
  state: ILEDState;
  color: TLEDColor;

begin
  for state in AStates do
  begin
    if (not Assigned(ASettings)) or (not ASettings.GetStateColor(state.GetUID, color)) then
      color := state.GetDefaultColor;

    States.Add(TLEDStateWorker.Create(state.GetUID, TLEDColorPool.GetColor(color)));
  end;
end;


function TCustomLEDMultiStateFunctionWorker.FindState(const AUID: string): ILEDStateWorker;
var
  state: IInterface;

begin
  Result := nil;
  if not Assigned(States) then
    exit;

  for state in States do
    if (state as ICustomLEDState).GetUID = AUID then
    begin
      Result := (state as ILEDStateWorker);
      break;
    end;
end;


procedure TCustomLEDMultiStateFunctionWorker.SetCurrentState(const AUID: string; ANotifyObservers: Boolean);
begin
  SetCurrentState(FindState(AUID), ANotifyObservers);
end;


procedure TCustomLEDMultiStateFunctionWorker.SetCurrentState(AState: ILEDStateWorker; ANotifyObservers: Boolean);
begin
  if AState <> FCurrentState then
  begin
    FCurrentStateLock.Acquire;
    try
      FCurrentState := AState;
    finally
      FCurrentStateLock.Release;
    end;

    if ANotifyObservers then
      NotifyObservers;
  end;
end;


function TCustomLEDMultiStateFunctionWorker.GetCurrentState: ILEDStateWorker;
begin
  Result := FCurrentState;
end;


{ TCustomLEDFunctionProvider }
constructor TCustomLEDFunctionProvider.Create;
begin
  inherited Create;

  FFunctions := TInterfaceList.Create;
  RegisterFunctions;
end;


destructor TCustomLEDFunctionProvider.Destroy;
begin
  FreeAndNil(FFunctions);

  inherited Destroy;
end;


function TCustomLEDFunctionProvider.Find(const AFunctionUID: string): ILEDFunction;
var
  ledFunction: ILEDFunction;

begin
  Result := nil;

  for ledFunction in (Self as ILEDFunctionProvider) do
    if ledFunction.GetUID = AFunctionUID then
    begin
      Result := ledFunction;
      break;
    end;
end;


function TCustomLEDFunctionProvider.RegisterFunction(AFunction: ILEDFunction): ILEDFunction;
begin
  Result := AFunction as ILEDFunction;
  FFunctions.Add(Result);
end;


function TCustomLEDFunctionProvider.GetEnumerator: ILEDFunctionEnumerator;
begin
  Result := TLEDFunctionEnumerator.Create(FFunctions);
end;


{ TLEDFunctionEnumerator }
constructor TLEDFunctionEnumerator.Create(AList: TInterfaceList);
begin
  inherited Create;

  FList := AList;
  FIndex := -1;
end;


function TLEDFunctionEnumerator.GetCurrent: ILEDFunction;
begin
  Result := (FList[FIndex] as ILEDFunction);
end;


function TLEDFunctionEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < Pred(FList.Count));
  if Result then
    Inc(FIndex);
end;


{ TLEDStateEnumerator }
constructor TLEDStateEnumerator.Create(AList: TInterfaceList);
begin
  inherited Create;

  FList := AList;
  FIndex := -1;
end;


function TLEDStateEnumerator.GetCurrent: ILEDState;
begin
  Result := (FList[FIndex] as ILEDState);
end;


function TLEDStateEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < Pred(FList.Count));
  if Result then
    Inc(FIndex);
end;

end.

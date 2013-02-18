unit LEDFunction;

interface
uses
  Classes,

  LEDFunctionIntf,
  LEDStateIntf;


type
  TCustomLEDFunctionWorker = class;
  TCustomLEDFunctionWorkerClass = class of TCustomLEDFunctionWorker;


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

    function CreateWorker(ASettings: ILEDFunctionWorkerSettings): ILEDFunctionWorker; virtual; abstract;
  end;


  TCustomMultiStateLEDFunction = class(TCustomLEDFunction, ILEDMultiStateFunction)
  private
    FStates: TInterfaceList;
  protected
    procedure RegisterStates; virtual; abstract;
    function RegisterState(AState: ILEDState): ILEDState; virtual;

    function GetWorkerClass: TCustomLEDFunctionWorkerClass; virtual; abstract;
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker; virtual;
  protected
    function CreateWorker(ASettings: ILEDFunctionWorkerSettings): ILEDFunctionWorker; override;

    { ILEDMultiStateFunction }
    function GetEnumerator: ILEDStateEnumerator; virtual;
  public
    constructor Create;
    destructor Destroy; override;
  end;


  TCustomLEDFunctionWorker = class(TInterfacedObject, ILEDFunctionWorker)
  private
    FObservers: TInterfaceList;
    FStates: TInterfaceList;
  protected
    procedure RegisterStates(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings); virtual;
    function FindState(const AUID: string): ILEDStateWorker; virtual;

    procedure NotifyObservers; virtual;

    property Observers: TInterfaceList read FObservers;
    property States: TInterfaceList read FStates;
  protected
    { ILEDFunctionWorker }
    procedure Attach(AObserver: ILEDFunctionObserver); virtual;
    procedure Detach(AObserver: ILEDFunctionObserver); virtual;

    function GetCurrentState: ILEDStateWorker; virtual; abstract;
  public
    constructor Create; overload;
    constructor Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings); overload;

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
constructor TCustomMultiStateLEDFunction.Create;
begin
  inherited Create;

  FStates := TInterfaceList.Create;
  RegisterStates;
end;


destructor TCustomMultiStateLEDFunction.Destroy;
begin
  FreeAndNil(FStates);

  inherited;
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


function TCustomMultiStateLEDFunction.CreateWorker(ASettings: ILEDFunctionWorkerSettings): ILEDFunctionWorker;
begin
  Result := DoCreateWorker(ASettings);
end;


function TCustomMultiStateLEDFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker;
begin
  Result := GetWorkerClass.Create(Self, ASettings);
end;


{ TCustomLEDFunctionWorker }
constructor TCustomLEDFunctionWorker.Create;
begin
  inherited Create;

  FObservers := TInterfaceList.Create;
end;


constructor TCustomLEDFunctionWorker.Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings);
begin
  Create;

  FStates := TInterfaceList.Create;
  RegisterStates(AStates, ASettings);
end;


destructor TCustomLEDFunctionWorker.Destroy;
begin
  FreeAndNil(FStates);
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


procedure TCustomLEDFunctionWorker.RegisterStates(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings);
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


function TCustomLEDFunctionWorker.FindState(const AUID: string): ILEDStateWorker;
var
  state: IInterface;

begin
  Result := nil;

  for state in States do
    if (state as ICustomLEDState).GetUID = AUID then
    begin
      Result := (state as ILEDStateWorker);
      break;
    end;
end;


procedure TCustomLEDFunctionWorker.NotifyObservers;
var
  observer: IInterface;

begin
  for observer in Observers do
    (observer as ILEDFunctionObserver).ObserveUpdate(Self);
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

  inherited;
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

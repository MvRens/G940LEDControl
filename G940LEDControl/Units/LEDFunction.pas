unit LEDFunction;

interface
uses
  Classes,

  LEDFunctionIntf,
  LEDStateIntf,
  ObserverIntf;


type
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


  TCustomLEDFunction = class(TInterfacedObject, IObservable, ILEDFunction)
  private
    FObservers: TInterfaceList;
  protected
    procedure NotifyObservers; virtual;

    property Observers: TInterfaceList read FObservers;
  protected
    { IObservable }
    procedure Attach(AObserver: IObserver); virtual;
    procedure Detach(AObserver: IObserver); virtual;

    { ILEDFunction }
    function GetCategoryName: string; virtual; abstract;
    function GetDisplayName: string; virtual; abstract;
    function GetUID: string; virtual; abstract;

    function GetCurrentState: ILEDState; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
  end;


  TCustomMultiStateLEDFunction = class(TCustomLEDFunction, ILEDMultiStateFunction)
  private
    FStates: TInterfaceList;
  protected
//    procedure SetCurrentState(AState: ILEDState); virtual;
    procedure RegisterStates; virtual; abstract;
    function RegisterState(AState: ILEDState): ILEDState; virtual;
  protected
    { ILEDMultiStateFunction }
    function GetEnumerator: ILEDStateEnumerator; virtual;
  public
    constructor Create;
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
  SysUtils;


{ TCustomLEDFunction }
constructor TCustomLEDFunction.Create;
begin
  inherited Create;

  FObservers := TInterfaceList.Create;
end;


destructor TCustomLEDFunction.Destroy;
begin
  FreeAndNil(FObservers);

  inherited Destroy;
end;


procedure TCustomLEDFunction.Attach(AObserver: IObserver);
begin
  FObservers.Add(AObserver as IObserver);
end;


procedure TCustomLEDFunction.Detach(AObserver: IObserver);
begin
  FObservers.Remove(AObserver as IObserver);
end;


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


//procedure TCustomMultiStateLEDFunction.SetCurrentState(AState: ILEDState);
//begin
//  FCurrentState := AState;
//  NotifyObservers;
//end;


procedure TCustomLEDFunction.NotifyObservers;
var
  observer: IInterface;

begin
  for observer in Observers do
    (observer as IObserver).Update(Self);
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

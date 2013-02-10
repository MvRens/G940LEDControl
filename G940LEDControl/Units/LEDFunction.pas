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
    procedure RegisterFunction(AFunction: ILEDFunction);
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
    FStates: TInterfaceList;
  protected
//    procedure SetCurrentState(AState: ILEDState); virtual;

    procedure NotifyObservers; virtual;

    property Observers: TInterfaceList read FObservers;
  protected
    { IObservable }
    procedure Attach(AObserver: IObserver);
    procedure Detach(AObserver: IObserver);

    { ILEDFunction }
    function GetCategoryName: string; virtual; abstract;
    function GetDisplayName: string; virtual; abstract;
    function GetUID: string; virtual; abstract;

    function GetEnumerator: ILEDStateEnumerator; virtual;
    function GetCurrentState: ILEDState; virtual; abstract;
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
  FStates := TInterfaceList.Create;
end;


destructor TCustomLEDFunction.Destroy;
begin
  FreeAndNil(FStates);
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


function TCustomLEDFunction.GetEnumerator: ILEDStateEnumerator;
begin
  Result := TLEDStateEnumerator.Create(FStates);
end;


//procedure TCustomLEDFunction.SetCurrentState(AState: ILEDState);
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


procedure TCustomLEDFunctionProvider.RegisterFunction(AFunction: ILEDFunction);
begin
  FFunctions.Add(AFunction as ILEDFunction);
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

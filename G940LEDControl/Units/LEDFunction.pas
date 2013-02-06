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
    function GetUniqueName: string; virtual; abstract;

    function GetEnumerator: ILEDFunctionEnumerator; virtual;
  public
    constructor Create;
    destructor Destroy; override;
  end;


  TCustomLEDFunction = class(TInterfacedObject, IObservable, ILEDFunction)
  private
    FCurrentState: ILEDState;
    FObservers: TInterfaceList;
  protected
    procedure SetCurrentState(AState: ILEDState); virtual;

    procedure NotifyObservers; virtual;

    property Observers: TInterfaceList read FObservers;
  protected
    { IObservable }
    procedure Attach(AObserver: IObserver);
    procedure Detach(AObserver: IObserver);

    { ILEDFunction }
    function GetCategoryName: string; virtual; abstract;
    function GetDisplayName: string; virtual; abstract;
    function GetUniqueName: string; virtual; abstract;

    function GetCurrentState: ILEDState; virtual;
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

end;


procedure TCustomLEDFunction.Detach(AObserver: IObserver);
begin

end;


function TCustomLEDFunction.GetCurrentState: ILEDState;
begin

end;


procedure TCustomLEDFunction.SetCurrentState(AState: ILEDState);
begin
  FCurrentState := AState;
  NotifyObservers;
end;


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


procedure TCustomLEDFunctionProvider.RegisterFunction(AFunction: ILEDFunction);
begin
  { Make sure to explicitly request the ILEDFunction interface; I've experienced
    incomparable pointers otherwise if we ever need to write an UnregisterFunction.
    My best, but unverified, guess is that it works kinda like a VMT. }
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

end.

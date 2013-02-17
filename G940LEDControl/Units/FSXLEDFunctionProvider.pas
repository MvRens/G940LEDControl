unit FSXLEDFunctionProvider;

interface
uses
  Generics.Collections,
  System.SyncObjs,

  FSXSimConnectIntf,
  LEDFunction,
  LEDFunctionIntf,
  LEDStateIntf,
  ObserverIntf;


type
  TCustomFSXFunction = class;
  TCustomFSXFunctionList = TObjectList<TCustomFSXFunction>;


  TFSXLEDFunctionProvider = class(TCustomLEDFunctionProvider)
  private
    FConnectedFunctions: TCustomFSXFunctionList;
    FSimConnectHandle: THandle;
  protected
    procedure SimConnect;
    procedure SimDisconnect;

    procedure Connect(AFunction: TCustomFSXFunction); virtual;
    procedure Disconnect(AFunction: TCustomFSXFunction); virtual;

    property ConnectedFunctions: TCustomFSXFunctionList read FConnectedFunctions;
    property SimConnectHandle: THandle read FSimConnectHandle;
  protected
    procedure RegisterFunctions; override;

    function GetUID: string; override;
  public
    function GetSimConnect: IFSXSimConnect;
  end;


  TCustomFSXFunction = class(TCustomMultiStateLEDFunction)
  private
    FProvider: TFSXLEDFunctionProvider;
    FDisplayName: string;
    FUID: string;
  protected
    procedure SimConnected; virtual;
    procedure SimDisconnected; virtual;

    property Provider: TFSXLEDFunctionProvider read FProvider;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
  end;


  TCustomFSXFunctionWorker = class(TCustomLEDFunctionWorker)
  private
    FSimConnect: IFSXSimConnect;
    FDefinition: IFSXSimConnectDefinition;
    FCurrentStateLock: TCriticalSection;
    FCurrentState: ILEDStateWorker;
  protected
    procedure RegisterVariables; virtual; abstract;

    procedure SetCurrentState(const AUID: string);

    property Definition: IFSXSimConnectDefinition read FDefinition;
    property SimConnect: IFSXSimConnect read FSimConnect;
  protected
    function GetCurrentState: ILEDStateWorker; override;
  public
    constructor Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; ASimConnect: IFSXSimConnect);
    destructor Destroy; override;
  end;


implementation
uses
  System.SysUtils,

  FSXLEDFunction,
  FSXResources,
  LEDFunctionRegistry,
  SimConnect;



{ TFSXLEDFunctionProvider }
procedure TFSXLEDFunctionProvider.RegisterFunctions;
begin
  RegisterFunction(TFSXGearFunction.Create(Self, FSXFunctionDisplayNameGear, FSXFunctionUIDGear));
end;


function TFSXLEDFunctionProvider.GetUID: string;
begin
  Result := FSXProviderUID;
end;


function TFSXLEDFunctionProvider.GetSimConnect: IFSXSimConnect;
begin
  // TODO
end;


procedure TFSXLEDFunctionProvider.SimConnect;
var
  fsxFunction: TCustomFSXFunction;

begin
  if SimConnectHandle <> 0 then
    exit;

//  FSimConnectHandle :=

  if SimConnectHandle <> 0 then
  begin
    for fsxFunction in ConnectedFunctions do
      fsxFunction.SimConnected;
  end;
end;


procedure TFSXLEDFunctionProvider.SimDisconnect;
begin
  if SimConnectHandle = 0 then
    exit;
end;


procedure TFSXLEDFunctionProvider.Connect(AFunction: TCustomFSXFunction);
begin
  if ConnectedFunctions.IndexOf(AFunction) = -1 then
  begin
    ConnectedFunctions.Add(AFunction);

    if ConnectedFunctions.Count > 0 then
      SimConnect;
  end;
end;

procedure TFSXLEDFunctionProvider.Disconnect(AFunction: TCustomFSXFunction);
begin
  ConnectedFunctions.Remove(AFunction);

  if ConnectedFunctions.Count = 0 then
    SimDisconnect;
end;


{ TCustomFSXFunction }
constructor TCustomFSXFunction.Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
begin
  inherited Create;

  FProvider := AProvider;
  FDisplayName := ADisplayName;
  FUID := AUID;
end;


function TCustomFSXFunction.GetCategoryName: string;
begin
  Result := FSXCategory;
end;


function TCustomFSXFunction.GetDisplayName: string;
begin
  Result := FDisplayName;
end;


function TCustomFSXFunction.GetUID: string;
begin
  Result := FUID;
end;


procedure TCustomFSXFunction.SimConnected;
begin
end;


procedure TCustomFSXFunction.SimDisconnected;
begin
end;


{ TCustomFSXFunctionWorker }
constructor TCustomFSXFunctionWorker.Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; ASimConnect: IFSXSimConnect);
begin
  inherited Create(AStates, ASettings);

  FCurrentStateLock := TCriticalSection.Create;
  FSimConnect := ASimConnect;

  FDefinition := ASimConnect.CreateDefinition;
  RegisterVariables;
  ASimConnect.AddDefinition(FDefinition);
end;


destructor TCustomFSXFunctionWorker.Destroy;
begin
  FreeAndNil(FCurrentStateLock);

  inherited;
end;


function TCustomFSXFunctionWorker.GetCurrentState: ILEDStateWorker;
begin
  FCurrentStateLock.Acquire;
  try
    Result := FCurrentState;
  finally
    FCurrentStateLock.Release;
  end;
end;


procedure TCustomFSXFunctionWorker.SetCurrentState(const AUID: string);
var
  newState: ILEDStateWorker;

begin
  FCurrentStateLock.Acquire;
  try
    newState := FindState(AUID);
    if newState <> FCurrentState then
    begin
      FCurrentState := newState;
      NotifyObservers;
    end;
  finally
    FCurrentStateLock.Release;
  end;
end;


initialization
  TLEDFunctionRegistry.Register(TFSXLEDFunctionProvider.Create);

end.

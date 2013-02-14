unit FSXLEDFunction;

interface
uses
  Generics.Collections,

  LEDFunction,
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
  end;


  TCustomFSXFunction = class(TCustomMultiStateLEDFunction)
  private
    FProvider: TFSXLEDFunctionProvider;
  protected
    procedure SimConnected; virtual;
    procedure SimDisconnected; virtual;

    property Provider: TFSXLEDFunctionProvider read FProvider;
  protected
    procedure Attach(AObserver: IObserver); override;
    procedure Detach(AObserver: IObserver); override;

    function GetCategoryName: string; override;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider);
  end;


  TFSXGearFunction = class(TCustomFSXFunction)
  private
    FRetractedState: ILEDState;
    FBetweenState: ILEDState;
    FExtendedState: ILEDState;
    FSpeedExceededState: ILEDState;
    FDamageBySpeedState: ILEDState;
  protected
    procedure RegisterStates; override;

    function GetDisplayName: string; override;
    function GetUID: string; override;

    function GetCurrentState: ILEDState; override;
  end;


implementation
uses
  FSXResources,
  LEDColorPool,
  LEDFunctionRegistry,
  LEDState;


{ TFSXLEDFunctionProvider }
procedure TFSXLEDFunctionProvider.RegisterFunctions;
begin
  RegisterFunction(TFSXGearFunction.Create(Self));
end;


function TFSXLEDFunctionProvider.GetUID: string;
begin
  Result := FSXProviderUID;
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
constructor TCustomFSXFunction.Create(AProvider: TFSXLEDFunctionProvider);
begin
  inherited Create;

  FProvider := AProvider;
end;


procedure TCustomFSXFunction.Attach(AObserver: IObserver);
begin
  if Observers.Count = 0 then
    Provider.Connect(Self);

  inherited Attach(AObserver);
end;


procedure TCustomFSXFunction.Detach(AObserver: IObserver);
begin
  if Assigned(Provider) and (Observers.Count > 0) then
  begin
    inherited Detach(AObserver);

    if Observers.Count = 0 then
      Provider.Disconnect(Self);
  end else
    inherited Detach(AObserver);
end;


function TCustomFSXFunction.GetCategoryName: string;
begin
  Result := FSXCategory;
end;


procedure TCustomFSXFunction.SimConnected;
begin
end;


procedure TCustomFSXFunction.SimDisconnected;
begin
end;


{ TFSXGearFunction }
procedure TFSXGearFunction.RegisterStates;
begin
  FRetractedState     := RegisterState(TLEDState.Create(FSXStateUIDGearRetracted,
                                                        FSXStateDisplayNameGearRetracted,
                                                        TLEDColorPool.GetColor(cpeStaticRed)));

  FBetweenState       := RegisterState(TLEDState.Create(FSXStateUIDGearBetween,
                                                        FSXStateDisplayNameGearBetween,
                                                        TLEDColorPool.GetColor(cpeStaticAmber)));

  FExtendedState      := RegisterState(TLEDState.Create(FSXStateUIDGearExtended,
                                                        FSXStateDisplayNameGearExtended,
                                                        TLEDColorPool.GetColor(cpeStaticGreen)));

  FSpeedExceededState := RegisterState(TLEDState.Create(FSXStateUIDGearSpeedExceeded,
                                                        FSXStateDisplayNameGearSpeedExceeded,
                                                        TLEDColorPool.GetColor(cpeFlashingAmberNormal)));

  FDamageBySpeedState := RegisterState(TLEDState.Create(FSXStateUIDGearDamageBySpeed,
                                                        FSXStateDisplayNameGearDamageBySpeed,
                                                        TLEDColorPool.GetColor(cpeFlashingRedFast)));
end;


function TFSXGearFunction.GetDisplayName: string;
begin
  Result := FSXFunctionDisplayNameGear;
end;


function TFSXGearFunction.GetUID: string;
begin
  Result := FSXFunctionUIDGear;
end;


function TFSXGearFunction.GetCurrentState: ILEDState;
begin
  // TODO TFSXGearFunction.GetCurrentState
end;


initialization
  TLEDFunctionRegistry.Register(TFSXLEDFunctionProvider.Create);

end.

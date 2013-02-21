unit FSXLEDFunctionProvider;

interface
uses
  Generics.Collections,
  System.SyncObjs,

  FSXSimConnectIntf,
  LEDFunction,
  LEDFunctionIntf,
  LEDStateIntf;


type
  TCustomFSXFunction = class;
  TCustomFSXFunctionList = TObjectList<TCustomFSXFunction>;


  TFSXLEDFunctionProvider = class(TCustomLEDFunctionProvider, IFSXSimConnectObserver)
  private
    FSimConnect: TInterfacedObject;
    FSimConnectLock: TCriticalSection;
  protected
    procedure RegisterFunctions; override;

    function GetUID: string; override;
  protected
    { IFSXSimConnectObserver }
    procedure ObserveDestroy(Sender: IFSXSimConnect);
  public
    constructor Create;
    destructor Destroy; override;

    function GetSimConnect: IFSXSimConnect;
  end;


  TCustomFSXFunction = class(TCustomMultiStateLEDFunction)
  private
    FProvider: TFSXLEDFunctionProvider;
    FDisplayName: string;
    FUID: string;
  protected
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker; override;

    property Provider: TFSXLEDFunctionProvider read FProvider;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
  end;


  TCustomFSXFunctionClass = class of TCustomFSXFunction;


  TCustomFSXFunctionWorker = class(TCustomLEDFunctionWorker)
  private
    FDataHandler: IFSXSimConnectDataHandler;
    FDefinitionID: Cardinal;
    FSimConnect: IFSXSimConnect;
    FCurrentStateLock: TCriticalSection;
    FCurrentState: ILEDStateWorker;
  protected
    procedure RegisterStates(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings); override;
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); virtual; abstract;

    procedure SetCurrentState(const AUID: string; ANotifyObservers: Boolean = True); overload; virtual;
    procedure SetCurrentState(AState: ILEDStateWorker; ANotifyObservers: Boolean = True); overload; virtual;
    procedure SetSimConnect(const Value: IFSXSimConnect); virtual;

    property DataHandler: IFSXSimConnectDataHandler read FDataHandler;
    property DefinitionID: Cardinal read FDefinitionID;
    property SimConnect: IFSXSimConnect read FSimConnect write SetSimConnect;
  protected
    function GetCurrentState: ILEDStateWorker; override;

    procedure HandleData(AData: Pointer); virtual; abstract;
  public
    constructor Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings); override;
    destructor Destroy; override;
  end;


implementation
uses
  System.SysUtils,

  FSXLEDFunction,
  FSXResources,
  FSXSimConnectClient,
  LEDFunctionRegistry,
  SimConnect;


type
  TCustomFSXFunctionWorkerDataHandler = class(TInterfacedObject, IFSXSimConnectDataHandler)
  private
    FWorker: TCustomFSXFunctionWorker;
  protected
    { IFSXSimConnectDataHandler }
    procedure HandleData(AData: Pointer);

    property Worker: TCustomFSXFunctionWorker read FWorker;
  public
    constructor Create(AWorker: TCustomFSXFunctionWorker);
  end;



{ TFSXLEDFunctionProvider }
constructor TFSXLEDFunctionProvider.Create;
begin
  inherited Create;

  FSimConnectLock := TCriticalSection.Create;
end;


destructor TFSXLEDFunctionProvider.Destroy;
begin
  FreeAndNil(FSimConnectLock);

  inherited Destroy;
end;


procedure TFSXLEDFunctionProvider.RegisterFunctions;
begin
  {
  AConsumer.AddFunction(FUNCTION_FSX_CARBHEAT, 'Anti-ice');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT, 'Auto pilot (main)');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_AMBER, 'Auto pilot (main - off / amber)');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_ALTITUDE, 'Auto pilot - Altitude');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_APPROACH, 'Auto pilot - Approach');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_BACKCOURSE, 'Auto pilot - Backcourse');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_HEADING, 'Auto pilot - Heading');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_NAV, 'Auto pilot - Nav');
  AConsumer.AddFunction(FUNCTION_FSX_AVIONICSMASTER, 'Avionics master switch');
  AConsumer.AddFunction(FUNCTION_FSX_BATTERYMASTER, 'Battery master switch');
  AConsumer.AddFunction(FUNCTION_FSX_ENGINE, 'Engine');
  AConsumer.AddFunction(FUNCTION_FSX_EXITDOOR, 'Exit door');
  AConsumer.AddFunction(FUNCTION_FSX_FLAPS, 'Flaps');
  AConsumer.AddFunction(FUNCTION_FSX_PARKINGBRAKE, 'Parking brake');
  AConsumer.AddFunction(FUNCTION_FSX_PRESSURIZATIONDUMPSWITCH, 'Pressurization dump switch');
  AConsumer.AddFunction(FUNCTION_FSX_SPOILERS, 'Spoilers (air brake)');
  AConsumer.AddFunction(FUNCTION_FSX_TAILHOOK, 'Tail hook');
  }

  { Misc }
  RegisterFunction(TFSXEngineFunction.Create(           Self, FSXFunctionDisplayNameEngine,             FSXFunctionUIDEngine));
  RegisterFunction(TFSXGearFunction.Create(             Self, FSXFunctionDisplayNameGear,               FSXFunctionUIDGear));

  { Lights }
  RegisterFunction(TFSXBeaconLightsFunction.Create(     Self, FSXFunctionDisplayNameBeaconLights,       FSXFunctionUIDBeaconLights));
  RegisterFunction(TFSXInstrumentLightsFunction.Create( Self, FSXFunctionDisplayNameInstrumentLights,   FSXFunctionUIDInstrumentLights));
  RegisterFunction(TFSXLandingLightsFunction.Create(    Self, FSXFunctionDisplayNameLandingLights,      FSXFunctionUIDLandingLights));
  RegisterFunction(TFSXNavLightsFunction.Create(        Self, FSXFunctionDisplayNameNavLights,          FSXFunctionUIDNavLights));
  RegisterFunction(TFSXRecognitionLightsFunction.Create(Self, FSXFunctionDisplayNameRecognitionLights,  FSXFunctionUIDRecognitionLights));
  RegisterFunction(TFSXStrobeLightsFunction.Create(     Self, FSXFunctionDisplayNameStrobeLights,       FSXFunctionUIDStrobeLights));
  RegisterFunction(TFSXTaxiLightsFunction.Create(       Self, FSXFunctionDisplayNameTaxiLights,         FSXFunctionUIDTaxiLights));
end;


function TFSXLEDFunctionProvider.GetUID: string;
begin
  Result := FSXProviderUID;
end;


procedure TFSXLEDFunctionProvider.ObserveDestroy(Sender: IFSXSimConnect);
begin
  FSimConnectLock.Acquire;
  try
    FSimConnect := nil;
  finally
    FSimConnectLock.Release;
  end;
end;


function TFSXLEDFunctionProvider.GetSimConnect: IFSXSimConnect;
begin
  FSimConnectLock.Acquire;
  try
    if not Assigned(FSimConnect) then
    begin
      { Keep an object reference so we don't increment the reference count.
        We'll know when it's gone through the ObserveDestroy. }
      FSimConnect := TFSXSimConnectInterface.Create;
      (FSimConnect as IFSXSimConnect).Attach(Self);
    end;

    Result := (FSimConnect as IFSXSimConnect);
  finally
    FSimConnectLock.Release;
  end;
end;


{ TCustomFSXFunction }
constructor TCustomFSXFunction.Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
begin
  inherited Create;

  FProvider := AProvider;
  FDisplayName := ADisplayName;
  FUID := AUID;
end;


function TCustomFSXFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings): TCustomLEDFunctionWorker;
begin
  Result := inherited DoCreateWorker(ASettings);

  (Result as TCustomFSXFunctionWorker).SimConnect := Provider.GetSimConnect;
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


{ TCustomFSXFunctionWorker }
constructor TCustomFSXFunctionWorker.Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings);
begin
  FCurrentStateLock := TCriticalSection.Create;

  { We can't pass ourselves as the Data Handler, as it would keep a reference to
    this worker from the SimConnect interface. That'd mean the worker never
    gets destroyed, and SimConnect never shuts down. Hence this proxy class. }
  FDataHandler := TCustomFSXFunctionWorkerDataHandler.Create(Self);

  inherited Create(AStates, ASettings);
end;


destructor TCustomFSXFunctionWorker.Destroy;
begin
  FreeAndNil(FCurrentStateLock);

  if DefinitionID <> 0 then
    SimConnect.RemoveDefinition(DefinitionID, DataHandler);

  inherited Destroy;
end;


procedure TCustomFSXFunctionWorker.RegisterStates(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings);
begin
  inherited RegisterStates(AStates, ASettings);

  { Make sure we have a default state }
  if States.Count > 0 then
    SetCurrentState((States[0] as ILEDStateWorker), False);
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


procedure TCustomFSXFunctionWorker.SetCurrentState(const AUID: string; ANotifyObservers: Boolean);
begin
  SetCurrentState(FindState(AUID), ANotifyObservers);
end;


procedure TCustomFSXFunctionWorker.SetCurrentState(AState: ILEDStateWorker; ANotifyObservers: Boolean);
begin
  FCurrentStateLock.Acquire;
  try
    if AState <> FCurrentState then
    begin
      FCurrentState := AState;

      if ANotifyObservers then
        NotifyObservers;
    end;
  finally
    FCurrentStateLock.Release;
  end;
end;


procedure TCustomFSXFunctionWorker.SetSimConnect(const Value: IFSXSimConnect);
var
  definition: IFSXSimConnectDefinition;

begin
  FSimConnect := Value;

  if Assigned(SimConnect) then
  begin
    definition := SimConnect.CreateDefinition;
    RegisterVariables(definition);

    FDefinitionID := SimConnect.AddDefinition(definition, DataHandler);
  end;
end;


{ TCustomFSXFunctionWorkerDataHandler }
constructor TCustomFSXFunctionWorkerDataHandler.Create(AWorker: TCustomFSXFunctionWorker);
begin
  inherited Create;

  FWorker := AWorker;
end;


procedure TCustomFSXFunctionWorkerDataHandler.HandleData(AData: Pointer);
begin
  Worker.HandleData(AData);
end;


initialization
  TLEDFunctionRegistry.Register(TFSXLEDFunctionProvider.Create);

end.

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
    FSimConnect: IFSXSimConnect;
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
    property Provider: TFSXLEDFunctionProvider read FProvider;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
  end;


  TCustomFSXFunctionClass = class of TCustomFSXFunction;


  TCustomFSXFunctionWorker = class(TCustomLEDFunctionWorker, IFSXSimConnectDataHandler)
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

    { IFSXSimConnectDataHandler }
    procedure HandleData(AData: Pointer); virtual; abstract;
  public
    constructor Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; ASimConnect: IFSXSimConnect);
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
      FSimConnect := TFSXSimConnectInterface.Create;
      FSimConnect.Attach(Self);
    end;

    Result := FSimConnect;
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
constructor TCustomFSXFunctionWorker.Create(AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; ASimConnect: IFSXSimConnect);
begin
  inherited Create(AStates, ASettings);

  FCurrentStateLock := TCriticalSection.Create;
  FSimConnect := ASimConnect;

  FDefinition := ASimConnect.CreateDefinition;
  RegisterVariables;

  // TODO pass self as callback for this definition
  ASimConnect.AddDefinition(FDefinition, Self);
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

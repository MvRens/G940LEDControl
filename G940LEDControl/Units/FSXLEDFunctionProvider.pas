unit FSXLEDFunctionProvider;

interface
uses
  Generics.Collections,
  System.SyncObjs,

  X2Log.Intf,

  FSXLEDFunctionProviderIntf,
  FSXSimConnectIntf,
  LEDFunction,
  LEDFunctionIntf,
  LEDStateIntf;


type
  TCustomFSXFunction = class;
  TCustomFSXFunctionList = TObjectList<TCustomFSXFunction>;


  TFSXLEDFunctionProvider = class(TCustomLEDFunctionProvider, IFSXLEDFunctionProvider, IFSXSimConnectObserver)
  private
    FSimConnect: TInterfacedObject;
    FSimConnectLock: TCriticalSection;
    FProfileMenuSimConnect: IFSXSimConnectProfileMenu;
  protected
    procedure RegisterFunctions; override;

    function GetUID: string; override;
  protected
    { IFSXSimConnectObserver }
    procedure ObserveDestroy(Sender: IFSXSimConnect);

    { IFSXLEDFunctionProvider }
    procedure SetProfileMenu(AEnabled: Boolean; ACascaded: Boolean);
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
    function DoCreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): TCustomLEDFunctionWorker; override;

    property Provider: TFSXLEDFunctionProvider read FProvider;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;
  public
    constructor Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
  end;


  TCustomFSXFunctionClass = class of TCustomFSXFunction;


  TCustomFSXFunctionWorker = class(TCustomLEDMultiStateFunctionWorker)
  private
    FDataHandler: IFSXSimConnectDataHandler;
    FDefinitionID: Cardinal;
    FSimConnect: IFSXSimConnect;
  protected
    procedure RegisterVariables(ADefinition: IFSXSimConnectDefinition); virtual; abstract;

    procedure SetSimConnect(const Value: IFSXSimConnect); virtual;

    property DataHandler: IFSXSimConnectDataHandler read FDataHandler;
    property DefinitionID: Cardinal read FDefinitionID;
    property SimConnect: IFSXSimConnect read FSimConnect write SetSimConnect;
  protected
    procedure HandleData(AData: Pointer); virtual; abstract;
  public
    constructor Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''); override;
    destructor Destroy; override;
  end;


implementation
uses
  System.SysUtils,

  X2Log.Global,

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
  { Systems }
  RegisterFunction(TFSXBatteryMasterFunction.Create(      Self, FSXFunctionDisplayNameBatteryMaster,        FSXFunctionUIDBatteryMaster));
  RegisterFunction(TFSXDeIceFunction.Create(              Self, FSXFunctionDisplayNameDeIce,                FSXFunctionUIDDeIce));
  RegisterFunction(TFSXExitDoorFunction.Create(           Self, FSXFunctionDisplayNameExitDoor,             FSXFunctionUIDExitDoor));
  RegisterFunction(TFSXGearFunction.Create(               Self, FSXFunctionDisplayNameGear,                 FSXFunctionUIDGear));
  RegisterFunction(TFSXParkingBrakeFunction.Create(       Self, FSXFunctionDisplayNameParkingBrake,         FSXFunctionUIDParkingBrake));
  RegisterFunction(TFSXAutoBrakeFunction.Create(          Self, FSXFunctionDisplayNameAutoBrake,            FSXFunctionUIDAutoBrake));
  RegisterFunction(TFSXPressDumpSwitchFunction.Create(    Self, FSXFunctionDisplayNamePressDumpSwitch,      FSXFunctionUIDPressDumpSwitch));
  RegisterFunction(TFSXTailHookFunction.Create(           Self, FSXFunctionDisplayNameTailHook,             FSXFunctionUIDTailHook));

  { Instruments }
  RegisterFunction(TFSXPitotOnOffFunction.Create(         Self, FSXFunctionDisplayNamePitotOnOff,           FSXFunctionUIDPitotOnOff));
  RegisterFunction(TFSXPitotWarningFunction.Create(       Self, FSXFunctionDisplayNamePitotWarning,         FSXFunctionUIDPitotWarning));

  { Engines }
  RegisterFunction(TFSXEngineAntiIceFunction.Create(      Self, FSXFunctionDisplayNameEngineAntiIce,        FSXFunctionUIDEngineAntiIce));
  RegisterFunction(TFSXEngineFunction.Create(             Self, FSXFunctionDisplayNameEngine,               FSXFunctionUIDEngine));
  RegisterFunction(TFSXThrottleFunction.Create(           Self, FSXFunctionDisplayNameThrottle,             FSXFunctionUIDThrottle));

  { Control surfaces }
  RegisterFunction(TFSXFlapsFunction.Create(              Self, FSXFunctionDisplayNameFlaps,                FSXFunctionUIDFlaps));
  RegisterFunction(TFSXSpoilersFunction.Create(           Self, FSXFunctionDisplayNameSpoilers,             FSXFunctionUIDSpoilers));
  RegisterFunction(TFSXSpoilersArmedFunction.Create(      Self, FSXFunctionDisplayNameSpoilersArmed,        FSXFunctionUIDSpoilersArmed));

  { Lights }
  RegisterFunction(TFSXBeaconLightsFunction.Create(       Self, FSXFunctionDisplayNameBeaconLights,         FSXFunctionUIDBeaconLights));
  RegisterFunction(TFSXInstrumentLightsFunction.Create(   Self, FSXFunctionDisplayNameInstrumentLights,     FSXFunctionUIDInstrumentLights));
  RegisterFunction(TFSXLandingLightsFunction.Create(      Self, FSXFunctionDisplayNameLandingLights,        FSXFunctionUIDLandingLights));
  RegisterFunction(TFSXNavLightsFunction.Create(          Self, FSXFunctionDisplayNameNavLights,            FSXFunctionUIDNavLights));
  RegisterFunction(TFSXRecognitionLightsFunction.Create(  Self, FSXFunctionDisplayNameRecognitionLights,    FSXFunctionUIDRecognitionLights));
  RegisterFunction(TFSXStrobeLightsFunction.Create(       Self, FSXFunctionDisplayNameStrobeLights,         FSXFunctionUIDStrobeLights));
  RegisterFunction(TFSXTaxiLightsFunction.Create(         Self, FSXFunctionDisplayNameTaxiLights,           FSXFunctionUIDTaxiLights));
  RegisterFunction(TFSXAllLightsFunction.Create(          Self, FSXFunctionDisplayNameAllLights,            FSXFunctionUIDAllLights));

  { Autopilot }
  RegisterFunction(TFSXAutoPilotFunction.Create(          Self, FSXFunctionDisplayNameAutoPilot,            FSXFunctionUIDAutoPilot));
  RegisterFunction(TFSXAutoPilotAltitudeFunction.Create(  Self, FSXFunctionDisplayNameAutoPilotAltitude,    FSXFunctionUIDAutoPilotAltitude));
  RegisterFunction(TFSXAutoPilotApproachFunction.Create(  Self, FSXFunctionDisplayNameAutoPilotApproach,    FSXFunctionUIDAutoPilotApproach));
  RegisterFunction(TFSXAutoPilotBackcourseFunction.Create(Self, FSXFunctionDisplayNameAutoPilotBackcourse,  FSXFunctionUIDAutoPilotBackcourse));
  RegisterFunction(TFSXAutoPilotHeadingFunction.Create(   Self, FSXFunctionDisplayNameAutoPilotHeading,     FSXFunctionUIDAutoPilotHeading));
  RegisterFunction(TFSXAutoPilotNavFunction.Create(       Self, FSXFunctionDisplayNameAutoPilotNav,         FSXFunctionUIDAutoPilotNav));

  { Radios }
  RegisterFunction(TFSXAvionicsMasterFunction.Create(     Self, FSXFunctionDisplayNameAvionicsMaster,       FSXFunctionUIDAvionicsMaster));

  { Fuel }
  RegisterFunction(TFSXFuelFunction.Create(               Self, FSXFunctionDisplayNameFuel,                 FSXFunctionUIDFuel));

  { ATC }
  RegisterFunction(TFSXATCVisibilityFunction.Create(FSXProviderUID));
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
      FSimConnect := TFSXSimConnectInterface.Create(TX2GlobalLog.Category('FSX SimConnect'));
      (FSimConnect as IFSXSimConnect).Attach(Self);
    end;

    Result := (FSimConnect as IFSXSimConnect);
  finally
    FSimConnectLock.Release;
  end;
end;


procedure TFSXLEDFunctionProvider.SetProfileMenu(AEnabled: Boolean; ACascaded: Boolean);
begin
  if AEnabled and (not Assigned(FProfileMenuSimConnect)) then
    FProfileMenuSimConnect := (GetSimConnect as IFSXSimConnectProfileMenu);

  if Assigned(FProfileMenuSimConnect) then
    FProfileMenuSimConnect.SetProfileMenu(AEnabled, ACascaded);

  if not AEnabled then
    FProfileMenuSimConnect := nil;
end;



{ TCustomFSXFunction }
constructor TCustomFSXFunction.Create(AProvider: TFSXLEDFunctionProvider; const ADisplayName, AUID: string);
begin
  inherited Create(AProvider.GetUID);

  FProvider := AProvider;
  FDisplayName := ADisplayName;
  FUID := AUID;
end;


function TCustomFSXFunction.DoCreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string): TCustomLEDFunctionWorker;
begin
  Result := inherited DoCreateWorker(ASettings, APreviousState);

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
constructor TCustomFSXFunctionWorker.Create(const AProviderUID, AFunctionUID: string; AStates: ILEDMultiStateFunction; ASettings: ILEDFunctionWorkerSettings; const APreviousState: string);
begin
  { We can't pass ourselves as the Data Handler, as it would keep a reference to
    this worker from the SimConnect interface. That'd mean the worker never
    gets destroyed, and SimConnect never shuts down. Hence this proxy class. }
  FDataHandler := TCustomFSXFunctionWorkerDataHandler.Create(Self);

  inherited Create(AProviderUID, AFunctionUID, AStates, ASettings, APreviousState);
end;


destructor TCustomFSXFunctionWorker.Destroy;
begin
  if DefinitionID <> 0 then
    SimConnect.RemoveDefinition(DefinitionID, DataHandler);

  inherited Destroy;
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

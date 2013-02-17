unit FSXLEDStateProvider;

interface
uses
  Classes,
  Messages,
  SyncObjs,
  Windows,

  LEDFunctionMap,
  LEDStateConsumer,
  LEDStateProvider,
  SimConnect;

  
const
  { Note: do not change these values, the config demands it! }
  FUNCTION_FSX_GEAR = FUNCTION_PROVIDER_OFFSET + 1;
  FUNCTION_FSX_LANDINGLIGHTS = FUNCTION_PROVIDER_OFFSET + 2;
  FUNCTION_FSX_INSTRUMENTLIGHTS = FUNCTION_PROVIDER_OFFSET + 3;
  FUNCTION_FSX_PARKINGBRAKE = FUNCTION_PROVIDER_OFFSET + 4;
  FUNCTION_FSX_ENGINE = FUNCTION_PROVIDER_OFFSET + 5;

  FUNCTION_FSX_EXITDOOR = FUNCTION_PROVIDER_OFFSET + 6;
  FUNCTION_FSX_STROBELIGHTS = FUNCTION_PROVIDER_OFFSET + 7;
  FUNCTION_FSX_NAVLIGHTS = FUNCTION_PROVIDER_OFFSET + 8;
  FUNCTION_FSX_BEACONLIGHTS = FUNCTION_PROVIDER_OFFSET + 9;
  FUNCTION_FSX_FLAPS = FUNCTION_PROVIDER_OFFSET + 10;
  FUNCTION_FSX_BATTERYMASTER = FUNCTION_PROVIDER_OFFSET + 11;
  FUNCTION_FSX_AVIONICSMASTER = FUNCTION_PROVIDER_OFFSET + 12;

  FUNCTION_FSX_SPOILERS = FUNCTION_PROVIDER_OFFSET + 13;

  FUNCTION_FSX_PRESSURIZATIONDUMPSWITCH = FUNCTION_PROVIDER_OFFSET + 14;
  FUNCTION_FSX_ENGINEANTIICE = FUNCTION_PROVIDER_OFFSET + 15;
  FUNCTION_FSX_AUTOPILOT = FUNCTION_PROVIDER_OFFSET + 16;
  FUNCTION_FSX_FUELPUMP = FUNCTION_PROVIDER_OFFSET + 17;

  FUNCTION_FSX_TAILHOOK = FUNCTION_PROVIDER_OFFSET + 18;

  FUNCTION_FSX_AUTOPILOT_AMBER = FUNCTION_PROVIDER_OFFSET + 19;
  FUNCTION_FSX_AUTOPILOT_HEADING = FUNCTION_PROVIDER_OFFSET + 20;
  FUNCTION_FSX_AUTOPILOT_APPROACH = FUNCTION_PROVIDER_OFFSET + 21;
  FUNCTION_FSX_AUTOPILOT_BACKCOURSE = FUNCTION_PROVIDER_OFFSET + 22;
  FUNCTION_FSX_AUTOPILOT_ALTITUDE = FUNCTION_PROVIDER_OFFSET + 23;
  FUNCTION_FSX_AUTOPILOT_NAV = FUNCTION_PROVIDER_OFFSET + 24;

  FUNCTION_FSX_TAXILIGHTS = FUNCTION_PROVIDER_OFFSET + 25;
  FUNCTION_FSX_RECOGNITIONLIGHTS = FUNCTION_PROVIDER_OFFSET + 26;

  FUNCTION_FSX_DEICE = FUNCTION_PROVIDER_OFFSET + 27;


type
  TFSXLEDStateProvider = class(TLEDStateProvider)
  private
    FSimConnectHandle: THandle;
    FDefinitions: TList;
//    FLastDown: Boolean;
  protected
    function GetProcessMessagesInterval: Integer; override;

    procedure UpdateMap;
    procedure HandleDispatch(AData: PSimConnectRecv);

    procedure HandleGearData(AData: Pointer);
    procedure HandleLightsData(AData: Pointer);
    procedure HandleParkingBrakeData(AData: Pointer);
    procedure HandleEngineData(AData: Pointer);
    procedure HandleExitDoorData(AData: Pointer);
    procedure HandleFlapsData(AData: Pointer);
    procedure HandleSwitchesData(AData: Pointer);
    procedure HandleAntiIceData(AData: Pointer);

    procedure AddVariable(ADefineID: Cardinal; ADatumName, AUnitsName: string;
                          ADatumType: SIMCONNECT_DATAType = SIMCONNECT_DATAType_FLOAT64;
                          AEpsilon: Single = 0; ADatumID: DWORD = SIMCONNECT_UNUSED);
    procedure AddDefinition(ADefinition: Cardinal);
    procedure ClearDefinitions;

    procedure SetFSXLightState(AStates: Cardinal; AMask, AFunction: Integer);

    property SimConnectHandle: THandle read FSimConnectHandle;
  public
    class procedure EnumFunctions(AConsumer: IFunctionConsumer); override;

    constructor Create(AConsumer: ILEDStateConsumer); override;
    destructor Destroy; override;

    procedure Initialize; override;
    procedure Finalize; override;
    procedure ProcessMessages; override;
  end;


implementation
uses
  ComObj,
  Math,
  SysUtils;


const
  APPNAME = 'G940 LED Control';

  MAX_ENGINES = 4;

  DEFINITION_GEAR = 1;
  DEFINITION_LIGHTS = 2;
  DEFINITION_INSTRUMENTLIGHTS = 3;
  DEFINITION_PARKINGBRAKE = 4;
  DEFINITION_ENGINE = 5;
  DEFINITION_THROTTLE = 6;
  DEFINITION_EXITDOOR = 7;
  DEFINITION_FLAPSSPOILERS = 8;
  DEFINITION_SWITCHES = 9;
  DEFINITION_ANTIICE = 10;

//  EVENT_ZOOM = 10;

  FSX_UNIT_PERCENT = 'percent';
  FSX_UNIT_MASK = 'mask';
  FSX_UNIT_BOOL = 'bool';
  FSX_UNIT_NUMBER = 'number';

  FSX_LIGHTON_NAV = $0001;
  FSX_LIGHTON_BEACON = $0002;
  FSX_LIGHTON_LANDING = $0004;
  FSX_LIGHTON_TAXI = $0008;
  FSX_LIGHTON_STROBE = $0010;
  FSX_LIGHTON_PANEL = $0020;
  FSX_LIGHTON_RECOGNITION = $0040;
  FSX_LIGHTON_CABIN = $0200;


type
  TThrottleData = packed record
    NumberOfEngines: Integer;
    ThrottleLeverPos: array[1..MAX_ENGINES] of Double;
  end;



{ TFSXLEDStateProvider }
class procedure TFSXLEDStateProvider.EnumFunctions(AConsumer: IFunctionConsumer);
begin
  inherited;

  AConsumer.SetCategory('Dynamic');

//  AConsumer.AddFunction(FUNCTION_FSX_FUELPUMP, 'Fuel boost pump');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT, 'Auto pilot (main)');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_ALTITUDE, 'Auto pilot - Altitude');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_AMBER, 'Auto pilot (main - off / amber)');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_APPROACH, 'Auto pilot - Approach');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_BACKCOURSE, 'Auto pilot - Backcourse');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_HEADING, 'Auto pilot - Heading');
  AConsumer.AddFunction(FUNCTION_FSX_AUTOPILOT_NAV, 'Auto pilot - Nav');
  AConsumer.AddFunction(FUNCTION_FSX_AVIONICSMASTER, 'Avionics master switch');
  AConsumer.AddFunction(FUNCTION_FSX_BATTERYMASTER, 'Battery master switch');
  AConsumer.AddFunction(FUNCTION_FSX_BEACONLIGHTS, 'Beacon lights');
  AConsumer.AddFunction(FUNCTION_FSX_DEICE, 'De-ice');
  AConsumer.AddFunction(FUNCTION_FSX_ENGINE, 'Engine');
  AConsumer.AddFunction(FUNCTION_FSX_ENGINEANTIICE, 'Engine anti-ice');
  AConsumer.AddFunction(FUNCTION_FSX_EXITDOOR, 'Exit door');
  AConsumer.AddFunction(FUNCTION_FSX_FLAPS, 'Flaps');
  AConsumer.AddFunction(FUNCTION_FSX_GEAR, 'Landing gear');
  AConsumer.AddFunction(FUNCTION_FSX_INSTRUMENTLIGHTS, 'Instrument lights');
  AConsumer.AddFunction(FUNCTION_FSX_LANDINGLIGHTS, 'Landing lights');
  AConsumer.AddFunction(FUNCTION_FSX_NAVLIGHTS, 'Nav lights');
  AConsumer.AddFunction(FUNCTION_FSX_PARKINGBRAKE, 'Parking brake');
  AConsumer.AddFunction(FUNCTION_FSX_PRESSURIZATIONDUMPSWITCH, 'Pressurization dump switch');
  AConsumer.AddFunction(FUNCTION_FSX_RECOGNITIONLIGHTS, 'Recognition lights');
  AConsumer.AddFunction(FUNCTION_FSX_SPOILERS, 'Spoilers (air brake)');
  AConsumer.AddFunction(FUNCTION_FSX_STROBELIGHTS, 'Strobe lights');
  AConsumer.AddFunction(FUNCTION_FSX_TAILHOOK, 'Tail hook');
  AConsumer.AddFunction(FUNCTION_FSX_TAXILIGHTS, 'Taxi lights');
end;


constructor TFSXLEDStateProvider.Create(AConsumer: ILEDStateConsumer);
begin
  inherited;

  FDefinitions := TList.Create;
end;


destructor TFSXLEDStateProvider.Destroy;
begin
  FreeAndNil(FDefinitions);

  inherited;
end;


procedure TFSXLEDStateProvider.Initialize;
begin
  inherited;

  if not InitSimConnect then
    raise EInitializeError.Create('SimConnect.dll could not be loaded');

  if SimConnect_Open(FSimConnectHandle, APPNAME, 0, 0, 0, 0) <> S_OK then
    raise EInitializeError.Create('Connection to Flight Simulator could not be established. Is it running?');

  UpdateMap;

//  SimConnect_MapClientEventToSimEvent(SimConnectHandle, EVENT_ZOOM, 'VIEW_ZOOM_SET');
end;


procedure TFSXLEDStateProvider.Finalize;
begin
  inherited;

  ClearDefinitions;

  if SimConnectHandle <> 0 then
  begin
    SimConnect_Close(SimConnectHandle);
    FSimConnectHandle := 0;
  end;
end;


procedure TFSXLEDStateProvider.ProcessMessages;
var
  data: PSimConnectRecv;
  dataSize: Cardinal;
//  down: Boolean;
//  level: Integer;
//  state: Integer;

begin
  inherited;

  while SimConnect_GetNextDispatch(SimConnectHandle, data, dataSize) = S_OK do
    HandleDispatch(data);

  {
  state := GetKeyState(VK_CONTROL);
  down := ((state and $8000) <> 0);
  if down <> FLastDown then
  begin
    if down then
      level := 4 * 64
    else
      level := 26;

    SimConnect_TransmitClientEvent(SimConnectHandle, 0, EVENT_ZOOM, level, SIMCONNECT_GROUP_PRIORITY_STANDARD, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
    FLastDown := down;
  end;
  }
end;


procedure TFSXLEDStateProvider.UpdateMap;
var
  engineIndex: Integer;

begin
  ClearDefinitions;

  { Gear }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_GEAR) then
  begin
    AddVariable(DEFINITION_GEAR, 'IS GEAR RETRACTABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_GEAR, 'GEAR TOTAL PCT EXTENDED', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
    AddVariable(DEFINITION_GEAR, 'GEAR DAMAGE BY SPEED', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_GEAR, 'GEAR SPEED EXCEEDED', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddDefinition(DEFINITION_GEAR);
  end;

  { Lights }
  if Consumer.FunctionMap.HasFunction([FUNCTION_FSX_LANDINGLIGHTS, FUNCTION_FSX_INSTRUMENTLIGHTS,
                                       FUNCTION_FSX_STROBELIGHTS, FUNCTION_FSX_NAVLIGHTS,
                                       FUNCTION_FSX_BEACONLIGHTS, FUNCTION_FSX_TAXILIGHTS,
                                       FUNCTION_FSX_RECOGNITIONLIGHTS]) then
  begin
    AddVariable(DEFINITION_LIGHTS, 'LIGHT ON STATES', FSX_UNIT_MASK, SIMCONNECT_DATATYPE_INT32);
    AddDefinition(DEFINITION_LIGHTS);
  end;

  { Parking brake }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_PARKINGBRAKE) then
  begin
    AddVariable(DEFINITION_PARKINGBRAKE, 'BRAKE PARKING INDICATOR', FSX_UNIT_BOOL, SIMCONNECT_DATATYPE_INT32);
    AddDefinition(DEFINITION_PARKINGBRAKE);
  end;

  { Engine }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_ENGINE) then
  begin
    AddVariable(DEFINITION_ENGINE, 'NUMBER OF ENGINES', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ENGINE, Format('GENERAL ENG COMBUSTION:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ENGINE, Format('ENG FAILED:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ENGINE, Format('ENG ON FIRE:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    AddDefinition(DEFINITION_ENGINE);
  end;

  { Exit door }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_EXITDOOR) or
     Consumer.FunctionMap.HasFunction(FUNCTION_FSX_TAILHOOK) then
  begin
    AddVariable(DEFINITION_EXITDOOR, 'CANOPY OPEN', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
    AddVariable(DEFINITION_EXITDOOR, 'TAILHOOK POSITION', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
    AddDefinition(DEFINITION_EXITDOOR);
  end;

  { Flaps & spoilers }
  if Consumer.FunctionMap.HasFunction([FUNCTION_FSX_FLAPS, FUNCTION_FSX_SPOILERS]) then
  begin
    AddVariable(DEFINITION_FLAPSSPOILERS, 'FLAPS AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_FLAPSSPOILERS, 'FLAPS HANDLE PERCENT', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
    AddVariable(DEFINITION_FLAPSSPOILERS, 'SPOILER AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_FLAPSSPOILERS, 'SPOILERS HANDLE POSITION', FSX_UNIT_PERCENT, SIMCONNECT_DATAType_FLOAT64);
    AddDefinition(DEFINITION_FLAPSSPOILERS);
  end;

  { Master switches }
  if Consumer.FunctionMap.HasFunction([FUNCTION_FSX_BATTERYMASTER, FUNCTION_FSX_AVIONICSMASTER,
                                       FUNCTION_FSX_PRESSURIZATIONDUMPSWITCH,
                                       FUNCTION_FSX_AUTOPILOT, FUNCTION_FSX_FUELPUMP,
                                       FUNCTION_FSX_AUTOPILOT_AMBER, FUNCTION_FSX_AUTOPILOT_HEADING,
                                       FUNCTION_FSX_AUTOPILOT_APPROACH, FUNCTION_FSX_AUTOPILOT_BACKCOURSE,
                                       FUNCTION_FSX_AUTOPILOT_ALTITUDE, FUNCTION_FSX_AUTOPILOT_NAV]) then
  begin
    AddVariable(DEFINITION_SWITCHES, 'AVIONICS MASTER SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'ELECTRICAL MASTER BATTERY', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'PRESSURIZATION DUMP SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT AVAILABLE', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT MASTER', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
//    AddVariable(DEFINITION_SWITCHES, 'fuel pump?', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT HEADING LOCK', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT APPROACH HOLD', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT BACKCOURSE HOLD', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT ALTITUDE LOCK', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_SWITCHES, 'AUTOPILOT NAV1 LOCK', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    AddDefinition(DEFINITION_SWITCHES);
  end;

  { Anti-ice }
  if Consumer.FunctionMap.HasFunction([FUNCTION_FSX_ENGINEANTIICE, FUNCTION_FSX_DEICE]) then
  begin
    AddVariable(DEFINITION_ANTIICE, 'NUMBER OF ENGINES', FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

//    for engineIndex := 1 to MAX_ENGINES do
//      AddVariable(DEFINITION_ANTIICE, Format('GENERAL ENG ANTI ICE POSITION:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
//
//    for engineIndex := 1 to MAX_ENGINES do
//      AddVariable(DEFINITION_ANTIICE, Format('PROP DEICE SWITCH:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ANTIICE, Format('ENG ANTI ICE:%d', [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    AddVariable(DEFINITION_ANTIICE, 'STRUCTURAL DEICE SWITCH', FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddDefinition(DEFINITION_ANTIICE);
  end;


  { Throttle }
  {
  AddVariable(DEFINITION_THROTTLE, FSX_VARIABLE_NUMBEROFENGINES, FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

  for engineIndex := 1 to MAX_ENGINES do
    AddVariable(DEFINITION_THROTTLE, Format(FSX_VARIABLE_ENGTHROTTLELEVERPOS, [engineIndex]), FSX_UNIT_PERCENT);

  AddDefinition(DEFINITION_THROTTLE);
  }
end;


procedure TFSXLEDStateProvider.SetFSXLightState(AStates: Cardinal; AMask: Integer; AFunction: Integer);
begin
  if (AStates and AMask) <> 0 then
    Consumer.SetStateByFunction(AFunction, lsGreen)
  else
    Consumer.SetStateByFunction(AFunction, lsRed);
end;


procedure TFSXLEDStateProvider.HandleDispatch(AData: PSimConnectRecv);
var
  simObjectData: PSimConnectRecvSimObjectData;
  data: Pointer;
//  throttleData: PThrottleData;

begin
  case SIMCONNECT_RECV_ID(AData^.dwID) of
    SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
      begin
        simObjectData := PSimConnectRecvSimObjectData(AData);
        data := @simObjectData^.dwData;

        case simObjectData^.dwRequestID of
          DEFINITION_GEAR:          HandleGearData(data);
          DEFINITION_LIGHTS:        HandleLightsData(data);
          DEFINITION_PARKINGBRAKE:  HandleParkingBrakeData(data);
          DEFINITION_ENGINE:        HandleEngineData(data);
          DEFINITION_EXITDOOR:      HandleExitDoorData(data);
          DEFINITION_FLAPSSPOILERS: HandleFlapsData(data);
          DEFINITION_SWITCHES:      HandleSwitchesData(data);
          DEFINITION_ANTIICE:       HandleAntiIceData(data);
          {
          DEFINITION_THROTTLE:
            begin
              throttleData := @simObjectData^.dwData;

              if throttleData^.NumberOfEngines > 2 then
              begin
                if (throttleData^.ThrottleLeverPos[4] <> throttleData^.ThrottleLeverPos[1]) or
                   (throttleData^.ThrottleLeverPos[3] <> throttleData^.ThrottleLeverPos[2]) then
                begin
                  throttleData^.ThrottleLeverPos[4] := throttleData^.ThrottleLeverPos[1];
                  throttleData^.ThrottleLeverPos[3] := throttleData^.ThrottleLeverPos[2];

                  SimConnect_SetDataOnSimObject(SimConnectHandle, DEFINITION_THROTTLE, SIMCONNECT_OBJECT_ID_USER,
                                                0, 0, SizeOf(throttleData^), throttleData);
                end;
              end;
            end;
          }
        end;
      end;

    SIMCONNECT_RECV_ID_QUIT:
      Terminate;
  end;
end;


procedure TFSXLEDStateProvider.HandleGearData(AData: Pointer);
type
  PGearData = ^TGearData;
  TGearData = packed record
    IsGearRetractable: Cardinal;
    TotalPctExtended: Double;
    DamageBySpeed: Integer;
    SpeedExceeded: Integer;
  end;

var
  gearData: PGearData;

begin
  gearData := AData;

  if gearData^.DamageBySpeed <> 0 then
    Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsError)

  else if gearData^.SpeedExceeded <> 0 then
    Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsWarning)

  else if gearData^.IsGearRetractable <> 0 then
  begin
    case Trunc(gearData ^.TotalPctExtended * 100) of
      0:        Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsRed);
      95..100:  Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsGreen);
    else        Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsAmber);
    end;
  end else
    Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsOff);
end;


procedure TFSXLEDStateProvider.HandleLightsData(AData: Pointer);
var
  state: Cardinal;

begin
  state := PCardinal(AData)^;

  SetFSXLightState(state, FSX_LIGHTON_LANDING, FUNCTION_FSX_LANDINGLIGHTS);
  SetFSXLightState(state, FSX_LIGHTON_PANEL, FUNCTION_FSX_INSTRUMENTLIGHTS);
  SetFSXLightState(state, FSX_LIGHTON_BEACON, FUNCTION_FSX_BEACONLIGHTS);
  SetFSXLightState(state, FSX_LIGHTON_NAV, FUNCTION_FSX_NAVLIGHTS);
  SetFSXLightState(state, FSX_LIGHTON_STROBE, FUNCTION_FSX_STROBELIGHTS);
  SetFSXLightState(state, FSX_LIGHTON_TAXI, FUNCTION_FSX_TAXILIGHTS);
  SetFSXLightState(state, FSX_LIGHTON_RECOGNITION, FUNCTION_FSX_RECOGNITIONLIGHTS);
end;


procedure TFSXLEDStateProvider.HandleParkingBrakeData(AData: Pointer);
begin
  if PCardinal(AData)^ <> 0 then
    Consumer.SetStateByFunction(FUNCTION_FSX_PARKINGBRAKE, lsRed)
  else
    Consumer.SetStateByFunction(FUNCTION_FSX_PARKINGBRAKE, lsGreen);
end;


procedure TFSXLEDStateProvider.HandleEngineData(AData: Pointer);
type
  PEngineData = ^TEngineData;
  TEngineData = packed record
    NumberOfEngines: Integer;
    Combustion: array[1..MAX_ENGINES] of Integer;
    Failed: array[1..MAX_ENGINES] of Integer;
    OnFire: array[1..MAX_ENGINES] of Integer;
  end;

var
  engineData: PEngineData;
  engineIndex: Integer;
  state: TLEDState;

begin
  engineData := AData;

  if engineData^.NumberOfEngines > 0 then
  begin
    state := lsGreen;

    for engineIndex := 1 to Min(engineData^.NumberOfEngines, MAX_ENGINES) do
    begin
      if engineData^.OnFire[engineIndex] <> 0 then
      begin
        state := lsError;
        break;

      end else if engineData^.Failed[engineIndex] <> 0 then
        state := lsWarning

      else if (engineData^.Combustion[engineIndex] = 0) and
              (state = lsGreen) then
        state := lsRed;
    end;

    Consumer.SetStateByFunction(FUNCTION_FSX_ENGINE, state);
  end else
    Consumer.SetStateByFunction(FUNCTION_FSX_ENGINE, lsOff);
end;


procedure TFSXLEDStateProvider.HandleExitDoorData(AData: Pointer);
type
  PExitDoorData = ^TExitDoorData;
  TExitDoorData = packed record
    PercentOpen: Double;
    TailHookPercent: Double;
  end;

var
  exitDoorData: PExitDoorData;

begin
  exitDoorData := AData;

  case Trunc(exitDoorData^.PercentOpen) of
    0:        Consumer.SetStateByFunction(FUNCTION_FSX_EXITDOOR, lsGreen);
    95..100:  Consumer.SetStateByFunction(FUNCTION_FSX_EXITDOOR, lsRed);
  else        Consumer.SetStateByFunction(FUNCTION_FSX_EXITDOOR, lsAmber);
  end;

  case Trunc(exitDoorData^.TailHookPercent) of
    0:        Consumer.SetStateByFunction(FUNCTION_FSX_TAILHOOK, lsGreen);
    95..100:  Consumer.SetStateByFunction(FUNCTION_FSX_TAILHOOK, lsRed);
  else        Consumer.SetStateByFunction(FUNCTION_FSX_TAILHOOK, lsAmber);
  end;
end;


procedure TFSXLEDStateProvider.HandleFlapsData(AData: Pointer);
type
  PFlapsData = ^TFlapsData;
  TFlapsData = packed record
    FlapsAvailable: Cardinal;
    FlapsHandlePercent: Double;
    SpoilersAvailable: Cardinal;
    SpoilersHandlePercent: Double;
  end;

var
  flapsData: PFlapsData;

begin
  flapsData := AData;

  if flapsData^.FlapsAvailable <> 0 then
  begin
    case Trunc(flapsData^.FlapsHandlePercent) of
      0:        Consumer.SetStateByFunction(FUNCTION_FSX_FLAPS, lsGreen);
      95..100:  Consumer.SetStateByFunction(FUNCTION_FSX_FLAPS, lsRed);
    else        Consumer.SetStateByFunction(FUNCTION_FSX_FLAPS, lsAmber);
    end;
  end else
    Consumer.SetStateByFunction(FUNCTION_FSX_FLAPS, lsOff);

  if flapsData^.SpoilersAvailable <> 0 then
  begin
    case Trunc(flapsData^.SpoilersHandlePercent) of
      0:        Consumer.SetStateByFunction(FUNCTION_FSX_SPOILERS, lsGreen);
      95..100:  Consumer.SetStateByFunction(FUNCTION_FSX_SPOILERS, lsRed);
    else        Consumer.SetStateByFunction(FUNCTION_FSX_SPOILERS, lsAmber);
    end;
  end else
    Consumer.SetStateByFunction(FUNCTION_FSX_SPOILERS, lsOff);
end;


procedure TFSXLEDStateProvider.HandleSwitchesData(AData: Pointer);
const
  ONOFF_STATE: array[Boolean] of TLEDState = (lsRed, lsGreen);
  AMBER_ONOFF_STATE: array[Boolean] of TLEDState = (lsOff, lsAmber);

type
  PSwitchesData = ^TSwitchesData;
  TSwitchesData = packed record
    AvionicsSwitch: Cardinal;
    BatterySwitch: Cardinal;
    PressurizationDumpSwitch: Cardinal;
    AutoPilotAvailable: Cardinal;
    AutoPilotMaster: Cardinal;
    AutoPilotHeading: Cardinal;
    AutoPilotApproach: Cardinal;
    AutoPilotBackcourse: Cardinal;
    AutoPilotAltitude: Cardinal;
    AutoPilotNav: Cardinal;
  end;

var
  switchesData: PSwitchesData;

begin
  switchesData := AData;

  Consumer.SetStateByFunction(FUNCTION_FSX_AVIONICSMASTER, ONOFF_STATE[switchesData^.AvionicsSwitch <> 0]);
  Consumer.SetStateByFunction(FUNCTION_FSX_BATTERYMASTER, ONOFF_STATE[switchesData^.BatterySwitch <> 0]);
  Consumer.SetStateByFunction(FUNCTION_FSX_PRESSURIZATIONDUMPSWITCH, ONOFF_STATE[switchesData^.PressurizationDumpSwitch <> 0]);

  if switchesData^.AutoPilotAvailable <> 0 then
  begin
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT, ONOFF_STATE[switchesData^.AutoPilotMaster <> 0]);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_AMBER, AMBER_ONOFF_STATE[switchesData^.AutoPilotMaster <> 0]);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_HEADING, AMBER_ONOFF_STATE[switchesData^.AutoPilotHeading <> 0]);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_APPROACH, AMBER_ONOFF_STATE[switchesData^.AutoPilotApproach <> 0]);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_BACKCOURSE, AMBER_ONOFF_STATE[switchesData^.AutoPilotBackcourse <> 0]);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_ALTITUDE, AMBER_ONOFF_STATE[switchesData^.AutoPilotAltitude <> 0]);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_NAV, AMBER_ONOFF_STATE[switchesData^.AutoPilotNav <> 0]);
  end else
  begin
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT, lsOff);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_AMBER, lsOff);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_HEADING, lsOff);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_APPROACH, lsOff);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_BACKCOURSE, lsOff);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_ALTITUDE, lsOff);
    Consumer.SetStateByFunction(FUNCTION_FSX_AUTOPILOT_NAV, lsOff);
  end;
end;


procedure TFSXLEDStateProvider.HandleAntiIceData(AData: Pointer);

  function EngineHasBoolean(AArray: array of Integer; ANumberOfEngines: Integer): Boolean;
  var
    engineIndex: Integer;

  begin
    Result := False;

    for engineIndex := 1 to Max(ANumberOfEngines, MAX_ENGINES) do
      if AArray[engineIndex] <> 0 then
      begin
        Result := True;
        break;
      end;
  end;

const
  ONOFF_STATE: array[Boolean] of TLEDState = (lsRed, lsGreen);

type
  PAntiIceData = ^TAntiIceData;
  TAntiIceData = packed record
    NumberOfEngines: Integer;
//    GeneralEngineAntiIce: array[1..MAX_ENGINES] of Integer;
//    PropDeIce: array[1..MAX_ENGINES] of Integer;
    EngineAntiIce: array[1..MAX_ENGINES] of Integer;
    StructuralAntiIce: Integer;
  end;

var
  antiIceData: PAntiIceData;

begin
  antiIceData := AData;

  Consumer.SetStateByFunction(FUNCTION_FSX_DEICE, ONOFF_STATE[antiIceData^.StructuralAntiIce <> 0]);
  Consumer.SetStateByFunction(FUNCTION_FSX_ENGINEANTIICE, ONOFF_STATE[EngineHasBoolean(antiIceData^.EngineAntiIce, antiIceData^.NumberOfEngines)]);
end;


procedure TFSXLEDStateProvider.AddDefinition(ADefinition: Cardinal);
begin
  FDefinitions.Add(Pointer(ADefinition));
  SimConnect_RequestDataOnSimObject(SimConnectHandle,
                                    ADefinition,
                                    ADefinition,
                                    SIMCONNECT_OBJECT_ID_USER,
                                    SIMCONNECT_PERIOD_SIM_FRAME,
                                    SIMCONNECT_DATA_REQUEST_FLAG_CHANGED);
end;


procedure TFSXLEDStateProvider.AddVariable(ADefineID: Cardinal; ADatumName, AUnitsName: string;
                                           ADatumType: SIMCONNECT_DATAType; AEpsilon: Single;
                                           ADatumID: DWORD);
begin
  SimConnect_AddToDataDefinition(SimConnectHandle, ADefineID, AnsiString(ADatumName), AnsiString(AUnitsName), ADatumType, AEpsilon, ADatumID);
end;

procedure TFSXLEDStateProvider.ClearDefinitions;
var
  definition: Pointer;

begin
  if SimConnectHandle <> 0 then
  begin
    for definition in FDefinitions do
      SimConnect_ClearDataDefinition(SimConnectHandle, Cardinal(definition));
  end;

  FDefinitions.Clear;
end;


function TFSXLEDStateProvider.GetProcessMessagesInterval: Integer;
begin
  Result := 50;
end;

end.

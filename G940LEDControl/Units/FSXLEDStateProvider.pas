unit FSXLEDStateProvider;

interface
uses
  Classes,
  SyncObjs,
  Windows,

  LEDFunctionMap,
  LEDStateConsumer,
  LEDStateProvider,
  SimConnect;

  
const
  FUNCTION_FSX_GEAR = FUNCTION_PROVIDER_OFFSET + 1;
  FUNCTION_FSX_LANDINGLIGHTS = FUNCTION_PROVIDER_OFFSET + 2;
  FUNCTION_FSX_INSTRUMENTLIGHTS = FUNCTION_PROVIDER_OFFSET + 3;
  FUNCTION_FSX_PARKINGBRAKE = FUNCTION_PROVIDER_OFFSET + 4;
  FUNCTION_FSX_ENGINE = FUNCTION_PROVIDER_OFFSET + 5;


type
  TFSXLEDStateProvider = class(TLEDStateProvider)
  private
    FSimConnectHandle: THandle;
    FDefinitions: TList;
  protected
    function GetProcessMessagesInterval: Integer; override;

    procedure UpdateMap;
    procedure HandleDispatch(AData: PSimConnectRecv);

    procedure AddVariable(ADefineID: Cardinal; ADatumName, AUnitsName: string;
                          ADatumType: SIMCONNECT_DATAType = SIMCONNECT_DATAType_FLOAT64;
                          AEpsilon: Single = 0; ADatumID: DWORD = SIMCONNECT_UNUSED);
    procedure AddDefinition(ADefinition: Cardinal);
    procedure ClearDefinitions;

    property SimConnectHandle: THandle read FSimConnectHandle;
  public
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

  FSX_VARIABLE_ISGEARRETRACTABLE = 'IS GEAR RETRACTABLE';
  FSX_VARIABLE_GEARTOTALPCTEXTENDED = 'GEAR TOTAL PCT EXTENDED';
  FSX_VARIABLE_LIGHTONSTATES = 'LIGHT ON STATES';
  FSX_VARIABLE_PARKINGBRAKE = 'BRAKE PARKING INDICATOR';
  FSX_VARIABLE_NUMBEROFENGINES = 'NUMBER OF ENGINES';
  FSX_VARIABLE_ENGCOMBUSTION = 'GENERAL ENG COMBUSTION:%d';
  FSX_VARIABLE_ENGFAILED = 'ENG FAILED:%d';
  FSX_VARIABLE_ENGONFIRE = 'ENG ON FIRE:%d';

  FSX_UNIT_PERCENT = 'percent';
  FSX_UNIT_MASK = 'mask';
  FSX_UNIT_BOOL = 'bool';
  FSX_UNIT_NUMBER = 'number';

  FSX_LIGHTON_LANDING = $0004;
  FSX_LIGHTON_PANEL = $0020;
  FSX_LIGHTON_CABIN = $0200;


type
  TGearData = packed record
    IsGearRetractable: Integer;
    TotalPctExtended: Double;
  end;
  PGearData = ^TGearData;

  TEngineData = packed record
    NumberOfEngines: Integer;
    Combustion: array[1..MAX_ENGINES] of Integer;
    Failed: array[1..MAX_ENGINES] of Integer;
    OnFire: array[1..MAX_ENGINES] of Integer;
  end;
  PEngineData = ^TEngineData;


{ TFSXLEDStateProvider }
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
  if not InitSimConnect then
    raise EInitializeError.Create('SimConnect.dll could not be loaded');

  if SimConnect_Open(FSimConnectHandle, APPNAME, 0, 0, 0, 0) <> S_OK then
    raise EInitializeError.Create('Connection to Flight Simulator could not be established');

  UpdateMap;
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

begin
  inherited;

  while SimConnect_GetNextDispatch(SimConnectHandle, data, dataSize) = S_OK do
    HandleDispatch(data);
end;


procedure TFSXLEDStateProvider.UpdateMap;
var
  engineIndex: Integer;
begin
  ClearDefinitions;

  { Gear }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_GEAR) then
  begin
    AddVariable(DEFINITION_GEAR, FSX_VARIABLE_ISGEARRETRACTABLE, FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);
    AddVariable(DEFINITION_GEAR, FSX_VARIABLE_GEARTOTALPCTEXTENDED, FSX_UNIT_PERCENT);
    AddDefinition(DEFINITION_GEAR);
  end;

  { Lights }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_LANDINGLIGHTS) or
     Consumer.FunctionMap.HasFunction(FUNCTION_FSX_INSTRUMENTLIGHTS) then
  begin
    AddVariable(DEFINITION_LIGHTS, FSX_VARIABLE_LIGHTONSTATES, FSX_UNIT_MASK, SIMCONNECT_DATATYPE_INT32);
    AddDefinition(DEFINITION_LIGHTS);
  end;

  { Parking brake }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_PARKINGBRAKE) then
  begin
    AddVariable(DEFINITION_PARKINGBRAKE, FSX_VARIABLE_PARKINGBRAKE, FSX_UNIT_BOOL, SIMCONNECT_DATATYPE_INT32);
    AddDefinition(DEFINITION_PARKINGBRAKE);
  end;

  { Engine }
  if Consumer.FunctionMap.HasFunction(FUNCTION_FSX_ENGINE) then
  begin
    AddVariable(DEFINITION_ENGINE, FSX_VARIABLE_NUMBEROFENGINES, FSX_UNIT_NUMBER, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ENGINE, Format(FSX_VARIABLE_ENGCOMBUSTION, [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ENGINE, Format(FSX_VARIABLE_ENGFAILED, [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    for engineIndex := 1 to MAX_ENGINES do
      AddVariable(DEFINITION_ENGINE, Format(FSX_VARIABLE_ENGONFIRE, [engineIndex]), FSX_UNIT_BOOL, SIMCONNECT_DATAType_INT32);

    AddDefinition(DEFINITION_ENGINE);
  end;
end;


procedure TFSXLEDStateProvider.HandleDispatch(AData: PSimConnectRecv);
var
  simObjectData: PSimConnectRecvSimObjectData;
  states: Cardinal;
  gearData: PGearData;
  engineData: PEngineData;
  engineIndex: Integer;
  state: TLEDState;

begin
  case SIMCONNECT_RECV_ID(AData^.dwID) of
    SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
      begin
        simObjectData := PSimConnectRecvSimObjectData(AData);

        case simObjectData^.dwRequestID of
          DEFINITION_GEAR:
            begin
              gearData := @simObjectData^.dwData;

              if gearData^.IsGearRetractable <> 0 then
              begin
                case Trunc(gearData^.TotalPctExtended * 100) of
                  0:    Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsRed);
                  100:  Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsGreen);
                else    Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsAmber);
                end;
              end else
                Consumer.SetStateByFunction(FUNCTION_FSX_GEAR, lsOff);
            end;

          DEFINITION_LIGHTS:
            begin
              states := simObjectData^.dwData;
              if (states and FSX_LIGHTON_LANDING) <> 0 then
                Consumer.SetStateByFunction(FUNCTION_FSX_LANDINGLIGHTS, lsGreen)
              else
                Consumer.SetStateByFunction(FUNCTION_FSX_LANDINGLIGHTS, lsRed);

              if (states and FSX_LIGHTON_PANEL) <> 0 then
                Consumer.SetStateByFunction(FUNCTION_FSX_INSTRUMENTLIGHTS, lsGreen)
              else
                Consumer.SetStateByFunction(FUNCTION_FSX_INSTRUMENTLIGHTS, lsRed);
            end;

          DEFINITION_PARKINGBRAKE:
            if simObjectData^.dwData <> 0 then
              Consumer.SetStateByFunction(FUNCTION_FSX_PARKINGBRAKE, lsRed)
            else
              Consumer.SetStateByFunction(FUNCTION_FSX_PARKINGBRAKE, lsGreen);

          DEFINITION_ENGINE:
            begin
              engineData := @simObjectData^.dwData;

              if engineData^.NumberOfEngines > 0 then
              begin
                state := lsGreen;

                for engineIndex := 1 to Min(engineData^.NumberOfEngines, MAX_ENGINES) do
                begin
                  if engineData.OnFire[engineIndex] <> 0 then
                  begin
                    state := lsError;
                    break;

                  end else if engineData.Failed[engineIndex] <> 0 then
                    state := lsWarning

                  else if (engineData.Combustion[engineIndex] = 0) and
                          (state = lsGreen) then
                    state := lsRed;
                end;

                Consumer.SetStateByFunction(FUNCTION_FSX_ENGINE, state);
              end else
                Consumer.SetStateByFunction(FUNCTION_FSX_ENGINE, lsOff);
            end;
        end;
      end;

    SIMCONNECT_RECV_ID_QUIT:
      Terminate;
  end;
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

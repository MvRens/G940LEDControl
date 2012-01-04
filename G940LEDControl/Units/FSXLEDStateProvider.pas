unit FSXLEDStateProvider;

interface
uses
  Classes,
  SyncObjs,
  
  CustomLEDStateProvider,
  SimConnect;

  
const
  FUNCTION_FSX_GEAR = 1;

  EXIT_ERROR_INITSIMCONNECT = 1;
  EXIT_ERROR_CONNECT = 2;

  
type
  TFSXLEDStateProvider = class(TCustomLEDStateProvider)
  private
    FSimConnectHandle: THandle;
  protected
    procedure Execute; override;

    procedure UpdateMap(AConnection: THandle);
    procedure HandleDispatch(AData: PSimConnectRecv);

    function GetDataDouble(var AData: Cardinal): Double;

    property SimConnectHandle: THandle read FSimConnectHandle;
  end;


implementation
uses
  ComObj,
  SysUtils;


const
  APPNAME = 'G940 LED Control';
  READY_TIMEOUT = 5000;

  DEFINITION_GEAR = 1;
  REQUEST_GEAR = 1;


  FSX_VARIABLE_GEARTOTALPCTEXTENDED = 'GEAR TOTAL PCT EXTENDED';

  FSX_UNIT_PERCENT = 'percent';


{ TFSXLEDStateProvider }
procedure TFSXLEDStateProvider.Execute;
var
  connection: THandle;
  data: PSimConnectRecv;
  dataSize: Cardinal;

begin
  if not InitSimConnect then
  begin
    Task.SetExitStatus(EXIT_ERROR_INITSIMCONNECT, 'SimConnect.dll could not be loaded');
    Task.Terminate;
    exit;
  end;

  if SimConnect_Open(connection, APPNAME, 0, 0, 0, 0) = S_OK then
  try
    UpdateMap(connection);

    while not Task.Terminated do
    begin
      if SimConnect_GetNextDispatch(connection, data, dataSize) = S_OK then
        HandleDispatch(data);

      ProcessMessages;
      Sleep(1);
    end;
  finally
    SimConnect_Close(connection);
  end else
  begin
    Task.SetExitStatus(EXIT_ERROR_CONNECT, 'Connection to Flight Simulator could not be established');
    Task.Terminate;
  end;
end;


procedure TFSXLEDStateProvider.UpdateMap(AConnection: THandle);
var
  functionMap: TLEDFunctionMap;

  function HasFunction(AFunction: Integer): Boolean;
  var
    ledIndex: Integer;

  begin
    Result := False;

    for ledIndex := 0 to Pred(functionMap.Count) do
      if functionMap.GetFunction(ledIndex) = AFunction then
      begin
        Result := True;
        break;
      end;
  end;

  
begin
  SimConnect_ClearDataDefinition(AConnection, DEFINITION_GEAR);

  functionMap := LockFunctionMap;
  try
    if HasFunction(FUNCTION_FSX_GEAR) then
    begin
      SimConnect_AddToDataDefinition(AConnection, DEFINITION_GEAR,
                                     FSX_VARIABLE_GEARTOTALPCTEXTENDED,
                                     FSX_UNIT_PERCENT);
      SimConnect_RequestDataOnSimObject(AConnection, REQUEST_GEAR,
                                        DEFINITION_GEAR,
                                        SIMCONNECT_OBJECT_ID_USER,
                                        SIMCONNECT_PERIOD_SIM_FRAME,
                                        SIMCONNECT_DATA_REQUEST_FLAG_CHANGED);
    end;
  finally
    UnlockFunctionMap;
  end;
end;


procedure TFSXLEDStateProvider.HandleDispatch(AData: PSimConnectRecv);
var
  simObjectData: PSimConnectRecvSimObjectData;
  
begin
  case SIMCONNECT_RECV_ID(AData^.dwID) of
    SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
      begin
        simObjectData := PSimConnectRecvSimObjectData(AData);

        case simObjectData^.dwRequestID of
          REQUEST_GEAR:
            begin
              case Trunc(GetDataDouble(simObjectData^.dwData) * 100) of
                0:    SetStateByFunction(FUNCTION_FSX_GEAR, lsRed);
                100:  SetStateByFunction(FUNCTION_FSX_GEAR, lsGreen);
              else    SetStateByFunction(FUNCTION_FSX_GEAR, lsAmber);
              end;
            end;
        end;
      end;

    SIMCONNECT_RECV_ID_QUIT:
      Task.Terminate;
  end;
end;


function TFSXLEDStateProvider.GetDataDouble(var AData: Cardinal): Double;
begin
  Result := PDouble(@AData)^;
end;

end.

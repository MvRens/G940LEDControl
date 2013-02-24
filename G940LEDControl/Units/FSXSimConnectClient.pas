unit FSXSimConnectClient;

interface
uses
  Classes,

  OtlTaskControl,

  FSXSimConnectIntf;


type
  TFSXSimConnectInterface = class(TInterfacedObject, IFSXSimConnect)
  private
    FClient: IOmniTaskControl;
    FObservers: TInterfaceList;
  protected
    property Client: IOmniTaskControl read FClient;
    property Observers: TInterfaceList read FObservers;
  protected
    { IFSXSimConnect }
    procedure Attach(AObserver: IFSXSimConnectObserver);
    procedure Detach(AObserver: IFSXSimConnectObserver);

    function CreateDefinition: IFSXSimConnectDefinition;
    function AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler): Integer;
    procedure RemoveDefinition(ADefinitionID: Cardinal; ADataHandler: IFSXSimConnectDataHandler);
  public
    constructor Create;
    destructor Destroy; override;
  end;


implementation
uses
  Generics.Collections,
  System.Math,
  System.SyncObjs,
  System.SysUtils,
  Winapi.Windows,

  OtlComm,
  OtlCommon,
  SimConnect,

  FSXResources,
  FSXSimConnectStateMonitor;


const
  TM_ADDDEFINITION = 3001;
  TM_REMOVEDEFINITION = 3002;
  TM_TRYSIMCONNECT = 3003;

  TIMER_TRYSIMCONNECT = 201;

  INTERVAL_TRYSIMCONNECT = 5000;


type
  TFSXSimConnectDefinitionRef = class(TObject)
  private
    FDefinition: IFSXSimConnectDefinitionAccess;
    FDataHandlers: TInterfaceList;
  protected
    property DataHandlers: TInterfaceList read FDataHandlers;
  public
    constructor Create(ADefinition: IFSXSimConnectDefinitionAccess);
    destructor Destroy; override;

    procedure Attach(ADataHandler: IFSXSimConnectDataHandler);
    function Detach(ADataHandler: IFSXSimConnectDataHandler): Integer;

    procedure HandleData(AData: Pointer);

    property Definition: IFSXSimConnectDefinitionAccess read FDefinition;
  end;


  TFSXSimConnectDefinitionMap = class(TObjectDictionary<Cardinal, TFSXSimConnectDefinitionRef>)
  public
    constructor Create(ACapacity: Integer = 0); reintroduce;
  end;

  TFSXSimConnectClient = class(TOmniWorker)
  private
    FDefinitions: TFSXSimConnectDefinitionMap;
    FLastDefinitionID: Cardinal;
    FSimConnectHandle: THandle;
    FSimConnectDataEvent: TEvent;
  protected
    procedure TMAddDefinition(var Msg: TOmniMessage); message TM_ADDDEFINITION;
    procedure TMRemoveDefinition(var Msg: TOmniMessage); message TM_REMOVEDEFINITION;
    procedure TMTrySimConnect(var Msg: TOmniMessage); message TM_TRYSIMCONNECT;

    procedure HandleSimConnectDataEvent;
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    procedure TrySimConnect;

    procedure RegisterDefinitions;
    procedure RegisterDefinition(ADefinitionID: Cardinal; ADefinition: IFSXSimConnectDefinitionAccess);
    procedure UpdateDefinition(ADefinitionID: Cardinal);
    procedure UnregisterDefinition(ADefinitionID: Cardinal);

    function SameDefinition(ADefinition1, ADefinition2: IFSXSimConnectDefinitionAccess): Boolean;

    property Definitions: TFSXSimConnectDefinitionMap read FDefinitions;
    property LastDefinitionID: Cardinal read FLastDefinitionID;
    property SimConnectHandle: THandle read FSimConnectHandle;
    property SimConnectDataEvent: TEvent read FSimConnectDataEvent;
  end;


  TFSXSimConnectVariable = class(TInterfacedPersistent, IFSXSimConnectVariable)
  private
    FVariableName: string;
    FUnitsName: string;
    FDataType: SIMCONNECT_DATAType;
    FEpsilon: Single;
  protected
    { IFSXSimConnectVariable }
    function GetVariableName: string;
    function GetUnitsName: string;
    function GetDataType: SIMCONNECT_DATAType;
    function GetEpsilon: Single;
  public
    constructor Create(AVariableName, AUnitsName: string; ADataType: SIMCONNECT_DATAType; AEpsilon: Single);
  end;


  TFSXSimConnectVariableList = TObjectList<TFSXSimConnectVariable>;

  TFSXSimConnectDefinition = class(TInterfacedObject, IFSXSimConnectDefinition, IFSXSimConnectDefinitionAccess)
  private
    FSimConnect: IFSXSimConnect;
    FVariables: TFSXSimConnectVariableList;
  protected
    property SimConnect: IFSXSimConnect read FSimConnect;
    property Variables: TFSXSimConnectVariableList read FVariables;
  protected
    { IFSXSimConnectDefinition }
    procedure AddVariable(AVariableName, AUnitsName: string; ADataType: SIMCONNECT_DATAType; AEpsilon: Single = 0);

    { IFSXSimConnectDefinitionAccess }
    function GetVariableCount: Integer;
    function GetVariable(AIndex: Integer): IFSXSimConnectVariable;
  public
    constructor Create;
    destructor Destroy; override;
  end;



  TAddDefinitionValue = class(TOmniWaitableValue)
  private
    FDataHandler: IFSXSimConnectDataHandler;
    FDefinition: IFSXSimConnectDefinition;
    FDefinitionID: Cardinal;

    procedure SetDefinitionID(const Value: Cardinal);
  public
    constructor Create(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);

    property DataHandler: IFSXSimConnectDataHandler read FDataHandler;
    property Definition: IFSXSimConnectDefinition read FDefinition;

    property DefinitionID: Cardinal read FDefinitionID write SetDefinitionID;
  end;


  TRemoveDefinitionValue = class(TOmniWaitableValue)
  private
    FDataHandler: IFSXSimConnectDataHandler;
    FDefinitionID: Cardinal;
  public
    constructor Create(ADefinitionID: Cardinal; ADataHandler: IFSXSimConnectDataHandler);

    property DataHandler: IFSXSimConnectDataHandler read FDataHandler;
    property DefinitionID: Cardinal read FDefinitionID;
  end;


{ TFSXSimConnectInterface }
constructor TFSXSimConnectInterface.Create;
var
  worker: IOmniWorker;

begin
  inherited Create;

  FObservers := TInterfaceList.Create;

  worker := TFSXSimConnectClient.Create;
  FClient := CreateTask(worker).Run;
end;


destructor TFSXSimConnectInterface.Destroy;
var
  observer: IInterface;

begin
  for observer in Observers do
    (observer as IFSXSimConnectObserver).ObserveDestroy(Self);

  FreeAndNil(FObservers);

  FClient.Terminate;
  FClient := nil;

  inherited Destroy;
end;


procedure TFSXSimConnectInterface.Attach(AObserver: IFSXSimConnectObserver);
begin
  Observers.Add(AObserver as IFSXSimConnectObserver);
end;


procedure TFSXSimConnectInterface.Detach(AObserver: IFSXSimConnectObserver);
begin
  Observers.Remove(AObserver as IFSXSimConnectObserver);
end;


function TFSXSimConnectInterface.CreateDefinition: IFSXSimConnectDefinition;
begin
  Result := TFSXSimConnectDefinition.Create;
end;


function TFSXSimConnectInterface.AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler): Integer;
var
  addDefinition: TAddDefinitionValue;

begin
  addDefinition := TAddDefinitionValue.Create(ADefinition, ADataHandler);
  Client.Comm.Send(TM_ADDDEFINITION, addDefinition);

  addDefinition.WaitFor(INFINITE);
  Result := addDefinition.DefinitionID;
end;


procedure TFSXSimConnectInterface.RemoveDefinition(ADefinitionID: Cardinal; ADataHandler: IFSXSimConnectDataHandler);
var
  removeDefinition: TRemoveDefinitionValue;

begin
  removeDefinition := TRemoveDefinitionValue.Create(ADefinitionID, ADataHandler);
  Client.Comm.Send(TM_REMOVEDEFINITION, removeDefinition);

  removeDefinition.WaitFor(INFINITE);
end;



{ TFSXSimConnectDefinition }
constructor TFSXSimConnectDefinition.Create;
begin
  inherited Create;

  FVariables := TFSXSimConnectVariableList.Create(True);
end;


destructor TFSXSimConnectDefinition.Destroy;
begin
  FreeAndNil(FVariables);

  inherited Destroy;
end;


procedure TFSXSimConnectDefinition.AddVariable(AVariableName, AUnitsName: string; ADataType: SIMCONNECT_DATAType; AEpsilon: Single);
begin
  Variables.Add(TFSXSimConnectVariable.Create(AVariableName, AUnitsName, ADataType, AEpsilon));
end;


function TFSXSimConnectDefinition.GetVariable(AIndex: Integer): IFSXSimConnectVariable;
begin
  Result := Variables[AIndex];
end;


function TFSXSimConnectDefinition.GetVariableCount: Integer;
begin
  Result := Variables.Count;
end;


{ TFSXSimConnectClient }
function TFSXSimConnectClient.Initialize: Boolean;
begin
  Result := inherited Initialize;
  if not Result then
    exit;

  FDefinitions := TFSXSimConnectDefinitionMap.Create;
  FSimConnectDataEvent := TEvent.Create(nil, False, False, '');

  Task.RegisterWaitObject(SimConnectDataEvent.Handle, HandleSimConnectDataEvent);

  TrySimConnect;
end;


procedure TFSXSimConnectClient.Cleanup;
begin
  FreeAndNil(FSimConnectDataEvent);
  FreeAndNil(FDefinitions);

  if SimConnectHandle <> 0 then
    SimConnect_Close(SimConnectHandle);

  TFSXSimConnectStateMonitor.SetCurrentState(scsDisconnected);

  inherited Cleanup;
end;


procedure TFSXSimConnectClient.TrySimConnect;
begin
  if SimConnectHandle <> 0 then
    exit;

  if InitSimConnect then
  begin
    if SimConnect_Open(FSimConnectHandle, FSXSimConnectAppName, 0, 0, SimConnectDataEvent.Handle, 0) = S_OK then
    begin
      TFSXSimConnectStateMonitor.SetCurrentState(scsConnected);

      Task.ClearTimer(TIMER_TRYSIMCONNECT);
      RegisterDefinitions;
    end;
  end;

  if SimConnectHandle = 0 then
  begin
    TFSXSimConnectStateMonitor.SetCurrentState(scsFailed);

    Task.SetTimer(TIMER_TRYSIMCONNECT, INTERVAL_TRYSIMCONNECT, TM_TRYSIMCONNECT);
  end;
end;


procedure TFSXSimConnectClient.HandleSimConnectDataEvent;
var
  data: PSimConnectRecv;
  dataSize: Cardinal;
  simObjectData: PSimConnectRecvSimObjectData;
  definitionRef: TFSXSimConnectDefinitionRef;

begin
  while (SimConnectHandle <> 0) and
        (SimConnect_GetNextDispatch(SimConnectHandle, data, dataSize) = S_OK) do
  begin
    case SIMCONNECT_RECV_ID(data^.dwID) of
      SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
        begin
          simObjectData := PSimConnectRecvSimObjectData(data);

          if Definitions.ContainsKey(simObjectData^.dwDefineID) then
          begin
            definitionRef := Definitions[simObjectData^.dwDefineID];
            definitionRef.HandleData(@simObjectData^.dwData);
          end;
        end;

      SIMCONNECT_RECV_ID_QUIT:
        begin
          FSimConnectHandle := 0;
          Task.SetTimer(TIMER_TRYSIMCONNECT, INTERVAL_TRYSIMCONNECT, TM_TRYSIMCONNECT);

          TFSXSimConnectStateMonitor.SetCurrentState(scsDisconnected);
        end;
    end;
  end;
end;


procedure TFSXSimConnectClient.RegisterDefinitions;
var
  definitionID: Cardinal;

begin
  if SimConnectHandle = 0 then
    exit;

  for definitionID in Definitions.Keys do
    RegisterDefinition(definitionID, Definitions[definitionID].Definition);
end;


procedure TFSXSimConnectClient.RegisterDefinition(ADefinitionID: Cardinal; ADefinition: IFSXSimConnectDefinitionAccess);
var
  variableIndex: Integer;
  variable: IFSXSimConnectVariable;

begin
  if SimConnectHandle = 0 then
    exit;

  for variableIndex := 0 to Pred(ADefinition.GetVariableCount) do
  begin
    variable := ADefinition.GetVariable(variableIndex);
    SimConnect_AddToDataDefinition(SimConnectHandle, ADefinitionID,
                                   AnsiString(variable.GetVariableName),
                                   AnsiString(variable.GetUnitsName),
                                   variable.GetDataType,
                                   variable.GetEpsilon);
  end;

  SimConnect_RequestDataOnSimObject(SimConnectHandle, ADefinitionID, ADefinitionID,
                                    SIMCONNECT_OBJECT_ID_USER,
                                    SIMCONNECT_PERIOD_SIM_FRAME,
                                    SIMCONNECT_DATA_REQUEST_FLAG_CHANGED);
end;


procedure TFSXSimConnectClient.UpdateDefinition(ADefinitionID: Cardinal);
begin
  if SimConnectHandle <> 0 then
    { One-time data update; the RequestID is counted backwards to avoid conflicts with
      the FLAG_CHANGED request which is still active }
    SimConnect_RequestDataOnSimObject(SimConnectHandle, High(Cardinal) - ADefinitionID, ADefinitionID,
                                      SIMCONNECT_OBJECT_ID_USER,
                                      SIMCONNECT_PERIOD_SIM_FRAME,
                                      0, 0, 0, 1);
end;


procedure TFSXSimConnectClient.UnregisterDefinition(ADefinitionID: Cardinal);
begin
  if SimConnectHandle <> 0 then
    SimConnect_ClearDataDefinition(SimConnectHandle, ADefinitionID);
end;


function TFSXSimConnectClient.SameDefinition(ADefinition1, ADefinition2: IFSXSimConnectDefinitionAccess): Boolean;
var
  variableIndex: Integer;
  variable1: IFSXSimConnectVariable;
  variable2: IFSXSimConnectVariable;

begin
  if ADefinition1.GetVariableCount = ADefinition2.GetVariableCount then
  begin
    Result := True;

    { Order is very important in the definitions, as the Data Handler depends
      on it to interpret the data. }
    for variableIndex := 0 to Pred(ADefinition1.GetVariableCount) do
    begin
      variable1 := ADefinition1.GetVariable(variableIndex);
      variable2 := ADefinition2.GetVariable(variableIndex);

      if (variable1.GetVariableName <> variable2.GetVariableName) or
         (variable1.GetUnitsName <> variable2.GetUnitsName) or
         (variable1.GetDataType <> variable2.GetDataType) or
         (not SameValue(variable1.GetEpsilon, variable2.GetEpsilon, 0.00001)) then
      begin
        Result := False;
        break;
      end;
    end;
  end else
    Result := False;
end;


procedure TFSXSimConnectClient.TMAddDefinition(var Msg: TOmniMessage);
var
  addDefinition: TAddDefinitionValue;
  definitionID: Cardinal;
  definitionRef: TFSXSimConnectDefinitionRef;
  definitionAccess: IFSXSimConnectDefinitionAccess;
  hasDefinition: Boolean;

begin
  addDefinition := Msg.MsgData;
  definitionAccess := (addDefinition.Definition as IFSXSimConnectDefinitionAccess);
  hasDefinition := False;

  { Attempt to re-use existing definition to save on SimConnect traffic }
  for definitionID in Definitions.Keys do
  begin
    definitionRef := Definitions[definitionID];

    if SameDefinition(definitionRef.Definition, definitionAccess) then
    begin
      definitionRef.Attach(addDefinition.DataHandler);
      addDefinition.DefinitionID := definitionID;

      { Request an update on the definition to update the new worker }
      UpdateDefinition(definitionID);

      hasDefinition := True;
      break;
    end;
  end;

  if not hasDefinition then
  begin
    { Add as new definition }
    Inc(FLastDefinitionID);

    definitionRef := TFSXSimConnectDefinitionRef.Create(definitionAccess);
    definitionRef.Attach(addDefinition.DataHandler);

    Definitions.Add(LastDefinitionID, definitionRef);
    addDefinition.DefinitionID := LastDefinitionID;

    { Register with SimConnect }
    RegisterDefinition(LastDefinitionID, definitionAccess);
  end;
end;


procedure TFSXSimConnectClient.TMRemoveDefinition(var Msg: TOmniMessage);
var
  removeDefinition: TRemoveDefinitionValue;
  definitionRef: TFSXSimConnectDefinitionRef;

begin
  removeDefinition := Msg.MsgData;

  if Definitions.ContainsKey(removeDefinition.DefinitionID) then
  begin
    definitionRef := Definitions[removeDefinition.DefinitionID];
    if definitionRef.Detach(removeDefinition.DataHandler) = 0 then
    begin
      { Unregister with SimConnect }
      UnregisterDefinition(removeDefinition.DefinitionID);

      Definitions.Remove(removeDefinition.DefinitionID);
    end;
  end;

  removeDefinition.Signal;
end;


procedure TFSXSimConnectClient.TMTrySimConnect(var Msg: TOmniMessage);
begin
  TrySimConnect;
end;


{ TFSXSimConnectDefinitionRef }
constructor TFSXSimConnectDefinitionRef.Create(ADefinition: IFSXSimConnectDefinitionAccess);
begin
  inherited Create;

  FDataHandlers := TInterfaceList.Create;
  FDefinition := ADefinition;
end;


destructor TFSXSimConnectDefinitionRef.Destroy;
begin
  FreeAndNil(FDataHandlers);

  inherited Destroy;
end;


procedure TFSXSimConnectDefinitionRef.HandleData(AData: Pointer);
var
  dataHandler: IInterface;

begin
  for dataHandler in DataHandlers do
    (dataHandler as IFSXSimConnectDataHandler).HandleData(AData);
end;


procedure TFSXSimConnectDefinitionRef.Attach(ADataHandler: IFSXSimConnectDataHandler);
begin
  DataHandlers.Add(ADataHandler as IFSXSimConnectDataHandler);
end;


function TFSXSimConnectDefinitionRef.Detach(ADataHandler: IFSXSimConnectDataHandler): Integer;
begin
  DataHandlers.Remove(ADataHandler as IFSXSimConnectDataHandler);
  Result := DataHandlers.Count;
end;


{ TFSXSimConnectDefinitionMap }
constructor TFSXSimConnectDefinitionMap.Create(ACapacity: Integer);
begin
  inherited Create([doOwnsValues], ACapacity);
end;


{ TFSXSimConnectVariable }
constructor TFSXSimConnectVariable.Create(AVariableName, AUnitsName: string; ADataType: SIMCONNECT_DATAType; AEpsilon: Single);
begin
  inherited Create;

  FVariableName := AVariableName;
  FUnitsName := AUnitsName;
  FDataType := ADataType;
  FEpsilon := AEpsilon;
end;


function TFSXSimConnectVariable.GetVariableName: string;
begin
  Result := FVariableName;
end;


function TFSXSimConnectVariable.GetUnitsName: string;
begin
  Result := FUnitsName;
end;


function TFSXSimConnectVariable.GetDataType: SIMCONNECT_DATAType;
begin
  Result := FDataType;
end;


function TFSXSimConnectVariable.GetEpsilon: Single;
begin
  Result := FEpsilon;
end;


{ TAddDefinitionValue }
constructor TAddDefinitionValue.Create(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);
begin
  inherited Create;

  FDefinition := ADefinition;
  FDataHandler := ADataHandler;
end;


procedure TAddDefinitionValue.SetDefinitionID(const Value: Cardinal);
begin
  FDefinitionID := Value;
  Signal;
end;


{ TRemoveDefinitionValue }
constructor TRemoveDefinitionValue.Create(ADefinitionID: Cardinal; ADataHandler: IFSXSimConnectDataHandler);
begin
  inherited Create;

  FDefinitionID := ADefinitionID;
  FDataHandler := ADataHandler;
end;

end.

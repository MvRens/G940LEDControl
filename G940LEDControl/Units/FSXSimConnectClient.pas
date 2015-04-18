unit FSXSimConnectClient;

// Determines if a Win32 event will be used to wait for new
// messages instead of the old 0.x method of polling via a timer.
{$DEFINE SCUSEEVENT}

interface
uses
  Classes,

  OtlTaskControl,
  X2Log.Intf,

  FSXSimConnectIntf,
  Profile,
  ProfileManager;


type
  TFSXSimConnectInterface = class(TInterfacedObject, IFSXSimConnect, IFSXSimConnectProfileMenu, IProfileObserver)
  private
    FClient: IOmniTaskControl;
    FObservers: TInterfaceList;

    FObservingProfileManager: Boolean;
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

    { IFSXSimConnectProfileMenu }
    procedure SetProfileMenu(AEnabled, ACascaded: Boolean);

    { IProfileObserver }
    procedure ObserveAdd(AProfile: TProfile);
    procedure ObserveRemove(AProfile: TProfile);
    procedure ObserveActiveChanged(AProfile: TProfile);
  public
    constructor Create(ALog: IX2Log);
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
  TM_PROCESSMESSAGES = 3004;
  TM_SETPROFILEMENU = 3005;
  TM_UPDATEPROFILEMENU = 3006;

  TIMER_TRYSIMCONNECT = 201;
  INTERVAL_TRYSIMCONNECT = 5000;

  {$IFNDEF SCUSEEVENT}
  TIMER_PROCESSMESSAGES = 202;
  INTERVAL_PROCESSMESSAGES = 50;
  {$ENDIF}


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

    function Attach(ADataHandler: IFSXSimConnectDataHandler): Integer;
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
    {$IFDEF SCUSEEVENT}
    FSimConnectDataEvent: TEvent;
    {$ENDIF}

    FProfileMenu: Boolean;
    FProfileMenuCascaded: Boolean;

    FMenuProfiles: TStringList;
    FMenuWasCascaded: Boolean;
    FLog: IX2Log;
  protected
    procedure TMAddDefinition(var Msg: TOmniMessage); message TM_ADDDEFINITION;
    procedure TMRemoveDefinition(var Msg: TOmniMessage); message TM_REMOVEDEFINITION;
    procedure TMTrySimConnect(var Msg: TOmniMessage); message TM_TRYSIMCONNECT;
    {$IFNDEF SCUSEEVENT}
    procedure TMProcessMessages(var Msg: TOmniMessage); message TM_PROCESSMESSAGES;
    {$ENDIF}
    procedure TMSetProfileMenu(var Msg: TOmniMessage); message TM_SETPROFILEMENU;
    procedure TMUpdateProfileMenu(var Msg: TOmniMessage); message TM_UPDATEPROFILEMENU;

    procedure HandleSimConnectDataEvent;
    procedure HandleEvent(AEventID: Integer);
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    procedure TrySimConnect;

    procedure RegisterDefinitions;
    procedure RegisterDefinition(ADefinitionID: Cardinal; ADefinition: IFSXSimConnectDefinitionAccess);
    procedure UpdateDefinition(ADefinitionID: Cardinal);
    procedure UnregisterDefinition(ADefinitionID: Cardinal);

    function SameDefinition(ADefinition1, ADefinition2: IFSXSimConnectDefinitionAccess): Boolean;

    procedure UpdateProfileMenu;

    property Definitions: TFSXSimConnectDefinitionMap read FDefinitions;
    property LastDefinitionID: Cardinal read FLastDefinitionID;
    property SimConnectHandle: THandle read FSimConnectHandle;
    {$IFDEF SCUSEEVENT}
    property SimConnectDataEvent: TEvent read FSimConnectDataEvent;
    {$ENDIF}

    property Log: IX2Log read FLog;
    property ProfileMenu: Boolean read FProfileMenu;
    property ProfileMenuCascaded: Boolean read FProfileMenuCascaded;
  public
    constructor Create(ALog: IX2Log);
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
constructor TFSXSimConnectInterface.Create(ALog: IX2Log);
var
  worker: IOmniWorker;

begin
  inherited Create;

  FObservers := TInterfaceList.Create;

  worker := TFSXSimConnectClient.Create(ALog);
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



procedure TFSXSimConnectInterface.SetProfileMenu(AEnabled, ACascaded: Boolean);
begin
  Client.Comm.Send(TM_SETPROFILEMENU, [AEnabled, ACascaded]);

  if AEnabled <> FObservingProfileManager then
  begin
    if AEnabled then
      TProfileManager.Attach(Self)
    else
      TProfileManager.Detach(Self);

    FObservingProfileManager := AEnabled;
  end;
end;


procedure TFSXSimConnectInterface.ObserveAdd(AProfile: TProfile);
begin
  Client.Comm.Send(TM_UPDATEPROFILEMENU);
end;


procedure TFSXSimConnectInterface.ObserveRemove(AProfile: TProfile);
begin
  Client.Comm.Send(TM_UPDATEPROFILEMENU);
end;


procedure TFSXSimConnectInterface.ObserveActiveChanged(AProfile: TProfile);
begin
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
constructor TFSXSimConnectClient.Create(ALog: IX2Log);
begin
  inherited Create;

  FLog := ALog;
end;


function TFSXSimConnectClient.Initialize: Boolean;
begin
  Log.Info('Initializing');

  Result := inherited Initialize;
  if not Result then
    exit;

  FDefinitions := TFSXSimConnectDefinitionMap.Create;
  FMenuProfiles := TStringList.Create;

  {$IFDEF SCUSEEVENT}
  FSimConnectDataEvent := TEvent.Create(nil, False, False, '');
  Task.RegisterWaitObject(SimConnectDataEvent.Handle, HandleSimConnectDataEvent);
  {$ENDIF}

  TrySimConnect;
end;


procedure TFSXSimConnectClient.Cleanup;
begin
  Log.Info('Cleaning up');

  {$IFDEF SCUSEEVENT}
  FreeAndNil(FSimConnectDataEvent);
  {$ENDIF}

  FreeAndNil(FMenuProfiles);
  FreeAndNil(FDefinitions);

  if SimConnectHandle <> 0 then
    SimConnect_Close(SimConnectHandle);

  TFSXSimConnectStateMonitor.SetCurrentState(scsDisconnected);

  inherited Cleanup;
end;


procedure TFSXSimConnectClient.TrySimConnect;
var
  eventHandle: THandle;

begin
  if SimConnectHandle <> 0 then
    exit;

  Log.Info('Attempting to connect to SimConnect');

  if InitSimConnect then
  begin
    {$IFDEF SCUSEEVENT}
    eventHandle := SimConnectDataEvent.Handle;
    {$ELSE}
    eventHandle := 0;
    {$ENDIF}

    if SimConnect_Open(FSimConnectHandle, FSXSimConnectAppName, 0, 0, eventHandle, 0) = S_OK then
    begin
      Log.Info('Succesfully connected');
      TFSXSimConnectStateMonitor.SetCurrentState(scsConnected);

      Task.ClearTimer(TIMER_TRYSIMCONNECT);
      RegisterDefinitions;
      UpdateProfileMenu;

      {$IFNDEF SCUSEEVENT}
      Task.SetTimer(TIMER_PROCESSMESSAGES, INTERVAL_PROCESSMESSAGES, TM_PROCESSMESSAGES);
      {$ENDIF}
    end;
  end;

  if SimConnectHandle = 0 then
  begin
    Log.Info(Format('FSX SimConnect: Connection failed, trying again in %d seconds', [INTERVAL_TRYSIMCONNECT div 1000]));
    TFSXSimConnectStateMonitor.SetCurrentState(scsFailed);

    Task.SetTimer(TIMER_TRYSIMCONNECT, INTERVAL_TRYSIMCONNECT, TM_TRYSIMCONNECT);
    {$IFNDEF SCUSEEVENT}
    Task.ClearTimer(TIMER_PROCESSMESSAGES);
    {$ENDIF}
  end;
end;


procedure TFSXSimConnectClient.HandleSimConnectDataEvent;
const
  RecvMessageName: array[SIMCONNECT_RECV_ID] of string =
                   (
                     'Null',
                     'Exception',
                     'Open',
                     'Quit',
                     'Event',
                     'Event Object Addremove',
                     'Event Filename',
                     'Event Frame',
                     'Simobject Data',
                     'Simobject Data Bytype',
                     'Weather Observation',
                     'Cloud State',
                     'Assigned Object Id',
                     'Reserved Key',
                     'Custom Action',
                     'System State',
                     'Client Data'
                   );


var
  data: PSimConnectRecv;
  dataSize: Cardinal;
  simObjectData: PSimConnectRecvSimObjectData;
  eventData: PSimConnectRecvEvent;
  definitionRef: TFSXSimConnectDefinitionRef;

begin
  Log.Verbose('Handling messages');

  while (SimConnectHandle <> 0) and
        (SimConnect_GetNextDispatch(SimConnectHandle, data, dataSize) = S_OK) do
  begin
    case SIMCONNECT_RECV_ID(data^.dwID) of
      SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
        begin
          simObjectData := PSimConnectRecvSimObjectData(data);
          Log.Verbose(Format('Received Sim Object Data message (definition = %d)', [simObjectData^.dwDefineID]));

          if Definitions.ContainsKey(simObjectData^.dwDefineID) then
          begin
            definitionRef := Definitions[simObjectData^.dwDefineID];
            definitionRef.HandleData(@simObjectData^.dwData);
          end;
        end;

      SIMCONNECT_RECV_ID_EVENT:
        begin
          eventData := PSimConnectRecvEvent(data);
          Log.Verbose(Format('Received Event message (eventId = %d)', [eventData^.uEventID]));

          HandleEvent(eventData^.uEventID);
        end;

      SIMCONNECT_RECV_ID_QUIT:
        begin
          Log.Verbose('Received Quit message');

          FSimConnectHandle := 0;
          {$IFNDEF SCUSEEVENT}
          Task.ClearTimer(TIMER_PROCESSMESSAGES);
          {$ENDIF}
          Task.SetTimer(TIMER_TRYSIMCONNECT, INTERVAL_TRYSIMCONNECT, TM_TRYSIMCONNECT);

          FMenuProfiles.Clear;

          TFSXSimConnectStateMonitor.SetCurrentState(scsDisconnected);
        end;
    else
      if SIMCONNECT_RECV_ID(data^.dwID) in [Low(SIMCONNECT_RECV_ID)..High(SIMCONNECT_RECV_ID)] then
        Log.Verbose(Format('Received unhandled message (%s)', [RecvMessageName[SIMCONNECT_RECV_ID(data^.dwID)]]))
      else
        Log.Verbose(Format('Received unknown message (%d)', [data^.dwID]));
    end;
  end;
end;


procedure TFSXSimConnectClient.HandleEvent(AEventID: Integer);
var
  profileName: string;
  profile: TProfile;

begin
  if (AEventID <= 0) or (AEventID > FMenuProfiles.Count) then
    exit;

  profileName := FMenuProfiles[Pred(AEventID)];
  profile := TProfileManager.Find(profileName);
  if Assigned(profile) then
    TProfileManager.Instance.ActiveProfile := profile;
end;


procedure TFSXSimConnectClient.RegisterDefinitions;
var
  definitionID: Cardinal;

begin
  if SimConnectHandle = 0 then
    exit;

  UpdateProfileMenu;

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

  Log.Verbose(Format('Registering definition %d', [ADefinitionID]));

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
  begin
    Log.Verbose(Format('Unregistering definition: %d', [ADefinitionID]));
    SimConnect_ClearDataDefinition(SimConnectHandle, ADefinitionID);
  end;
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


procedure TFSXSimConnectClient.UpdateProfileMenu;
var
  profile: TProfile;
  profileIndex: Integer;
  menuIndex: Integer;
  profileName: string;

begin
  if SimConnectHandle = 0 then
    exit;

  Log.Info('Updating profile menu');

  if FMenuWasCascaded then
  begin
    for menuIndex := Pred(FMenuProfiles.Count) downto 0 do
      SimConnect_MenuDeleteSubItem(SimConnectHandle, 1, Cardinal(FMenuProfiles.Objects[menuIndex]));

    SimConnect_MenuDeleteItem(SimConnectHandle, 1);
  end else
  begin
    for menuIndex := Pred(FMenuProfiles.Count) downto 0 do
      SimConnect_MenuDeleteItem(SimConnectHandle, Cardinal(FMenuProfiles.Objects[menuIndex]));
  end;

  FMenuProfiles.Clear;


  if ProfileMenu then
  begin
    for profile in TProfileManager.Instance do
      FMenuProfiles.Add(profile.Name);

    FMenuProfiles.Sort;


    if ProfileMenuCascaded then
    begin
      SimConnect_MenuAddItem(SimConnectHandle, FSXMenuProfiles, 1, 0);

      for profileIndex := 0 to Pred(FMenuProfiles.Count) do
      begin
        profileName := Format(FSXMenuProfileFormatCascaded, [FMenuProfiles[profileIndex]]);

        SimConnect_MenuAddSubItem(SimConnectHandle, 1, PAnsiChar(AnsiString(profileName)), Succ(profileIndex), Succ(profileIndex));
        FMenuProfiles.Objects[profileIndex] := TObject(Succ(profileIndex));
      end;
    end else
    begin
      for profileIndex := 0 to Pred(FMenuProfiles.Count) do
      begin
        profileName := Format(FSXMenuProfileFormat, [FMenuProfiles[profileIndex]]);

        SimConnect_MenuAddItem(SimConnectHandle, PAnsiChar(AnsiString(profileName)), Succ(profileIndex), Succ(profileIndex));
        FMenuProfiles.Objects[profileIndex] := TObject(Succ(profileIndex));
      end;
    end;

    FMenuWasCascaded := ProfileMenuCascaded;
  end;
end;


procedure TFSXSimConnectClient.TMAddDefinition(var Msg: TOmniMessage);
var
  addDefinition: TAddDefinitionValue;
  definitionID: Cardinal;
  definitionRef: TFSXSimConnectDefinitionRef;
  definitionAccess: IFSXSimConnectDefinitionAccess;
  hasDefinition: Boolean;
  refCount: Integer;

begin
  addDefinition := Msg.MsgData;
  definitionAccess := (addDefinition.Definition as IFSXSimConnectDefinitionAccess);
  hasDefinition := False;

  Log.Verbose('Received request to add a definition');

  { Attempt to re-use existing definition to save on SimConnect traffic }
  for definitionID in Definitions.Keys do
  begin
    definitionRef := Definitions[definitionID];

    if SameDefinition(definitionRef.Definition, definitionAccess) then
    begin
      refCount := definitionRef.Attach(addDefinition.DataHandler);
      addDefinition.DefinitionID := definitionID;

      Log.Verbose(Format('Definition exists, incremented reference count (definitionID = %d, refCount = %d)', [definitionID, refCount]));


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
    Log.Verbose(Format('Adding as new definition (%d)', [FLastDefinitionID]));

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
  refCount: Integer;

begin
  removeDefinition := Msg.MsgData;
  Log.Verbose(Format('Received request to remove a definition (%d)', [removeDefinition.DefinitionID]));

  if Definitions.ContainsKey(removeDefinition.DefinitionID) then
  begin
    definitionRef := Definitions[removeDefinition.DefinitionID];
    refCount := definitionRef.Detach(removeDefinition.DataHandler);

    Log.Verbose(Format('Definition exists, decreased reference count (refCount = %d)', [refCount]));

    if refCount = 0 then
    begin
      Log.Verbose('Removing definition');

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


{$IFNDEF SCUSEEVENT}
procedure TFSXSimConnectClient.TMProcessMessages(var Msg: TOmniMessage);
begin
  HandleSimConnectDataEvent;
end;
{$ENDIF}


procedure TFSXSimConnectClient.TMSetProfileMenu(var Msg: TOmniMessage);
var
  newProfileMenu: Boolean;
  newProfileMenuCascaded: Boolean;

begin
  newProfileMenu := Msg.MsgData[0];
  newProfileMenuCascaded := Msg.MsgData[1];

  if (newProfileMenu <> FProfileMenu) or (newProfileMenuCascaded <> FProfileMenuCascaded) then
  begin
    FProfileMenu := newProfileMenu;
    FProfileMenuCascaded := newProfileMenuCascaded;

    UpdateProfileMenu;
  end;
end;


procedure TFSXSimConnectClient.TMUpdateProfileMenu(var Msg: TOmniMessage);
begin
  UpdateProfileMenu;
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


function TFSXSimConnectDefinitionRef.Attach(ADataHandler: IFSXSimConnectDataHandler): Integer;
begin
  DataHandlers.Add(ADataHandler as IFSXSimConnectDataHandler);
  Result := DataHandlers.Count;
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

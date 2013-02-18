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
    procedure AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);
    procedure RemoveDefinition(ADataHandler: IFSXSimConnectDataHandler);
  public
    constructor Create;
    destructor Destroy; override;
  end;


implementation
uses
  System.SysUtils,

  SimConnect;


const
  TM_ADDDEFINITION = 3001;
  TM_REMOVEDEFINITION = 3002;


type
  TFSXSimConnectClient = class(TOmniWorker)
  end;


  TFSXSimConnectDefinition = class(TInterfacedObject, IFSXSimConnectDefinition)
  private
    FSimConnect: IFSXSimConnect;
  protected
    property SimConnect: IFSXSimConnect read FSimConnect;
  protected
    { IFSXSimConnectDefinition }
    procedure AddVariable(AVariableName, AUnitsName: string; ADatumType: SIMCONNECT_DATAType; AEpsilon: Single = 0);
    procedure Apply(ASimConnectHandle: THandle; ADefinitionID: Integer);
  public
    constructor Create(ASimConnect: IFSXSimConnect);
  end;




{ TFSXSimConnectInterface }
constructor TFSXSimConnectInterface.Create;
var
  worker: IOmniWorker;

begin
  worker := TFSXSimConnectClient.Create;
  FClient := CreateTask(worker);

  FObservers := TInterfaceList.Create;
end;


destructor TFSXSimConnectInterface.Destroy;
begin
  FreeAndNil(FObservers);

  FClient.Terminate;
  FClient := nil;

  inherited;
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
  Result := TFSXSimConnectDefinition.Create(Self);
end;


procedure TFSXSimConnectInterface.AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);
begin
  Client.Comm.Send(TM_ADDDEFINITION, [ADefinition, ADataHandler]);
  // TODO pass to thread; if definition already exists (same variables), link to existing definition to avoid too many SimConnect definition
end;


procedure TFSXSimConnectInterface.RemoveDefinition(ADataHandler: IFSXSimConnectDataHandler);
begin
  Client.Comm.Send(TM_REMOVEDEFINITION, ADataHandler);
end;



{ TFSXSimConnectDefinition }
constructor TFSXSimConnectDefinition.Create(ASimConnect: IFSXSimConnect);
begin

end;


procedure TFSXSimConnectDefinition.AddVariable(AVariableName, AUnitsName: string; ADatumType: SIMCONNECT_DATAType; AEpsilon: Single);
begin

end;


procedure TFSXSimConnectDefinition.Apply(ASimConnectHandle: THandle; ADefinitionID: Integer);
begin
//  SimConnect_AddToDataDefinition(ASimConnectHandle, ADefinitionID,
//                                 AnsiString(AVariableName), AnsiString(AUnitsName), ADatumType, AEpsilon, 0);
end;

end.

unit FSXSimConnectClient;

interface
uses
  OtlTaskControl,

  FSXSimConnectIntf;

type
  TFSXSimConnectInterface = class(TInterfacedObject, IFSXSimConnect)
  private
    FClient: IOmniTaskControl;
  protected
    property Client: IOmniTaskControl read FClient;
  protected
    { IFSXSimConnect }
    function CreateDefinition: IFSXSimConnectDefinition;
    procedure AddDefinition(ADefinition: IFSXSimConnectDefinition);
  public
    constructor Create;
    destructor Destroy; override;
  end;


implementation
uses
  System.SysUtils,

  SimConnect;


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
end;


destructor TFSXSimConnectInterface.Destroy;
begin
  FClient.Terminate;
  FClient := nil;

  inherited;
end;


function TFSXSimConnectInterface.CreateDefinition: IFSXSimConnectDefinition;
begin
  Result := TFSXSimConnectDefinition.Create(Self);
end;


procedure TFSXSimConnectInterface.AddDefinition(ADefinition: IFSXSimConnectDefinition);
begin
  // TODO
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

unit FSXSimConnectIntf;

interface
uses
  SimConnect;


type
  IFSXSimConnect = interface;
  IFSXSimConnectDefinition = interface;


  IFSXSimConnectObserver = interface
    ['{ACE8979A-D656-4F97-A332-A54BB615C4D1}']
    procedure ObserveDestroy(Sender: IFSXSimConnect);
  end;


  IFSXSimConnectDataHandler = interface
    ['{29F00FB8-00AB-419F-83A3-A6AB3582599F}']
    procedure HandleData(AData: Pointer);
  end;


  IFSXSimConnect = interface
    ['{B6BE3E7C-0804-43D6-84DE-8010C5728A07}']
    procedure Attach(AObserver: IFSXSimConnectObserver);
    procedure Detach(AObserver: IFSXSimConnectObserver);

    function CreateDefinition: IFSXSimConnectDefinition;
    function AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler): Integer;
    procedure RemoveDefinition(ADefinitionID: Cardinal; ADataHandler: IFSXSimConnectDataHandler);
  end;


  IFSXSimConnectProfileMenu = interface
    ['{362B6F7D-3E68-48A8-83BC-6078AE100334}']
    procedure SetProfileMenu(AEnabled, ACascaded: Boolean);
  end;


  IFSXSimConnectVariable = interface
    ['{A41AD003-77C0-4E34-91E3-B0BAADD08FCE}']
    function GetVariableName: string;
    function GetUnitsName: string;
    function GetDataType: SIMCONNECT_DATAType;
    function GetEpsilon: Single;
  end;


  IFSXSimConnectDefinition = interface
    ['{F1EAB3B1-0A3D-4B06-A75F-823E15C313B8}']
    procedure AddVariable(AVariableName, AUnitsName: string; ADataType: SIMCONNECT_DATAType; AEpsilon: Single = 0);

    function GetVariableCount: Integer;
    function GetVariable(AIndex: Integer): IFSXSimConnectVariable;
  end;


  TFSXSimConnectState = (scsDisconnected, scsConnecting, scsConnected, scsFailed);

  IFSXSimConnectStateObserver = interface
    ['{0508904F-8189-479D-AF70-E98B00C9D9B2}']
    procedure ObserverStateUpdate(ANewState: TFSXSimConnectState);
  end;


const
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
  FSX_LIGHTON_WING = $0080;
  FSX_LIGHTON_LOGO = $0100;
  FSX_LIGHTON_CABIN = $0200;

  FSX_LIGHTON_ALL = FSX_LIGHTON_NAV or FSX_LIGHTON_BEACON or FSX_LIGHTON_LANDING or
                    FSX_LIGHTON_TAXI or FSX_LIGHTON_STROBE or FSX_LIGHTON_PANEL or
                    FSX_LIGHTON_RECOGNITION or FSX_LIGHTON_WING or FSX_LIGHTON_LOGO or
                    FSX_LIGHTON_CABIN;


  FSX_MAX_ENGINES = 4;


implementation

end.

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
    procedure AddDefinition(ADefinition: IFSXSimConnectDefinition; ADataHandler: IFSXSimConnectDataHandler);
    procedure RemoveDefinition(ADataHandler: IFSXSimConnectDataHandler);
  end;


  IFSXSimConnectDefinition = interface
    ['{F1EAB3B1-0A3D-4B06-A75F-823E15C313B8}']
    procedure AddVariable(AVariableName, AUnitsName: string; ADatumType: SIMCONNECT_DATAType; AEpsilon: Single = 0);
    procedure Apply(ASimConnectHandle: THandle; ADefinitionID: Integer);
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
  FSX_LIGHTON_CABIN = $0200;

  FSX_MAX_ENGINES = 4;


implementation

end.

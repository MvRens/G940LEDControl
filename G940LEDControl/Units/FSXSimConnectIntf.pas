unit FSXSimConnectIntf;

interface
uses
  SimConnect;


type
  IFSXSimConnectDefinition = interface;


  IFSXSimConnect = interface
    ['{B6BE3E7C-0804-43D6-84DE-8010C5728A07}']
    function CreateDefinition: IFSXSimConnectDefinition;
    procedure AddDefinition(ADefinition: IFSXSimConnectDefinition);
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



implementation

end.

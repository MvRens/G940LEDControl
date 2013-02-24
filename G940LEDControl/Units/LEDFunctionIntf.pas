unit LEDFunctionIntf;

interface
uses
  LEDColorIntf,
  LEDStateIntf;


type
  ILEDFunction = interface;
  ILEDFunctionWorker = interface;
  ILEDFunctionWorkerSettings = interface;
  ILEDFunctionEnumerator = interface;
  ILEDStateEnumerator = interface;


  ILEDFunctionProvider = interface
    ['{B38F6F90-DC96-42CE-B8F0-21F0DD8AA537}']
    function GetUID: string;
    function GetEnumerator: ILEDFunctionEnumerator;

    function Find(const AFunctionUID: string): ILEDFunction;
  end;


  ILEDFunction = interface
    ['{7087067A-1016-4A7D-ACB1-BA1F388DAD6C}']
    function GetCategoryName: string;
    function GetDisplayName: string;
    function GetUID: string;

    function CreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): ILEDFunctionWorker;
  end;


  ILEDMultiStateFunction = interface(ILEDFunction)
    ['{F16ADF7E-1C1C-4676-8D4F-135B68A80B52}']
    function GetEnumerator: ILEDStateEnumerator;
  end;


  ILEDFunctionObserver = interface
    ['{B78415C9-9F64-4AF1-8983-BACE2B7225EF}']
    procedure ObserveUpdate(Sender: ILEDFunctionWorker);
  end;


  ILEDFunctionWorker = interface
    ['{5EF3230D-B52F-4BD6-8AD3-F3A035F155B1}']
    procedure Attach(AObserver: ILEDFunctionObserver);
    procedure Detach(AObserver: ILEDFunctionObserver);

    function GetProviderUID: string;
    function GetFunctionUID: string;

    function GetCurrentState: ILEDStateWorker;
  end;


  ILEDFunctionWorkerSettings = interface
    ['{8FA287F6-9FE6-4A49-9C87-05C7F3F2B256}']
    function GetStateColor(const AUID: string; out AColor: TLEDColor): Boolean;
  end;


  ILEDFunctionEnumerator = interface
    ['{A03E4E54-19CB-4C08-AD5F-20265817086D}']
    function GetCurrent: ILEDFunction;
    function MoveNext: Boolean;

    property Current: ILEDFunction read GetCurrent;
  end;


  ILEDStateEnumerator = interface
    ['{045E8466-831A-4704-ABBB-31E85789F314}']
    function GetCurrent: ILEDState;
    function MoveNext: Boolean;

    property Current: ILEDState read GetCurrent;
  end;


implementation

end.

unit LEDFunctionIntf;

interface
uses
  LEDColorIntf,
  LEDStateIntf,
  ObserverIntf;


type
  ILEDFunctionEnumerator = interface;
  ILEDStateEnumerator = interface;


  ILEDFunctionProvider = interface
    ['{B38F6F90-DC96-42CE-B8F0-21F0DD8AA537}']
    function GetUID: string;

    function GetEnumerator: ILEDFunctionEnumerator;
  end;


  ILEDFunction = interface(IObservable)
    ['{7087067A-1016-4A7D-ACB1-BA1F388DAD6C}']
    function GetCategoryName: string;
    function GetDisplayName: string;
    function GetUID: string;

    function GetEnumerator: ILEDStateEnumerator;
    function GetCurrentState: ILEDState;
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

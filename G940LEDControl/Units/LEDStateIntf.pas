unit LEDStateIntf;

interface
uses
  LEDColorIntf;


type
  ICustomLEDState = interface
    ['{B5567129-74E1-4888-83F5-8A6174706671}']
    function GetUID: string;
  end;


  ILEDState = interface(ICustomLEDState)
    ['{2C91D49C-2B67-42A3-B5EF-475976DD33F8}']
    function GetDisplayName: string;
    function GetDefaultColor: TLEDColor;
  end;


  ILEDStateWorker = interface(ICustomLEDState)
    ['{0361CBD5-E64E-4972-A8A4-D5FE0B0DFB1C}']
    function GetColor: ILEDStateColor;
  end;


implementation

end.

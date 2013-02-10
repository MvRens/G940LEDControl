unit LEDStateIntf;

interface
uses
  LEDColorIntf;


type
  ILEDState = interface
    ['{0361CBD5-E64E-4972-A8A4-D5FE0B0DFB1C}']
    function GetDisplayName: string;
    function GetUID: string;

    function GetColor: ILEDColor;
  end;


implementation

end.

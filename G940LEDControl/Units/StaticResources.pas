unit StaticResources;

interface
uses
  LEDColorIntf;


const
  StaticProviderUID = 'static';
  StaticFunctionUID: array[TLEDColor] of string =
                     (
                       'off',
                       'green',
                       'amber',
                       'red'
                     );


  StaticCategory = 'Static';
  StaticFunctionDisplayName: array[TLEDColor] of string =
                             (
                               'Off',
                               'Green',
                               'Amber',
                               'Red'
                             );


implementation

end.

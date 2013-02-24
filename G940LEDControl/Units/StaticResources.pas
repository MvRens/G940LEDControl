unit StaticResources;

interface
uses
  LEDColorIntf;


const
  StaticProviderUID = 'static';
  StaticFunctionUID: array[TStaticLEDColor] of string =
                     (
                       'off',
                       'green',
                       'amber',
                       'red'
                     );


  StaticCategory = 'Static';
  StaticFunctionDisplayName: array[TStaticLEDColor] of string =
                             (
                               'Off',
                               'Green',
                               'Amber',
                               'Red'
                             );


implementation

end.

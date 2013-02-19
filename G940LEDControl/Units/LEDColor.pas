unit LEDColor;

interface
uses
  SysUtils,

  LEDColorIntf;


type
  TCustomLEDStateColor = class(TInterfacedObject, ILEDStateColor)
  protected
    { ILEDState }
    function GetCurrentColor: TStaticLEDColor; virtual; abstract;
  end;


  TCustomLEDStateDynamicColor = class(TCustomLEDStateColor, ILEDStateDynamicColor)
  protected
    { ITickLEDState }
    procedure Reset; virtual; abstract;
    procedure Tick; virtual; abstract;
  end;


implementation

end.

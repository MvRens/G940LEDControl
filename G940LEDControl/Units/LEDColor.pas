unit LEDColor;

interface
uses
  SysUtils,

  LEDColorIntf;


type
  TCustomLEDColor = class(TInterfacedObject, ILEDColor)
  protected
    { ILEDState }
    function GetColor: TLEDColor; virtual; abstract;
  end;


  TCustomDynamicLEDColor = class(TCustomLEDColor, IDynamicLEDColor)
  protected
    { ITickLEDState }
    procedure Tick; virtual; abstract;
  end;


implementation

end.

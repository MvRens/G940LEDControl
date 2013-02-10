unit LEDColorIntf;

interface
type
  TLEDColor = (lcOff, lcGreen, lcAmber, lcRed);


  ILEDColor = interface
    ['{B40DF462-B660-4002-A6B9-DD30AC69E8DB}']
    function GetColor: TLEDColor;
  end;


  IDynamicLEDColor = interface(ILEDColor)
    ['{9770E851-580D-4803-9979-0C608CB108A0}']
    procedure Tick;
  end;


implementation

end.

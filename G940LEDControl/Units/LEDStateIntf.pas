unit LEDStateIntf;

interface
type
  TLEDColor = (lcOff, lcGreen, lcAmber, lcRed);

  ILEDState = interface
    ['{B40DF462-B660-4002-A6B9-DD30AC69E8DB}']
    procedure Tick;

    function GetColor: TLEDColor;
  end;


implementation

end.

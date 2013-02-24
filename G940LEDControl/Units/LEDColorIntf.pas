unit LEDColorIntf;

interface
type
  TLEDColor = (lcOff, lcGreen, lcAmber, lcRed,
               lcFlashingGreenFast, lcFlashingGreenNormal,
               lcFlashingAmberFast, lcFlashingAmberNormal,
               lcFlashingRedFast, lcFlashingRedNormal);

  TStaticLEDColor = lcOff..lcRed;



  ILEDStateColor = interface
    ['{B40DF462-B660-4002-A6B9-DD30AC69E8DB}']
    function GetCurrentColor: TStaticLEDColor;
  end;


  ILEDStateDynamicColor = interface(ILEDStateColor)
    ['{9770E851-580D-4803-9979-0C608CB108A0}']
    procedure Reset;
    procedure Tick;
  end;


implementation

end.

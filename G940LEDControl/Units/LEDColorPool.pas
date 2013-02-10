unit LEDColorPool;

interface
uses
  LEDColorIntf;


type
  TLEDColorPoolEntry = (cpeStaticOff,
                        cpeStaticGreen,
                        cpeStaticAmber,
                        cpeStaticRed,

                        cpeFlashingGreenFast,
                        cpeFlashingGreenNormal,
                        cpeFlashingAmberFast,
                        cpeFlashingAmberNormal,
                        cpeFlashingRedFast,
                        cpeFlashingRedNormal);

  TLEDColorPool = class(TObject)
  private
    FStates: array[TLEDColorPoolEntry] of ILEDColor;
  protected
    class function Instance: TLEDColorPool;

    function DoGetColor(AEntry: TLEDColorPoolEntry): ILEDColor;
  public
    class function GetColor(AEntry: TLEDColorPoolEntry): ILEDColor;
  end;


implementation
uses
  SysUtils,

  DynamicLEDColor,
  StaticLEDColor;


var
  LEDColorPoolInstance: TLEDColorPool;


{ TLEDStatePool }
class function TLEDColorPool.GetColor(AEntry: TLEDColorPoolEntry): ILEDColor;
begin
  Result := Instance.DoGetColor(AEntry);
end;


class function TLEDColorPool.Instance: TLEDColorPool;
begin
  if not Assigned(LEDColorPoolInstance) then
    LEDColorPoolInstance := TLEDColorPool.Create;

  Result := LEDColorPoolInstance;
end;


function TLEDColorPool.DoGetColor(AEntry: TLEDColorPoolEntry): ILEDColor;

  function GetFlashingCycle(AColor: TLEDColor): TLEDColorDynArray;
  begin
    SetLength(Result, 2);
    Result[0] := AColor;
    Result[1] := lcOff;
  end;

var
  state: ILEDColor;

begin
  if not Assigned(FStates[AEntry]) then
  begin
    case AEntry of
      cpeStaticOff:           state := TStaticLEDColor.Create(lcOff);
      cpeStaticGreen:         state := TStaticLEDColor.Create(lcGreen);
      cpeStaticAmber:         state := TStaticLEDColor.Create(lcAmber);
      cpeStaticRed:           state := TStaticLEDColor.Create(lcRed);

      cpeFlashingGreenFast:   state := TDynamicLEDColor.Create(GetFlashingCycle(lcGreen), TICKINTERVAL_FAST);
      cpeFlashingGreenNormal: state := TDynamicLEDColor.Create(GetFlashingCycle(lcGreen), TICKINTERVAL_NORMAL);
      cpeFlashingAmberFast:   state := TDynamicLEDColor.Create(GetFlashingCycle(lcAmber), TICKINTERVAL_FAST);
      cpeFlashingAmberNormal: state := TDynamicLEDColor.Create(GetFlashingCycle(lcAmber), TICKINTERVAL_NORMAL);
      cpeFlashingRedFast:     state := TDynamicLEDColor.Create(GetFlashingCycle(lcRed), TICKINTERVAL_FAST);
      cpeFlashingRedNormal:   state := TDynamicLEDColor.Create(GetFlashingCycle(lcRed), TICKINTERVAL_NORMAL);
    end;

    FStates[AEntry] := state;
    Result := state;
  end else
    Result := FStates[AEntry];
end;


initialization
finalization
  FreeAndNil(LEDColorPoolInstance);

end.

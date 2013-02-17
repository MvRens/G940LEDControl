unit LEDColorPool;

interface
uses
  LEDColorIntf;


type
  TLEDColorPool = class(TObject)
  private
    FStates: array[TLEDColor] of ILEDColor;
  protected
    class function Instance: TLEDColorPool;

    function DoGetColor(AColor: TLEDColor): ILEDColor;
  public
    class function GetColor(AColor: TLEDColor): ILEDColor; overload;
  end;


implementation
uses
  SysUtils,

  DynamicLEDColor,
  StaticLEDColor;


var
  LEDColorPoolInstance: TLEDColorPool;


{ TLEDStatePool }
class function TLEDColorPool.GetColor(AColor: TLEDColor): ILEDColor;
begin
  Result := Instance.DoGetColor(AColor);
end;


class function TLEDColorPool.Instance: TLEDColorPool;
begin
  if not Assigned(LEDColorPoolInstance) then
    LEDColorPoolInstance := TLEDColorPool.Create;

  Result := LEDColorPoolInstance;
end;


function TLEDColorPool.DoGetColor(AColor: TLEDColor): ILEDColor;

  function GetFlashingCycle(AColor: TLEDColor): TLEDColorDynArray;
  begin
    SetLength(Result, 2);
    Result[0] := AColor;
    Result[1] := lcOff;
  end;

var
  state: ILEDColor;

begin
  if not Assigned(FStates[AColor]) then
  begin
    case AColor of
      lcOff:                  state := TStaticLEDColor.Create(lcOff);
      lcGreen:                state := TStaticLEDColor.Create(lcGreen);
      lcAmber:                state := TStaticLEDColor.Create(lcAmber);
      lcRed:                  state := TStaticLEDColor.Create(lcRed);

      lcFlashingGreenFast:    state := TDynamicLEDColor.Create(GetFlashingCycle(lcGreen), TICKINTERVAL_FAST);
      lcFlashingGreenNormal:  state := TDynamicLEDColor.Create(GetFlashingCycle(lcGreen), TICKINTERVAL_NORMAL);
      lcFlashingAmberFast:    state := TDynamicLEDColor.Create(GetFlashingCycle(lcAmber), TICKINTERVAL_FAST);
      lcFlashingAmberNormal:  state := TDynamicLEDColor.Create(GetFlashingCycle(lcAmber), TICKINTERVAL_NORMAL);
      lcFlashingRedFast:      state := TDynamicLEDColor.Create(GetFlashingCycle(lcRed), TICKINTERVAL_FAST);
      lcFlashingRedNormal:    state := TDynamicLEDColor.Create(GetFlashingCycle(lcRed), TICKINTERVAL_NORMAL);
    end;

    FStates[AColor] := state;
    Result := state;
  end else
    Result := FStates[AColor];
end;


initialization
finalization
  FreeAndNil(LEDColorPoolInstance);

end.

unit StaticLEDColor;

interface
uses
  LEDColor,
  LEDColorIntf;


type
  TLEDStateStaticColor = class(TCustomLEDStateColor)
  private
    FColor: TStaticLEDColor;
  protected
    function GetCurrentColor: TStaticLEDColor; override;
  public
    constructor Create(AColor: TStaticLEDColor);
  end;


implementation


{ TStaticLEDState }
constructor TLEDStateStaticColor.Create(AColor: TStaticLEDColor);
begin
  inherited Create;

  FColor := AColor;
end;


function TLEDStateStaticColor.GetCurrentColor: TStaticLEDColor;
begin
  Result := FColor;
end;


end.

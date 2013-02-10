unit StaticLEDColor;

interface
uses
  LEDColor,
  LEDColorIntf;


type
  TStaticLEDColor = class(TCustomLEDColor)
  private
    FColor: TLEDColor;
  protected
    function GetColor: TLEDColor; override;
  public
    constructor Create(AColor: TLEDColor);
  end;


implementation


{ TStaticLEDState }
constructor TStaticLEDColor.Create(AColor: TLEDColor);
begin
  inherited Create;

  FColor := AColor;
end;


function TStaticLEDColor.GetColor: TLEDColor;
begin
  Result := FColor;
end;


end.

unit LEDState;

interface
uses
  SysUtils,

  LEDStateIntf;


type
  TCustomLEDState = class(TInterfacedObject, ILEDState)
  protected
    { ILEDState }
    procedure Tick; virtual;
    function GetColor: TLEDColor; virtual; abstract;
  end;


  TStaticLEDState = class(TCustomLEDState)
  private
    FColor: TLEDColor;
  protected
    function GetColor: TLEDColor; override;
  public
    constructor Create(AColor: TLEDColor);
  end;


implementation


{ TCustomLEDState }
procedure TCustomLEDState.Tick;
begin
end;


{ TStaticLEDState }
constructor TStaticLEDState.Create(AColor: TLEDColor);
begin
  inherited Create;

  FColor := AColor;
end;


function TStaticLEDState.GetColor: TLEDColor;
begin
  Result := FColor;
end;

end.

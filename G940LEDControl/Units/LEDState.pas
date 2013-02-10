unit LEDState;

interface
uses
  LEDColorIntf,
  LEDStateIntf;


type
  TLEDState = class(TInterfacedObject, ILEDState)
  private
    FDisplayName: string;
    FUID: string;
    FColor: ILEDColor;
  protected
    { ILEDState }
    function GetDisplayName: string;
    function GetUID: string;

    function GetColor: ILEDColor;
  public
    constructor Create(const AUID, ADisplayName: string; AColor: ILEDColor);
  end;


implementation

{ TLEDState }
constructor TLEDState.Create(const AUID, ADisplayName: string; AColor: ILEDColor);
begin
  inherited Create;

  FUID := AUID;
  FDisplayName := ADisplayName;

  FColor := AColor;
end;


function TLEDState.GetDisplayName: string;
begin
  Result := FDisplayName;
end;


function TLEDState.GetUID: string;
begin
  Result := FUID;
end;


function TLEDState.GetColor: ILEDColor;
begin
  Result := FColor;
end;

end.

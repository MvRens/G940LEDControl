unit LEDState;

interface
uses
  LEDColorIntf,
  LEDStateIntf;


type
  TCustomLEDState = class(TInterfacedObject, ICustomLEDState)
  private
    FUID: string;
  protected
    { ICustomLEDState }
    function GetUID: string;
  public
    constructor Create(const AUID: string);
  end;


  TLEDState = class(TCustomLEDState, ILEDState)
  private
    FDisplayName: string;
    FDefaultColor: TLEDColor;
  protected
    { ILEDState }
    function GetDisplayName: string;
    function GetDefaultColor: TLEDColor;
  public
    constructor Create(const AUID, ADisplayName: string; ADefaultColor: TLEDColor);
  end;


  TLEDStateWorker = class(TCustomLEDState, ILEDStateWorker)
  private
    FColor: ILEDColor;
  protected
    { ILEDStateWorker }
    function GetColor: ILEDColor;
  public
    constructor Create(const AUID: string; AColor: ILEDColor);
  end;


implementation


{ TCustomLEDState }
constructor TCustomLEDState.Create(const AUID: string);
begin
  inherited Create;

  FUID := AUID;
end;


function TCustomLEDState.GetUID: string;
begin
  Result := FUID;
end;


{ TLEDState }
constructor TLEDState.Create(const AUID, ADisplayName: string; ADefaultColor: TLEDColor);
begin
  inherited Create(AUID);

  FDisplayName := ADisplayName;
  FDefaultColor := ADefaultColor;
end;


function TLEDState.GetDisplayName: string;
begin
  Result := FDisplayName;
end;


function TLEDState.GetDefaultColor: TLEDColor;
begin
  Result := FDefaultColor;
end;


{ TLEDStateWorker }
constructor TLEDStateWorker.Create(const AUID: string; AColor: ILEDColor);
begin
  inherited Create(AUID);

  FColor := AColor;
end;


function TLEDStateWorker.GetColor: ILEDColor;
begin
  Result := FColor;
end;

end.

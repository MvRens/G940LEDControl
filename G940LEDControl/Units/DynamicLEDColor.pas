unit DynamicLEDColor;

interface
uses
  LEDColor,
  LEDColorIntf;


const
  TICKINTERVAL_NORMAL = 2;
  TICKINTERVAL_FAST = 1;


type
  TLEDColorDynArray = array of TLEDColor;


  TDynamicLEDColor = class(TCustomDynamicLEDColor)
  private
    FCycleColors: TLEDColorDynArray;
    FCycleIndex: Integer;
    FTickInterval: Integer;
    FTickCount: Integer;
  protected
    { ILEDState }
    function GetColor: TLEDColor; override;

    { ITickLEDState }
    procedure Tick; override;
  public
    constructor Create(ACycleColors: TLEDColorDynArray; ATickInterval: Integer = TICKINTERVAL_NORMAL);
  end;



implementation
uses
  SysUtils;


{ TDynamicLEDState }
constructor TDynamicLEDColor.Create(ACycleColors: TLEDColorDynArray; ATickInterval: Integer);
begin
  inherited Create;

  if Length(ACycleColors) = 0 then
    raise Exception.Create(Self.ClassName + ' must have at least one color in a cycle');

  FCycleColors := ACycleColors;
  FCycleIndex := Low(FCycleColors);
  FTickInterval := ATickInterval;
  FTickCount := 0;
end;


function TDynamicLEDColor.GetColor: TLEDColor;
begin
  Result := FCycleColors[FCycleIndex];
end;


procedure TDynamicLEDColor.Tick;
begin
  Inc(FTickCount);

  if FTickCount >= FTickInterval then
  begin
    Inc(FCycleIndex);
    if FCycleIndex > High(FCycleColors) then
      FCycleIndex := 0;

    FTickCount := 0;
  end;
end;

end.

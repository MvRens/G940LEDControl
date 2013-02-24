unit DynamicLEDColor;

interface
uses
  LEDColor,
  LEDColorIntf;


const
  TICKINTERVAL_NORMAL = 2;
  TICKINTERVAL_FAST = 1;


type
  TStaticLEDColorDynArray = array of TStaticLEDColor;


  TDynamicLEDColor = class(TCustomLEDStateDynamicColor)
  private
    FCycleColors: TStaticLEDColorDynArray;
    FCycleIndex: Integer;
    FTickInterval: Integer;
    FTickCount: Integer;
  protected
    { ILEDState }
    function GetCurrentColor: TStaticLEDColor; override;

    { ITickLEDState }
    procedure Reset; override;
    procedure Tick; override;
  public
    constructor Create(ACycleColors: TStaticLEDColorDynArray; ATickInterval: Integer = TICKINTERVAL_NORMAL);
  end;



implementation
uses
  SysUtils;


{ TDynamicLEDState }
constructor TDynamicLEDColor.Create(ACycleColors: TStaticLEDColorDynArray; ATickInterval: Integer);
begin
  inherited Create;

  if Length(ACycleColors) = 0 then
    raise Exception.Create(Self.ClassName + ' must have at least one color in a cycle');

  FCycleColors := ACycleColors;
  FCycleIndex := Low(FCycleColors);
  FTickInterval := ATickInterval;
  Reset;
end;


function TDynamicLEDColor.GetCurrentColor: TStaticLEDColor;
begin
  Result := FCycleColors[FCycleIndex];
end;


procedure TDynamicLEDColor.Reset;
begin
  FCycleIndex := 0;
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

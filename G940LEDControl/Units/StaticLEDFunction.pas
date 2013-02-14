unit StaticLEDFunction;

interface
uses
  LEDFunction,
  LEDColorIntf,
  LEDStateIntf;


type
  TStaticLEDFunctionProvider = class(TCustomLEDFunctionProvider)
  protected
    procedure RegisterFunctions; override;

    function GetUID: string; override;
  end;


  TStaticLEDFunction = class(TCustomLEDFunction)
  private
    FColor: TLEDColor;
    FState: ILEDState;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;

    function GetCurrentState: ILEDState; override;
  public
    constructor Create(AColor: TLEDColor);
  end;


implementation
uses
  LEDColorPool,
  LEDFunctionRegistry,
  LEDState,
  StaticResources;


{ TStaticLEDFunctionProvider }
procedure TStaticLEDFunctionProvider.RegisterFunctions;
var
  color: TLEDColor;

begin
  for color := Low(TLEDColor) to High(TLEDColor) do
    RegisterFunction(TStaticLEDFunction.Create(color));
end;


function TStaticLEDFunctionProvider.GetUID: string;
begin
  Result := StaticProviderUID;
end;


{ TStaticLEDFunction }
constructor TStaticLEDFunction.Create(AColor: TLEDColor);
begin
  inherited Create;

  FColor := AColor;
end;


function TStaticLEDFunction.GetCategoryName: string;
begin
  Result := StaticCategory;
end;


function TStaticLEDFunction.GetDisplayName: string;
begin
  Result := StaticFunctionDisplayName[FColor];
end;


function TStaticLEDFunction.GetUID: string;
begin
  Result := StaticFunctionUID[FColor];
end;


function TStaticLEDFunction.GetCurrentState: ILEDState;
begin
  if not Assigned(FState) then
    FState := TLEDState.Create('', '', TLEDColorPool.GetColor(FColor));

  Result := FState;
end;



initialization
  TLEDFunctionRegistry.Register(TStaticLEDFunctionProvider.Create);

end.

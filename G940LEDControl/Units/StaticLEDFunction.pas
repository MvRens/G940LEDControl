unit StaticLEDFunction;

interface
uses
  LEDFunction,
  LEDColorIntf;


type
  TStaticLEDFunctionProvider = class(TCustomLEDFunctionProvider)
  protected
    function GetUID: string; override;
  public
    constructor Create;
  end;


  TStaticLEDFunction = class(TCustomLEDFunction)
  private
    FColor: TLEDColor;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;
  public
    constructor Create(AColor: TLEDColor);
  end;


const
  StaticProviderUID = 'static';
  StaticFunctionUID: array[TLEDColor] of string =
                     (
                       'off',
                       'green',
                       'amber',
                       'red'
                     );


implementation
uses
  LEDFunctionRegistry;


const
  CategoryStatic = 'Static';
  FunctionDisplayName: array[TLEDColor] of string =
                       (
                         'Off',
                         'Green',
                         'Amber',
                         'Red'
                       );



{ TStaticLEDFunctionProvider }
constructor TStaticLEDFunctionProvider.Create;
var
  color: TLEDColor;

begin
  inherited Create;

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
  Result := CategoryStatic;
end;


function TStaticLEDFunction.GetDisplayName: string;
begin
  Result := FunctionDisplayName[FColor];
end;


function TStaticLEDFunction.GetUID: string;
begin
  Result := StaticFunctionUID[FColor];
end;


initialization
  TLEDFunctionRegistry.Register(TStaticLEDFunctionProvider.Create);

end.

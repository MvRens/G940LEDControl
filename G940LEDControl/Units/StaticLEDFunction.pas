unit StaticLEDFunction;

interface
uses
  LEDFunction,
  LEDStateIntf;


type
  TStaticLEDFunctionProvider = class(TCustomLEDFunctionProvider)
  protected
    function GetUniqueName: string; override;
  public
    constructor Create;
  end;


  TStaticLEDFunction = class(TCustomLEDFunction)
  private
    FColor: TLEDColor;
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUniqueName: string; override;
  public
    constructor Create(AColor: TLEDColor);
  end;


implementation
uses
  LEDFunctionRegistry;


const
  CategoryStatic = 'Static';

  ProviderUniqueName = 'static';

  FunctionUniqueName: array[TLEDColor] of string =
                      (
                        'off',
                        'green',
                        'amber',
                        'red'
                      );

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


function TStaticLEDFunctionProvider.GetUniqueName: string;
begin
  Result := ProviderUniqueName;
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


function TStaticLEDFunction.GetUniqueName: string;
begin
  Result := FunctionUniqueName[FColor];
end;


initialization
  TLEDFunctionRegistry.Register(TStaticLEDFunctionProvider.Create);

end.

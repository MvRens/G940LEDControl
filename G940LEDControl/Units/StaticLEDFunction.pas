unit StaticLEDFunction;

interface
uses
  LEDFunction,
  LEDFunctionIntf,
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
  protected
    function GetCategoryName: string; override;
    function GetDisplayName: string; override;
    function GetUID: string; override;

    function CreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string = ''): ILEDFunctionWorker; override;
  public
    constructor Create(AColor: TLEDColor);
  end;


implementation
uses
  LEDColorPool,
  LEDFunctionRegistry,
  LEDState,
  StaticResources;


type
  TStaticLEDFunctionWorker = class(TCustomLEDFunctionWorker)
  private
    FState: ILEDStateWorker;
  protected
    function GetCurrentState: ILEDStateWorker; override;
  public
    constructor Create(const AProviderUID, AFunctionUID: string; AColor: TLEDColor);
  end;


{ TStaticLEDFunctionProvider }
procedure TStaticLEDFunctionProvider.RegisterFunctions;
var
  color: TLEDColor;

begin
  for color := Low(TStaticLEDColor) to High(TStaticLEDColor) do
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


function TStaticLEDFunction.CreateWorker(ASettings: ILEDFunctionWorkerSettings; const APreviousState: string): ILEDFunctionWorker;
begin
  Result := TStaticLEDFunctionWorker.Create(StaticProviderUID, GetUID, FColor);
end;


{ TStaticLEDFunctionWorker }
constructor TStaticLEDFunctionWorker.Create(const AProviderUID, AFunctionUID: string; AColor: TLEDColor);
begin
  inherited Create(AProviderUID, AFunctionUID);

  FState := TLEDStateWorker.Create('', TLEDColorPool.GetColor(AColor));
end;


function TStaticLEDFunctionWorker.GetCurrentState: ILEDStateWorker;
begin
  Result := FState;
end;


initialization
  TLEDFunctionRegistry.Register(TStaticLEDFunctionProvider.Create);

end.

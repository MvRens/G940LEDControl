unit LEDFunctionRegistry;

interface
uses
  Classes,

  LEDFunctionIntf;


type
  TLEDFunctionProviderList = class;

  TLEDFunctionRegistry = class(TObject)
  private
    FProviders: TLEDFunctionProviderList;
  protected
    class function Instance: TLEDFunctionRegistry;

    procedure DoRegister(AProvider: ILEDFunctionProvider);
    procedure DoUnregister(AProvider: ILEDFunctionProvider);
    function DoFind(const AUID: string): ILEDFunctionProvider;

    function GetProviders: TLEDFunctionProviderList;
  public
    constructor Create;
    destructor Destroy; override;

    class procedure Register(AProvider: ILEDFunctionProvider);
    class procedure Unregister(AProvider: ILEDFunctionProvider);

    class function Find(const AUID: string): ILEDFunctionProvider;

    class function Providers: TLEDFunctionProviderList;
  end;


  TLEDFunctionProviderListEnumerator = class;

  TLEDFunctionProviderList = class(TObject)
  private
    FList: TInterfaceList;
  protected
    procedure Add(AProvider: ILEDFunctionProvider);
    procedure Remove(AProvider: ILEDFunctionProvider);
  public
    constructor Create;
    destructor Destroy; override;

    function Find(const AUID: string): ILEDFunctionProvider;

    function GetEnumerator: TLEDFunctionProviderListEnumerator;
  end;


  TLEDFunctionProviderListEnumerator = class(TInterfaceListEnumerator)
  public
    function GetCurrent: ILEDFunctionProvider; inline;
    property Current: ILEDFunctionProvider read GetCurrent;
  end;


implementation
uses
  SysUtils;


var
  RegistryInstance: TLEDFunctionRegistry;


{ TLEDFunctionRegistry }
class procedure TLEDFunctionRegistry.Register(AProvider: ILEDFunctionProvider);
begin
  Instance.DoRegister(AProvider);
end;


class procedure TLEDFunctionRegistry.Unregister(AProvider: ILEDFunctionProvider);
begin
  Instance.DoUnregister(AProvider);
end;


class function TLEDFunctionRegistry.Find(const AUID: string): ILEDFunctionProvider;
begin
  Result := Instance.DoFind(AUID);
end;


class function TLEDFunctionRegistry.Providers: TLEDFunctionProviderList;
begin
  Result := Instance.GetProviders;
end;


class function TLEDFunctionRegistry.Instance: TLEDFunctionRegistry;
begin
  if not Assigned(RegistryInstance) then
    RegistryInstance := TLEDFunctionRegistry.Create;

  Result := RegistryInstance;
end;


constructor TLEDFunctionRegistry.Create;
begin
  inherited Create;

  FProviders := TLEDFunctionProviderList.Create;
end;


destructor TLEDFunctionRegistry.Destroy;
begin
  FreeAndNil(FProviders);

  inherited;
end;


procedure TLEDFunctionRegistry.DoRegister(AProvider: ILEDFunctionProvider);
begin
  FProviders.Add(AProvider);
end;


procedure TLEDFunctionRegistry.DoUnregister(AProvider: ILEDFunctionProvider);
begin
  FProviders.Remove(AProvider);
end;


function TLEDFunctionRegistry.DoFind(const AUID: string): ILEDFunctionProvider;
begin
  Result := FProviders.Find(AUID);
end;


function TLEDFunctionRegistry.GetProviders: TLEDFunctionProviderList;
begin
  Result := FProviders;
end;


{ TLEDFunctionProviderList }
constructor TLEDFunctionProviderList.Create;
begin
  inherited Create;

  FList := TInterfaceList.Create;
end;


destructor TLEDFunctionProviderList.Destroy;
begin
  FreeAndNil(FList);

  inherited;
end;


function TLEDFunctionProviderList.Find(const AUID: string): ILEDFunctionProvider;
var
  provider: ILEDFunctionProvider;

begin
  Result := nil;

  for provider in Self do
    if provider.GetUID = AUID then
    begin
      Result := provider;
      break;
    end;
end;

procedure TLEDFunctionProviderList.Add(AProvider: ILEDFunctionProvider);
var
  stableReference: ILEDFunctionProvider;

begin
  stableReference := (AProvider as ILEDFunctionProvider);
  if FList.IndexOf(stableReference) = -1 then
    FList.Add(stableReference);
end;


procedure TLEDFunctionProviderList.Remove(AProvider: ILEDFunctionProvider);
var
  index: Integer;

begin
  index := FList.IndexOf(AProvider as ILEDFunctionProvider);
  if index  > -1 then
    FList.Delete(index);
end;


function TLEDFunctionProviderList.GetEnumerator: TLEDFunctionProviderListEnumerator;
begin
  Result := TLEDFunctionProviderListEnumerator.Create(FList);
end;


{ TLEDFunctionProviderListEnumerator }
function TLEDFunctionProviderListEnumerator.GetCurrent: ILEDFunctionProvider;
begin
  Result := ((inherited GetCurrent) as ILEDFunctionProvider);
end;


initialization
finalization
  FreeAndNil(RegistryInstance);

end.

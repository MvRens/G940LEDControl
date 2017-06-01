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
  public
    constructor Create;
    destructor Destroy; override;

    procedure Register(AProvider: ILEDFunctionProvider);
    procedure Unregister(AProvider: ILEDFunctionProvider);

    function Find(const AUID: string): ILEDFunctionProvider;

    function Providers: TLEDFunctionProviderList;
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


{ TLEDFunctionRegistry }
constructor TLEDFunctionRegistry.Create;
begin
  inherited Create;

  FProviders := TLEDFunctionProviderList.Create;
end;


destructor TLEDFunctionRegistry.Destroy;
begin
  FreeAndNil(FProviders);

  inherited Destroy;
end;


procedure TLEDFunctionRegistry.Register(AProvider: ILEDFunctionProvider);
begin
  FProviders.Add(AProvider);
end;


procedure TLEDFunctionRegistry.Unregister(AProvider: ILEDFunctionProvider);
begin
  FProviders.Remove(AProvider);
end;


function TLEDFunctionRegistry.Find(const AUID: string): ILEDFunctionProvider;
begin
  Result := FProviders.Find(AUID);
end;


function TLEDFunctionRegistry.Providers: TLEDFunctionProviderList;
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

  inherited Destroy;
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

end.

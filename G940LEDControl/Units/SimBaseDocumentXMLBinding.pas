{
  X2Software XML Data Binding

    Generated on:   18-4-2015 11:27:09
    Generated from: F:\Development\G940\G940LEDControl\XSD\SimBaseDocument.xsd
}
unit SimBaseDocumentXMLBinding;

interface
uses
  Classes,
  SysUtils,
  XMLDoc,
  XMLIntf,
  XMLDataBindingUtils;

type
  { Forward declarations for SimBaseDocument }
  IXMLSimBaseDocument = interface;
  IXMLLaunchAddon = interface;
  TXMLSimBaseBoolean = (SimBaseBoolean_False,
                        SimBaseBoolean_True);

  { Interfaces for SimBaseDocument }
  IXMLSimBaseDocumentEnumerator = interface
    ['{42B9B24E-C414-4C60-A01A-601E829465C1}']
    function GetCurrent: IXMLLaunchAddon;
    function MoveNext: Boolean;
    property Current: IXMLLaunchAddon read GetCurrent;
  end;


  IXMLSimBaseDocument = interface(IXMLNodeCollection)
    ['{7C4F45A9-16CB-413E-9C62-D682F5E5AE0C}']
    procedure XSDValidateDocument;
    procedure XSDValidate;

    function GetEnumerator: IXMLSimBaseDocumentEnumerator;

    function Get_LaunchAddon(Index: Integer): IXMLLaunchAddon;
    function Add: IXMLLaunchAddon;
    function Insert(Index: Integer): IXMLLaunchAddon;

    property LaunchAddon[Index: Integer]: IXMLLaunchAddon read Get_LaunchAddon; default;

    function GetDescr: WideString;
    function GetFilename: WideString;
    function GetDisabledText: WideString;
    function GetDisabled: TXMLSimBaseBoolean;
    function GetLaunchManualLoadText: WideString;
    function GetLaunchManualLoad: TXMLSimBaseBoolean;
    function Get_Type: WideString;
    function Getversion: WideString;

    procedure SetDescr(const Value: WideString);
    procedure SetFilename(const Value: WideString);
    procedure SetDisabledText(const Value: WideString);
    procedure SetDisabled(const Value: TXMLSimBaseBoolean);
    procedure SetLaunchManualLoadText(const Value: WideString);
    procedure SetLaunchManualLoad(const Value: TXMLSimBaseBoolean);
    procedure Set_Type(const Value: WideString);
    procedure Setversion(const Value: WideString);

    property Descr: WideString read GetDescr write SetDescr;
    property Filename: WideString read GetFilename write SetFilename;
    property DisabledText: WideString read GetDisabledText write SetDisabledText;
    property Disabled: TXMLSimBaseBoolean read GetDisabled write SetDisabled;
    property LaunchManualLoadText: WideString read GetLaunchManualLoadText write SetLaunchManualLoadText;
    property LaunchManualLoad: TXMLSimBaseBoolean read GetLaunchManualLoad write SetLaunchManualLoad;
    property _Type: WideString read Get_Type write Set_Type;
    property version: WideString read Getversion write Setversion;
  end;

  IXMLLaunchAddon = interface(IXMLNode)
    ['{31A8182C-75CC-4735-B68E-4EBDCDEFB1E3}']
    procedure XSDValidate;

    function GetName: WideString;
    function GetDisabledText: WideString;
    function GetDisabled: TXMLSimBaseBoolean;
    function GetManualLoadText: WideString;
    function GetManualLoad: TXMLSimBaseBoolean;
    function GetPath: WideString;

    procedure SetName(const Value: WideString);
    procedure SetDisabledText(const Value: WideString);
    procedure SetDisabled(const Value: TXMLSimBaseBoolean);
    procedure SetManualLoadText(const Value: WideString);
    procedure SetManualLoad(const Value: TXMLSimBaseBoolean);
    procedure SetPath(const Value: WideString);

    property Name: WideString read GetName write SetName;
    property DisabledText: WideString read GetDisabledText write SetDisabledText;
    property Disabled: TXMLSimBaseBoolean read GetDisabled write SetDisabled;
    property ManualLoadText: WideString read GetManualLoadText write SetManualLoadText;
    property ManualLoad: TXMLSimBaseBoolean read GetManualLoad write SetManualLoad;
    property Path: WideString read GetPath write SetPath;
  end;


  { Classes for SimBaseDocument }
  TXMLSimBaseDocumentEnumerator = class(TXMLNodeCollectionEnumerator, IXMLSimBaseDocumentEnumerator)
  protected
    function GetCurrent: IXMLLaunchAddon;
  end;


  TXMLSimBaseDocument = class(TX2XMLNodeCollection, IXSDValidate, IXMLSimBaseDocument)
  public
    procedure AfterConstruction; override;
  protected
    procedure XSDValidateDocument;
    procedure XSDValidate;

    function GetEnumerator: IXMLSimBaseDocumentEnumerator;

    function Get_LaunchAddon(Index: Integer): IXMLLaunchAddon;
    function Add: IXMLLaunchAddon;
    function Insert(Index: Integer): IXMLLaunchAddon;

    function GetDescr: WideString;
    function GetFilename: WideString;
    function GetDisabledText: WideString;
    function GetDisabled: TXMLSimBaseBoolean;
    function GetLaunchManualLoadText: WideString;
    function GetLaunchManualLoad: TXMLSimBaseBoolean;
    function Get_Type: WideString;
    function Getversion: WideString;

    procedure SetDescr(const Value: WideString);
    procedure SetFilename(const Value: WideString);
    procedure SetDisabledText(const Value: WideString);
    procedure SetDisabled(const Value: TXMLSimBaseBoolean);
    procedure SetLaunchManualLoadText(const Value: WideString);
    procedure SetLaunchManualLoad(const Value: TXMLSimBaseBoolean);
    procedure Set_Type(const Value: WideString);
    procedure Setversion(const Value: WideString);
  end;

  TXMLLaunchAddon = class(TX2XMLNode, IXSDValidate, IXMLLaunchAddon)
  protected
    procedure XSDValidate;

    function GetName: WideString;
    function GetDisabledText: WideString;
    function GetDisabled: TXMLSimBaseBoolean;
    function GetManualLoadText: WideString;
    function GetManualLoad: TXMLSimBaseBoolean;
    function GetPath: WideString;

    procedure SetName(const Value: WideString);
    procedure SetDisabledText(const Value: WideString);
    procedure SetDisabled(const Value: TXMLSimBaseBoolean);
    procedure SetManualLoadText(const Value: WideString);
    procedure SetManualLoad(const Value: TXMLSimBaseBoolean);
    procedure SetPath(const Value: WideString);
  end;


  { Document functions }
  function GetSimBaseDocument(ADocument: XMLIntf.IXMLDocument): IXMLSimBaseDocument;
  function LoadSimBaseDocument(const AFileName: String): IXMLSimBaseDocument;
  function LoadSimBaseDocumentFromStream(AStream: TStream): IXMLSimBaseDocument;
  function LoadSimBaseDocumentFromString(const AString: String{$IF CompilerVersion >= 20}; AEncoding: TEncoding = nil; AOwnsEncoding: Boolean = True{$IFEND}): IXMLSimBaseDocument;
  function NewSimBaseDocument: IXMLSimBaseDocument;


const
  TargetNamespace = '';


const
  SimBaseBooleanValues: array[TXMLSimBaseBoolean] of WideString =
                        (
                          'False',
                          'True'
                        );

  { Enumeration conversion helpers }
  function StringToSimBaseBoolean(const AValue: WideString): TXMLSimBaseBoolean;

implementation
uses
  Variants;

{ Document functions }
function GetSimBaseDocument(ADocument: XMLIntf.IXMLDocument): IXMLSimBaseDocument;
begin
  Result := ADocument.GetDocBinding('SimBase.Document', TXMLSimBaseDocument, TargetNamespace) as IXMLSimBaseDocument
end;

function LoadSimBaseDocument(const AFileName: String): IXMLSimBaseDocument;
begin
  Result := LoadXMLDocument(AFileName).GetDocBinding('SimBase.Document', TXMLSimBaseDocument, TargetNamespace) as IXMLSimBaseDocument
end;

function LoadSimBaseDocumentFromStream(AStream: TStream): IXMLSimBaseDocument;
var
  doc: XMLIntf.IXMLDocument;

begin
  doc := NewXMLDocument;
  doc.LoadFromStream(AStream);
  Result  := GetSimBaseDocument(doc);
end;

function LoadSimBaseDocumentFromString(const AString: String{$IF CompilerVersion >= 20}; AEncoding: TEncoding; AOwnsEncoding: Boolean{$IFEND}): IXMLSimBaseDocument;
var
  stream: TStringStream;

begin
  stream := TStringStream.Create(AString{$IF CompilerVersion >= 20}, AEncoding, AOwnsEncoding{$IFEND});
  try
    Result  := LoadSimBaseDocumentFromStream(stream);
  finally
    FreeAndNil(stream);
  end;
end;

function NewSimBaseDocument: IXMLSimBaseDocument;
begin
  Result := NewXMLDocument.GetDocBinding('SimBase.Document', TXMLSimBaseDocument, TargetNamespace) as IXMLSimBaseDocument
end;



{ Enumeration conversion helpers }
function StringToSimBaseBoolean(const AValue: WideString): TXMLSimBaseBoolean;
var
  enumValue: TXMLSimBaseBoolean;

begin
  Result := TXMLSimBaseBoolean(-1);
  for enumValue := Low(TXMLSimBaseBoolean) to High(TXMLSimBaseBoolean) do
    if SimBaseBooleanValues[enumValue] = AValue then
    begin
      Result := enumValue;
      break;
    end;
end;


{ Implementation for SimBaseDocument }
function TXMLSimBaseDocumentEnumerator.GetCurrent: IXMLLaunchAddon;
begin
  Result := (inherited GetCurrent as IXMLLaunchAddon);
end;

procedure TXMLSimBaseDocument.AfterConstruction;
begin
  RegisterChildNode('Launch.Addon', TXMLLaunchAddon);

  ItemTag := 'Launch.Addon';
  ItemInterface := IXMLLaunchAddon;

  inherited;
end;

procedure TXMLSimBaseDocument.XSDValidateDocument;
begin
  XMLDataBindingUtils.XSDValidate(Self);
end;

procedure TXMLSimBaseDocument.XSDValidate;
begin
  GetDisabled;
  GetLaunchManualLoad;
  CreateRequiredElements(Self, ['Descr', 'Filename']);
  CreateRequiredAttributes(Self, ['Type', 'version']);
  SortChildNodes(Self, ['Descr', 'Filename', 'Disabled', 'Launch.ManualLoad', 'Launch.Addon']);
end;

function TXMLSimBaseDocument.GetEnumerator: IXMLSimBaseDocumentEnumerator;
begin
  Result := TXMLSimBaseDocumentEnumerator.Create(Self);
end;

function TXMLSimBaseDocument.Get_LaunchAddon(Index: Integer): IXMLLaunchAddon;
begin
  Result := (List[Index] as IXMLLaunchAddon);
end;

function TXMLSimBaseDocument.Add: IXMLLaunchAddon;
begin
  Result := (AddItem(-1) as IXMLLaunchAddon);
end;

function TXMLSimBaseDocument.Insert(Index: Integer): IXMLLaunchAddon;
begin
  Result := (AddItem(Index) as IXMLLaunchAddon);
end;

function TXMLSimBaseDocument.GetDescr: WideString;
begin
  Result := ChildNodes['Descr'].Text;
end;

function TXMLSimBaseDocument.GetFilename: WideString;
begin
  Result := ChildNodes['Filename'].Text;
end;

function TXMLSimBaseDocument.GetDisabledText: WideString;
begin
  Result := ChildNodes['Disabled'].Text;
end;


function TXMLSimBaseDocument.GetDisabled: TXMLSimBaseBoolean;
begin
  Result := StringToSimBaseBoolean(GetDisabledText);
end;

function TXMLSimBaseDocument.GetLaunchManualLoadText: WideString;
begin
  Result := ChildNodes['Launch.ManualLoad'].Text;
end;


function TXMLSimBaseDocument.GetLaunchManualLoad: TXMLSimBaseBoolean;
begin
  Result := StringToSimBaseBoolean(GetLaunchManualLoadText);
end;

function TXMLSimBaseDocument.Get_Type: WideString;
begin
  Result := AttributeNodes['Type'].Text;
end;

function TXMLSimBaseDocument.Getversion: WideString;
begin
  Result := AttributeNodes['version'].Text;
end;

procedure TXMLSimBaseDocument.SetDescr(const Value: WideString);
begin
  ChildNodes['Descr'].NodeValue := GetValidXMLText(Value);
end;

procedure TXMLSimBaseDocument.SetFilename(const Value: WideString);
begin
  ChildNodes['Filename'].NodeValue := GetValidXMLText(Value);
end;

procedure TXMLSimBaseDocument.SetDisabledText(const Value: WideString);
begin
  ChildNodes['Disabled'].NodeValue := Value;
end;


procedure TXMLSimBaseDocument.SetDisabled(const Value: TXMLSimBaseBoolean);
begin
  ChildNodes['Disabled'].NodeValue := SimBaseBooleanValues[Value];
end;

procedure TXMLSimBaseDocument.SetLaunchManualLoadText(const Value: WideString);
begin
  ChildNodes['Launch.ManualLoad'].NodeValue := Value;
end;


procedure TXMLSimBaseDocument.SetLaunchManualLoad(const Value: TXMLSimBaseBoolean);
begin
  ChildNodes['Launch.ManualLoad'].NodeValue := SimBaseBooleanValues[Value];
end;

procedure TXMLSimBaseDocument.Set_Type(const Value: WideString);
begin
  SetAttribute('Type', GetValidXMLText(Value));
end;

procedure TXMLSimBaseDocument.Setversion(const Value: WideString);
begin
  SetAttribute('version', GetValidXMLText(Value));
end;

procedure TXMLLaunchAddon.XSDValidate;
begin
  GetDisabled;
  GetManualLoad;
  CreateRequiredElements(Self, ['Name', 'Path']);
  SortChildNodes(Self, ['Name', 'Disabled', 'ManualLoad', 'Path']);
end;

function TXMLLaunchAddon.GetName: WideString;
begin
  Result := ChildNodes['Name'].Text;
end;

function TXMLLaunchAddon.GetDisabledText: WideString;
begin
  Result := ChildNodes['Disabled'].Text;
end;


function TXMLLaunchAddon.GetDisabled: TXMLSimBaseBoolean;
begin
  Result := StringToSimBaseBoolean(GetDisabledText);
end;

function TXMLLaunchAddon.GetManualLoadText: WideString;
begin
  Result := ChildNodes['ManualLoad'].Text;
end;


function TXMLLaunchAddon.GetManualLoad: TXMLSimBaseBoolean;
begin
  Result := StringToSimBaseBoolean(GetManualLoadText);
end;

function TXMLLaunchAddon.GetPath: WideString;
begin
  Result := ChildNodes['Path'].Text;
end;

procedure TXMLLaunchAddon.SetName(const Value: WideString);
begin
  ChildNodes['Name'].NodeValue := GetValidXMLText(Value);
end;

procedure TXMLLaunchAddon.SetDisabledText(const Value: WideString);
begin
  ChildNodes['Disabled'].NodeValue := Value;
end;


procedure TXMLLaunchAddon.SetDisabled(const Value: TXMLSimBaseBoolean);
begin
  ChildNodes['Disabled'].NodeValue := SimBaseBooleanValues[Value];
end;

procedure TXMLLaunchAddon.SetManualLoadText(const Value: WideString);
begin
  ChildNodes['ManualLoad'].NodeValue := Value;
end;


procedure TXMLLaunchAddon.SetManualLoad(const Value: TXMLSimBaseBoolean);
begin
  ChildNodes['ManualLoad'].NodeValue := SimBaseBooleanValues[Value];
end;

procedure TXMLLaunchAddon.SetPath(const Value: WideString);
begin
  ChildNodes['Path'].NodeValue := GetValidXMLText(Value);
end;



end.

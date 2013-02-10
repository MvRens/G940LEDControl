unit ButtonFunctionFrm;

interface
uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,

  VirtualTrees,

  Profile;


type
  TButtonFunctionForm = class(TForm)
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    vstFunctions: TVirtualStringTree;
    vstStates: TVirtualStringTree;
    pnlFunction: TPanel;
    pnlName: TPanel;
    lblFunctionName: TLabel;
    lblCategoryName: TLabel;
    lblHasStates: TLabel;
    lblNoStates: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstFunctionsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
  private
    FButtonIndex: Integer;
    FProfile: TProfile;
  protected
    procedure LoadFunctions;

    property ButtonIndex: Integer read FButtonIndex write FButtonIndex;
    property Profile: TProfile read FProfile write FProfile;
  public
    class function Execute(AProfile: TProfile; AButtonIndex: Integer): Boolean;
  end;


implementation
uses
  System.SysUtils,
  Generics.Collections,

  LEDFunctionIntf,
  LEDFunctionRegistry;


type
  TNodeType = (ntCategory, ntFunction);
  TNodeData = record
    NodeType: TNodeType;
    Provider: ILEDFunctionProvider;
    LEDFunction: ILEDFunction;
  end;

  PNodeData = ^TNodeData;


{$R *.dfm}


{ TButtonFunctionForm }
class function TButtonFunctionForm.Execute(AProfile: TProfile; AButtonIndex: Integer): Boolean;
begin
  with Self.Create(nil) do
  try
    Profile := AProfile;
    ButtonIndex := AButtonIndex;

    Result := (ShowModal = mrOk);
  finally
    Free;
  end;
end;

procedure TButtonFunctionForm.FormCreate(Sender: TObject);
begin
  vstFunctions.NodeDataSize := SizeOf(TNodeData);

  lblNoStates.Top := lblHasStates.Top;

  lblCategoryName.Caption := '';
  lblFunctionName.Caption := '';

  LoadFunctions;
end;


procedure TButtonFunctionForm.FormDestroy(Sender: TObject);
begin
  //
end;


procedure TButtonFunctionForm.LoadFunctions;
var
  categoryNodes: TDictionary<string,PVirtualNode>;

  function GetCategoryNode(AProvider: ILEDFunctionProvider; AFunction: ILEDFunction): PVirtualNode;
  var
    category: string;
    nodeData: PNodeData;

  begin
    category := AFunction.GetCategoryName;

    if not categoryNodes.ContainsKey(category) then
    begin
      Result := vstFunctions.AddChild(nil);
      Include(Result^.States, vsExpanded);

      nodeData := vstFunctions.GetNodeData(Result);
      nodeData^.NodeType := ntCategory;
      nodeData^.Provider := AProvider;
      nodeData^.LEDFunction := AFunction;

      categoryNodes.Add(category, Result);
    end else
      Result := categoryNodes.Items[category];
  end;

var
  node: PVirtualNode;
  nodeData: PNodeData;
  provider: ILEDFunctionProvider;
  ledFunction: ILEDFunction;

begin
  vstFunctions.BeginUpdate;
  try
    vstFunctions.Clear;

    categoryNodes := TDictionary<string, PVirtualNode>.Create;
    try
      for provider in TLEDFunctionRegistry.Providers do
      begin
        for ledFunction in provider do
        begin
          node := vstFunctions.AddChild(GetCategoryNode(provider, ledFunction));
          nodeData := vstFunctions.GetNodeData(node);

          nodeData^.NodeType := ntFunction;
          nodeData^.Provider := provider;
          nodeData^.LEDFunction := ledFunction;
        end;
      end;
    finally
      FreeAndNil(categoryNodes);
    end;
  finally
    vstFunctions.EndUpdate;
  end;
end;


procedure TButtonFunctionForm.vstFunctionsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                                  TextType: TVSTTextType; var CellText: string);
var
  nodeData: PNodeData;

begin
  nodeData := Sender.GetNodeData(Node);
  case nodeData^.NodeType of
    ntCategory: CellText := nodeData^.LEDFunction.GetCategoryName;
    ntFunction: CellText := nodeData^.LEDFunction.GetDisplayName;
  end;
end;

end.

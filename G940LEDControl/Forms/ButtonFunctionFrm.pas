unit ButtonFunctionFrm;

interface
uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.Messages,

  VirtualTrees,

  LEDFunctionIntf,
  Profile;


const
  WM_STARTEDITING = WM_USER + 1;


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
    procedure vstFunctionsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure vstFunctionsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure vstStatesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstStatesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstStatesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vstStatesEditing(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
  private
    FButtonIndex: Integer;
    FProfile: TProfile;
  protected
    procedure WMStartEditing(var Msg: TMessage); message WM_STARTEDITING;
  protected
    procedure LoadFunctions;
    procedure SetFunction(AProvider: ILEDFunctionProvider; AFunction: ILEDFunction);

    procedure LoadStates(AFunction: ILEDMultiStateFunction);

    property ButtonIndex: Integer read FButtonIndex write FButtonIndex;
    property Profile: TProfile read FProfile write FProfile;
  public
    class function Execute(AProfile: TProfile; AButtonIndex: Integer): Boolean;
  end;


implementation
uses
  Generics.Collections,
  System.SysUtils,
  Winapi.Windows,

  ColourEditor,
  LEDFunctionRegistry,
  LEDStateIntf;


type
  TFunctionNodeType = (ntCategory, ntFunction);
  TFunctionNodeData = record
    NodeType: TFunctionNodeType;
    Provider: ILEDFunctionProvider;
    LEDFunction: ILEDFunction;
  end;

  PFunctionNodeData = ^TFunctionNodeData;


  TStateNodeData = record
    State: ILEDState;
  end;

  PStateNodeData = ^TStateNodeData;


const
  ColumnState = 0;
  ColumnColour = 1;


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
  vstFunctions.NodeDataSize := SizeOf(TFunctionNodeData);
  vstStates.NodeDataSize := SizeOf(TStateNodeData);

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
    nodeData: PFunctionNodeData;

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
  nodeData: PFunctionNodeData;
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


procedure TButtonFunctionForm.SetFunction(AProvider: ILEDFunctionProvider; AFunction: ILEDFunction);
var
  multiStateFunction: ILEDMultiStateFunction;

begin
  lblCategoryName.Caption := AFunction.GetCategoryName;
  lblFunctionName.Caption := AFunction.GetDisplayName;

  if Supports(AFunction, ILEDMultiStateFunction, multiStateFunction) then
  begin
    lblNoStates.Visible := False;
    lblHasStates.Visible := True;

    LoadStates(multiStateFunction);
    vstStates.Visible := True;
  end else
  begin
    lblNoStates.Visible := True;
    lblHasStates.Visible := False;

    vstStates.Visible := False;
    vstStates.Clear;
  end;
end;


procedure TButtonFunctionForm.LoadStates(AFunction: ILEDMultiStateFunction);
var
  node: PVirtualNode;
  nodeData: PStateNodeData;
  state: ILEDState;

begin
  vstStates.BeginUpdate;
  try
    vstStates.Clear;

    for state in AFunction do
    begin
      node := vstStates.AddChild(nil);
      nodeData := vstStates.GetNodeData(node);
      nodeData^.State := state;
    end;
  finally
    vstStates.EndUpdate;
  end;
end;


procedure TButtonFunctionForm.vstFunctionsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  nodeData: PFunctionNodeData;
  functionNode: PVirtualNode;

begin
  if Assigned(Node) then
  begin
    nodeData := Sender.GetNodeData(Node);

    case nodeData^.NodeType of
      ntCategory:
        begin
          { Select first child (function) node instead }
          functionNode := Sender.GetFirstChild(Node);
          if not Assigned(functionNode) then
            exit;

          Sender.FocusedNode := functionNode;
          Sender.Selected[functionNode] := True;
        end;

      ntFunction:
        SetFunction(nodeData^.Provider, nodeData^.LEDFunction);
    end;
  end;
end;


procedure TButtonFunctionForm.vstFunctionsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                                  TextType: TVSTTextType; var CellText: string);
var
  nodeData: PFunctionNodeData;

begin
  nodeData := Sender.GetNodeData(Node);

  case nodeData^.NodeType of
    ntCategory: CellText := nodeData^.LEDFunction.GetCategoryName;
    ntFunction: CellText := nodeData^.LEDFunction.GetDisplayName;
  end;
end;


procedure TButtonFunctionForm.vstFunctionsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas;
                                                    Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
  nodeData: PFunctionNodeData;

begin
  nodeData := Sender.GetNodeData(Node);

  if nodeData^.NodeType = ntCategory then
    TargetCanvas.Font.Style := [fsBold]
  else
    TargetCanvas.Font.Style := [];
end;


procedure TButtonFunctionForm.vstStatesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                               TextType: TVSTTextType; var CellText: string);
var
  nodeData: PStateNodeData;

begin
  nodeData := Sender.GetNodeData(Node);

  case Column of
    ColumnState:    CellText := nodeData^.State.GetDisplayName;
    ColumnColour:   CellText := 'Red';
  end;
end;


procedure TButtonFunctionForm.vstStatesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  if Assigned(Node) and not (tsIncrementalSearching in Sender.TreeStates) then
    PostMessage(Self.Handle, WM_STARTEDITING, WPARAM(Node), 0);
end;


procedure TButtonFunctionForm.vstStatesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
                                                    Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TVTColourEditor.Create;
end;


procedure TButtonFunctionForm.vstStatesEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := True;
end;

procedure TButtonFunctionForm.WMStartEditing(var Msg: TMessage);
var
  node: PVirtualNode;

begin
  node := Pointer(Msg.WParam);
  vstStates.EditNode(Node, 1);
end;

end.

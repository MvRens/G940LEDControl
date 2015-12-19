unit ButtonFunctionFrm;

interface
uses
  Generics.Collections,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.Messages,

  VirtualTrees,

  LEDColorIntf,
  LEDFunctionIntf,
  LEDStateIntf,
  Profile;


type
  TStateControlInfo = class;
  TStateControlInfoList = TObjectList<TStateControlInfo>;


  TButtonFunctionForm = class(TForm)
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    vstFunctions: TVirtualStringTree;
    pnlFunction: TPanel;
    pnlName: TPanel;
    lblFunctionName: TLabel;
    lblCategoryName: TLabel;
    lblHasStates: TLabel;
    lblNoStates: TLabel;
    sbStates: TScrollBox;
    pnlHeader: TPanel;
    bvlHeader: TBevel;
    lblButton: TLabel;
    lblCurrentAssignment: TLabel;
    lblCurrentFunction: TLabel;
    lblCurrentCategory: TLabel;
    bvlFooter: TBevel;
    pnlFunctions: TPanel;
    edtSearch: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstFunctionsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstFunctionsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure vstFunctionsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure vstFunctionsIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode; const SearchText: string; var Result: Integer);
    procedure btnOKClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure edtSearchEnter(Sender: TObject);
    procedure edtSearchExit(Sender: TObject);
  private
    FProfile: TProfile;
    FButtonIndex: Integer;
    FButton: TProfileButton;
    FCurrentProvider: ILEDFunctionProvider;
    FCurrentFunction: ILEDFunction;
    FSelectedProvider: ILEDFunctionProvider;
    FSelectedFunction: ILEDFunction;
    FStateControls: TStateControlInfoList;
  protected
    procedure Initialize(AProfile: TProfile; AButtonIndex: Integer);

    procedure LoadFunctions;
    procedure ApplyFilter(const AFilter: string);
    procedure SetFunction(AProvider: ILEDFunctionProvider; AFunction: ILEDFunction);

    procedure LoadStates(AProvider: ILEDFunctionProvider; AFunction: ILEDMultiStateFunction);

    property Button: TProfileButton read FButton;
    property CurrentProvider: ILEDFunctionProvider read FCurrentProvider;
    property CurrentFunction: ILEDFunction read FCurrentFunction;
    property SelectedProvider: ILEDFunctionProvider read FSelectedProvider;
    property SelectedFunction: ILEDFunction read FSelectedFunction;

    property Profile: TProfile read FProfile;
    property ButtonIndex: Integer read FButtonIndex;
  public
    class function Execute(AProfile: TProfile; AButtonIndex: Integer): Boolean;
  end;


  TStateControlInfo = class(TObject)
  private
    FState: ILEDState;
    FStateLabel: TLabel;
    FComboBox: TComboBox;
  public
    constructor Create(AState: ILEDState; AStateLabel: TLabel; AComboBox: TComboBox);
    destructor Destroy; override;

    property State: ILEDState read FState;
    property StateLabel: TLabel read FStateLabel;
    property ComboBox: TComboBox read FComboBox;
  end;


implementation
uses
  System.Math,
  System.StrUtils,
  System.SysUtils,
  Winapi.Windows,

  LEDFunctionRegistry,
  LEDResources;


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
    Color: TLEDColor;
  end;

  PStateNodeData = ^TStateNodeData;


const
  ColumnState = 0;
  ColumnColor = 1;


{$R *.dfm}


{ TButtonFunctionForm }
class function TButtonFunctionForm.Execute(AProfile: TProfile; AButtonIndex: Integer): Boolean;
begin
  with Self.Create(nil) do
  try
    Initialize(AProfile, AButtonIndex);
    Result := (ShowModal = mrOk);
  finally
    Free;
  end;
end;

procedure TButtonFunctionForm.FormCreate(Sender: TObject);
begin
  FStateControls := TStateControlInfoList.Create(True);

  vstFunctions.NodeDataSize := SizeOf(TFunctionNodeData);

  lblButton.Caption := '';
  lblCurrentCategory.Caption := '';
  lblCurrentFunction.Caption := '';
  lblCategoryName.Caption := '';
  lblFunctionName.Caption := '';
end;


procedure TButtonFunctionForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FStateControls);
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
  isCurrentProvider: Boolean;

begin
  vstFunctions.BeginUpdate;
  try
    vstFunctions.Clear;

    categoryNodes := TDictionary<string, PVirtualNode>.Create;
    try
      for provider in TLEDFunctionRegistry.Providers do
      begin
        isCurrentProvider := Assigned(CurrentProvider) and (provider.GetUID = CurrentProvider.GetUID);

        for ledFunction in provider do
        begin
          node := vstFunctions.AddChild(GetCategoryNode(provider, ledFunction));
          nodeData := vstFunctions.GetNodeData(node);

          nodeData^.NodeType := ntFunction;
          nodeData^.Provider := provider;
          nodeData^.LEDFunction := ledFunction;

          if isCurrentProvider and Assigned(CurrentFunction) and (ledFunction.GetUID = CurrentFunction.GetUID) then
            vstFunctions.Selected[node] := True;
        end;
      end;
    finally
      FreeAndNil(categoryNodes);
    end;
  finally
    vstFunctions.EndUpdate;
  end;
end;


procedure TButtonFunctionForm.ApplyFilter(const AFilter: string);
var
  hasFilter: Boolean;
  categoryNode: PVirtualNode;
  functionNode: PVirtualNode;
  hasVisibleChildren: Boolean;
  nodeData: PFunctionNodeData;

begin
  hasFilter := (Length(AFilter) > 0);

  vstFunctions.BeginUpdate;
  try
    categoryNode := vstFunctions.GetFirst;
    while Assigned(categoryNode) do
    begin
      hasVisibleChildren := False;

      functionNode := vstFunctions.GetFirstChild(categoryNode);
      while Assigned(functionNode) do
      begin
        nodeData := vstFunctions.GetNodeData(functionNode);
        if nodeData^.NodeType = ntFunction then
        begin
          if hasFilter and (not ContainsText(nodeData^.LEDFunction.GetDisplayName, AFilter)) then
            Exclude(functionNode^.States, vsVisible)
          else
            Include(functionNode^.States, vsVisible);
        end;

        if vsVisible in functionNode^.States then
          hasVisibleChildren := True;

        functionNode := vstFunctions.GetNextSibling(functionNode);
      end;

      if hasVisibleChildren then
        Include(categoryNode^.States, vsVisible)
      else
        Exclude(categoryNode^.States, vsVisible);

      categoryNode := vstFunctions.GetNextSibling(categoryNode);
    end;
  finally
    vstFunctions.EndUpdate;
  end;
end;


procedure TButtonFunctionForm.SetFunction(AProvider: ILEDFunctionProvider; AFunction: ILEDFunction);
var
  multiStateFunction: ILEDMultiStateFunction;

begin
  FSelectedProvider := AProvider;
  FSelectedFunction := AFunction;

  lblCategoryName.Caption := SelectedFunction.GetCategoryName;
  lblFunctionName.Caption := SelectedFunction.GetDisplayName;

  if Supports(SelectedFunction, ILEDMultiStateFunction, multiStateFunction) then
  begin
    lblNoStates.Visible := False;
    lblHasStates.Visible := True;

    LoadStates(AProvider, multiStateFunction);
    sbStates.Visible := True;
  end else
  begin
    lblNoStates.Visible := True;
    lblHasStates.Visible := False;

    sbStates.Visible := False;
    FStateControls.Clear;
  end;
end;


procedure TButtonFunctionForm.Initialize(AProfile: TProfile; AButtonIndex: Integer);
begin
  FProfile := AProfile;
  FButtonIndex := AButtonIndex;
  FButton := nil;
  FCurrentProvider := nil;
  FCurrentFunction := nil;

  lblButton.Caption := 'P' + IntToStr(Succ(ButtonIndex));

  if Profile.HasButton(ButtonIndex) then
  begin
    FButton := Profile.Buttons[ButtonIndex];
    FCurrentProvider := TLEDFunctionRegistry.Find(Button.ProviderUID);

    if Assigned(CurrentProvider) then
      FCurrentFunction := CurrentProvider.Find(Button.FunctionUID);
  end;

  LoadFunctions;

  if Assigned(CurrentFunction) then
  begin
    lblCurrentCategory.Caption := CurrentFunction.GetCategoryName + ': ';
    lblCurrentFunction.Caption := CurrentFunction.GetDisplayName;

    lblCurrentCategory.Left := lblCurrentFunction.Left - lblCurrentCategory.Width;

    SetFunction(CurrentProvider, CurrentFunction);
  end else
  begin
    lblCurrentCategory.Caption := '';
    lblCurrentFunction.Caption := 'Unassigned';
  end;
end;


procedure TButtonFunctionForm.LoadStates(AProvider: ILEDFunctionProvider; AFunction: ILEDMultiStateFunction);

  procedure FillColorComboBox(AComboBox: TComboBox; ASelectedColor: TLEDColor);
  var
    color: TLEDColor;
    itemIndex: Integer;

  begin
    AComboBox.Items.BeginUpdate;
    try
      AComboBox.Items.Clear;

      for color := Low(TLEDColor) to High(TLEDColor) do
      begin
        itemIndex := AComboBox.Items.AddObject(LEDColorDisplayName[color], TObject(color));

        if color = ASelectedColor then
          AComboBox.ItemIndex := itemIndex;
      end;
    finally
      AComboBox.Items.EndUpdate;
    end;
  end;


var
  state: ILEDState;
  stateLabel: TLabel;
  colorCombobox: TComboBox;
  comboBoxWidth: Integer;
  currentY: Integer;
  selectedColor: TLEDColor;
  isCurrent: Boolean;

begin
  FStateControls.Clear;

  currentY := 0;
  comboBoxWidth := sbStates.ClientWidth div 2;

  isCurrent := Assigned(CurrentProvider) and (AProvider.GetUID = CurrentProvider.GetUID) and
               Assigned(CurrentFunction) and (AFunction.GetUID = CurrentFunction.GetUID);

  for state in AFunction do
  begin
    stateLabel := TLabel.Create(nil);
    stateLabel.AutoSize := False;
    stateLabel.Caption := state.GetDisplayName;
    stateLabel.EllipsisPosition := epEndEllipsis;
    stateLabel.Left := 0;
    stateLabel.Top := currentY + 4;
    stateLabel.Width := comboBoxWidth - 8;
    stateLabel.Parent := sbStates;

    colorCombobox := TComboBox.Create(nil);
    colorCombobox.DropDownCount := Length(LEDColorDisplayName);
    colorCombobox.Style := csDropDownList;
    colorCombobox.Left := sbStates.ClientWidth - comboBoxWidth;
    colorCombobox.Top := currentY;
    colorCombobox.Width := comboBoxWidth;
    colorCombobox.Parent := sbStates;

    if (not isCurrent) or (not Button.GetStateColor(state.GetUID, selectedColor)) then
      selectedColor := state.GetDefaultColor;

    FillColorComboBox(colorComboBox, selectedColor);

    FStateControls.Add(TStateControlInfo.Create(state, stateLabel, colorCombobox));
    Inc(currentY, colorCombobox.Height + 8);
  end;
end;


procedure TButtonFunctionForm.btnOKClick(Sender: TObject);
var
  multiStateFunction: ILEDMultiStateFunction;
  stateControlInfo: TStateControlInfo;
  comboBox: TComboBox;
  color: TLEDColor;

begin
  if not Assigned(Button) then
    FButton := Profile.Buttons[ButtonIndex];

  Button.ProviderUID := SelectedProvider.GetUID;
  Button.FunctionUID := SelectedFunction.GetUID;

  Button.ClearStateColors;
  if Supports(SelectedFunction, ILEDMultiStateFunction, multiStateFunction) then
  begin
    for stateControlInfo in FStateControls do
    begin
      comboBox := stateControlInfo.ComboBox;
      if comboBox.ItemIndex > -1 then
      begin
        color := TLEDColor(comboBox.Items.Objects[comboBox.ItemIndex]);
        Button.SetStateColor(stateControlInfo.State.GetUID, color);
      end;
    end;
  end;

  ModalResult := mrOk;
end;


procedure TButtonFunctionForm.vstFunctionsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  nodeData: PFunctionNodeData;
  functionNode: PVirtualNode;

begin
  if Assigned(Node) then
  begin
    nodeData := Sender.GetNodeData(Node);

    if nodeData^.NodeType = ntCategory then
    begin
      { Get first child (function) node instead }
      functionNode := Sender.GetFirstChild(Node);
      if not Assigned(functionNode) then
        exit;

      nodeData := Sender.GetNodeData(functionNode);
    end;

    SetFunction(nodeData^.Provider, nodeData^.LEDFunction);
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


procedure TButtonFunctionForm.vstFunctionsIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
                                                            const SearchText: string; var Result: Integer);
var
  nodeData: PFunctionNodeData;
  displayName: string;

begin
  nodeData := Sender.GetNodeData(Node);

  if nodeData^.NodeType = ntFunction then
  begin
    displayName := nodeData^.LEDFunction.GetDisplayName;
    Result := StrLIComp(PChar(displayName), PChar(SearchText), Min(Length(displayName), Length(searchText)));
  end else
    Result := -1;
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


procedure TButtonFunctionForm.edtSearchChange(Sender: TObject);
begin
  if edtSearch.Tag = 1 then
    ApplyFilter('')
  else
    ApplyFilter(Trim(edtSearch.Text));
end;


procedure TButtonFunctionForm.edtSearchEnter(Sender: TObject);
begin
  if edtSearch.Tag = 1 then
  begin
    edtSearch.Text := '';
    edtSearch.Font.Color := clWindowText;
    edtSearch.Tag := 0;
  end;
end;


procedure TButtonFunctionForm.edtSearchExit(Sender: TObject);
begin
  if Length(Trim(edtSearch.Text)) = 0 then
  begin
    edtSearch.Tag := 1;
    edtSearch.Text := 'Search...';
    edtSearch.Font.Color := clGrayText;
  end else
    edtSearch.Tag := 0;
end;



{ TStateControlInfo }
constructor TStateControlInfo.Create(AState: ILEDState; AStateLabel: TLabel; AComboBox: TComboBox);
begin
  inherited Create;

  FState := AState;
  FStateLabel := AStateLabel;
  FComboBox := AComboBox;
end;


destructor TStateControlInfo.Destroy;
begin
  FreeAndNil(FComboBox);
  FreeAndNil(FStateLabel);

  inherited Destroy;
end;

end.

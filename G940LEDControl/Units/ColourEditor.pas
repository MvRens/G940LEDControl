unit ColourEditor;

interface
uses
  System.Types,
  System.Classes,
  Vcl.StdCtrls,
  Winapi.Messages,

  VirtualTrees;


type
  TVTColourEditor = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TComboBox;
    FTree: TBaseVirtualTree;
    FColumn: TColumnIndex;
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    { IVTEditLink }
    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;

    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;

    function GetBounds: TRect; stdcall;
    procedure SetBounds(R: TRect); stdcall;
  public
    destructor Destroy; override;
  end;

implementation
uses
  System.SysUtils,
  Winapi.Windows;


{ TVTColourEditor }
destructor TVTColourEditor.Destroy;
begin
  FreeAndNil(FEdit);

  inherited;
end;


function TVTColourEditor.BeginEdit: Boolean;
begin
  Result := True;
  FEdit.Show;
  FEdit.SetFocus;
end;


function TVTColourEditor.CancelEdit: Boolean;
begin
  Result := True;
  FEdit.Hide;
end;


function TVTColourEditor.EndEdit: Boolean;
begin
  Result := True;
  // TODO update node data
end;


function TVTColourEditor.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
begin
  Result := True;

  FTree := Tree;
//  FNode := Node;
  FColumn := Column;

  FreeAndNil(FEdit);

  FEdit := TComboBox.Create(nil);
  FEdit.Visible := False;
  FEdit.Parent := Tree;

//  FEdit.Text := Data.Value;
//  FEdit.Items.Add();

  FEdit.OnKeyDown := EditKeyDown;
end;


procedure TVTColourEditor.ProcessMessage(var Message: TMessage);
begin
  FEdit.WindowProc(Message);
end;


function TVTColourEditor.GetBounds: TRect;
begin
  Result := FEdit.BoundsRect;
end;


procedure TVTColourEditor.SetBounds(R: TRect);
var
  dummy: Integer;

begin
  (FTree as TVirtualStringTree).Header.Columns.GetColumnBounds(FColumn, dummy, R.Right);
  FEdit.BoundsRect := R;
end;


procedure TVTColourEditor.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        FTree.CancelEditNode;
        Key := 0;
      end;

    VK_RETURN:
      begin
        FTree.EndEditNode;
        Key := 0;
      end;

    VK_UP,
    VK_DOWN:
      if (Shift = []) and (not FEdit.DroppedDown) then
      begin
        PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
        Key := 0;
      end;
  end;
end;

end.

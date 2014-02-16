unit ButtonAssignmentFrm;

interface
uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls;


type
  TButtonAssignmentFrame = class(TFrame)
    btnConfiguration: TButton;
    lblFunction: TLabel;
    lblCategory: TLabel;

    procedure btnConfigurationClick(Sender: TObject);
  private
    FLEDIndex: Integer;
    FOnConfigurationClick: TNotifyEvent;

    function GetCategoryName: string;
    function GetFunctionName: string;
    procedure SetCategoryName(const Value: string);
    procedure SetFunctionName(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;

    property LEDIndex: Integer read FLEDIndex write FLEDIndex;
    property CategoryName: string read GetCategoryName write SetCategoryName;
    property FunctionName: string read GetFunctionName write SetFunctionName;

    property OnConfigurationClick: TNotifyEvent read FOnConfigurationClick write FOnConfigurationClick;
  end;


implementation
uses
  Graphics;


{$R *.dfm}


{ TButtonAssignmentFrame }
constructor TButtonAssignmentFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  lblCategory.Font.Color := clGrayText;

  SetCategoryName('');
  SetFunctionName('');
end;


function TButtonAssignmentFrame.GetCategoryName: string;
begin
  Result := lblCategory.Caption;
end;


function TButtonAssignmentFrame.GetFunctionName: string;
begin
  Result := lblFunction.Caption;
end;


procedure TButtonAssignmentFrame.SetCategoryName(const Value: string);
begin
  lblCategory.Caption := Value;
end;


procedure TButtonAssignmentFrame.SetFunctionName(const Value: string);
begin
  lblFunction.Caption := Value;
end;


procedure TButtonAssignmentFrame.btnConfigurationClick(Sender: TObject);
begin
  if Assigned(FOnConfigurationClick) then
    FOnConfigurationClick(Self);
end;

end.

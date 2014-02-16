object ButtonAssignmentFrame: TButtonAssignmentFrame
  Left = 0
  Top = 0
  Width = 261
  Height = 41
  TabOrder = 0
  DesignSize = (
    261
    41)
  object lblFunction: TLabel
    Left = 53
    Top = 6
    Width = 208
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '[runtime: function]'
    EllipsisPosition = epEndEllipsis
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblCategory: TLabel
    Left = 53
    Top = 22
    Width = 208
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '[runtime: category]'
    EllipsisPosition = epEndEllipsis
  end
  object btnConfiguration: TButton
    Left = 0
    Top = 0
    Width = 41
    Height = 41
    Caption = 'P&?'
    TabOrder = 0
    OnClick = btnConfigurationClick
  end
end

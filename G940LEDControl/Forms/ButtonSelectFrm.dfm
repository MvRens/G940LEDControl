object ButtonSelectForm: TButtonSelectForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Select joystick button'
  ClientHeight = 134
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    484
    134)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDevice: TLabel
    Left = 8
    Top = 11
    Width = 42
    Height = 13
    Caption = 'Joystick:'
  end
  object lblStatus: TLabel
    Left = 80
    Top = 48
    Width = 396
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '[runtime: acquired status]'
    ExplicitWidth = 296
  end
  object lblButton: TLabel
    Left = 8
    Top = 70
    Width = 36
    Height = 13
    Caption = 'Button:'
  end
  object cmbDevice: TComboBox
    Left = 80
    Top = 8
    Width = 396
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 20
    TabOrder = 0
    OnChange = cmbDeviceChange
  end
  object btnOK: TButton
    Left = 320
    Top = 101
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 401
    Top = 101
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtButton: TEdit
    Left = 80
    Top = 67
    Width = 396
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
end

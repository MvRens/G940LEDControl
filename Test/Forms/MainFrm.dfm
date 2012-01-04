object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 445
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btn1Red: TButton
    Left = 108
    Top = 136
    Width = 75
    Height = 25
    Caption = '1 - RED'
    TabOrder = 3
    OnClick = btn1RedClick
  end
  object btn1Green: TButton
    Left = 108
    Top = 167
    Width = 75
    Height = 25
    Caption = '1 - GREEN'
    TabOrder = 4
    OnClick = btn1GreenClick
  end
  object btnInitialize: TButton
    Left = 16
    Top = 12
    Width = 75
    Height = 25
    Caption = 'Initialize'
    TabOrder = 0
    OnClick = btnInitializeClick
  end
  object cmbDevice: TComboBox
    Left = 108
    Top = 14
    Width = 489
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object btnConnect: TButton
    Left = 108
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btnConnectClick
  end
  object btnSimConnect: TButton
    Left = 16
    Top = 248
    Width = 75
    Height = 25
    Caption = 'SimConnect'
    TabOrder = 5
    OnClick = btnSimConnectClick
  end
  object mmoLog: TMemo
    Left = 108
    Top = 248
    Width = 489
    Height = 157
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 8
  end
  object btnStartDispatch: TButton
    Left = 16
    Top = 279
    Width = 75
    Height = 25
    Caption = 'Start timer'
    TabOrder = 6
    OnClick = btnStartDispatchClick
  end
  object btnStopDispatch: TButton
    Left = 16
    Top = 310
    Width = 75
    Height = 25
    Caption = 'Stop timer'
    TabOrder = 7
    OnClick = btnStopDispatchClick
  end
  object tmrDispatch: TTimer
    Enabled = False
    OnTimer = tmrDispatchTimer
    Left = 44
    Top = 364
  end
end

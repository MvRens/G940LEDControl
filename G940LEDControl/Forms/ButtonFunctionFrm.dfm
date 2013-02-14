object ButtonFunctionForm: TButtonFunctionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Configure button'
  ClientHeight = 401
  ClientWidth = 692
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
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 360
    Width = 692
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      692
      41)
    object btnOK: TButton
      Left = 528
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 609
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object vstFunctions: TVirtualStringTree
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 257
    Height = 352
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 1
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = vstFunctionsGetText
    OnPaintText = vstFunctionsPaintText
    Columns = <
      item
        Position = 0
        Width = 253
        WideText = 'Available functions'
      end>
  end
  object pnlFunction: TPanel
    AlignWithMargins = True
    Left = 273
    Top = 8
    Width = 411
    Height = 352
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object vstStates: TVirtualStringTree
      Left = 0
      Top = 113
      Width = 411
      Height = 239
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      TabOrder = 0
      Columns = <
        item
          Position = 0
          Width = 207
          WideText = 'State'
        end
        item
          Position = 1
          Width = 200
          WideText = 'Color'
        end>
    end
    object pnlName: TPanel
      Left = 0
      Top = 0
      Width = 411
      Height = 113
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        411
        113)
      object lblFunctionName: TLabel
        Left = 0
        Top = 19
        Width = 405
        Height = 19
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'runtime: function'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 401
      end
      object lblCategoryName: TLabel
        Left = 0
        Top = 0
        Width = 405
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'runtime: category'
        ExplicitWidth = 401
      end
      object lblHasStates: TLabel
        Left = 0
        Top = 74
        Width = 401
        Height = 31
        AutoSize = False
        Caption = 
          'This function provides the following states. Each state can be c' +
          'ustomized by clicking on the state and changing the setting in t' +
          'he Color column.'
        WordWrap = True
      end
      object lblNoStates: TLabel
        Left = 0
        Top = 55
        Width = 195
        Height = 13
        Caption = 'This function has no configurable states.'
        Visible = False
      end
    end
  end
end

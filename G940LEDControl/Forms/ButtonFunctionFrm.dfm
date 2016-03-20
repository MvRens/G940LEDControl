object ButtonFunctionForm: TButtonFunctionForm
  Left = 0
  Top = 0
  ActiveControl = vstFunctions
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Configure button'
  ClientHeight = 561
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object bvlHeader: TBevel
    Left = 0
    Top = 50
    Width = 692
    Height = 2
    Align = alTop
    Shape = bsTopLine
    ExplicitTop = 41
  end
  object pnlButtons: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 518
    Width = 692
    Height = 43
    Margins.Left = 0
    Margins.Top = 8
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      692
      43)
    object bvlFooter: TBevel
      Left = 0
      Top = 0
      Width = 692
      Height = 8
      Align = alTop
      Shape = bsTopLine
    end
    object btnOK: TButton
      Left = 528
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 609
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlFunction: TPanel
    AlignWithMargins = True
    Left = 273
    Top = 60
    Width = 411
    Height = 450
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object pnlName: TPanel
      Left = 0
      Top = 0
      Width = 411
      Height = 97
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        411
        97)
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
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ExplicitWidth = 401
      end
      object lblHasStates: TLabel
        Left = 0
        Top = 47
        Width = 401
        Height = 31
        AutoSize = False
        Caption = 
          'This function provides the following states. Each state can be c' +
          'ustomized by changing the color below.'
        WordWrap = True
      end
      object lblNoStates: TLabel
        Left = 0
        Top = 47
        Width = 195
        Height = 13
        Caption = 'This function has no configurable states.'
        Visible = False
      end
    end
    object sbStates: TScrollBox
      Left = 0
      Top = 97
      Width = 411
      Height = 353
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 1
    end
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      692
      50)
    object lblButton: TLabel
      Left = 8
      Top = 13
      Width = 24
      Height = 23
      Caption = 'P1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblCurrentAssignment: TLabel
      Left = 586
      Top = 8
      Width = 98
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Current assignment:'
    end
    object lblCurrentFunction: TLabel
      Left = 587
      Top = 27
      Width = 97
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'runtime: function'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblCurrentCategory: TLabel
      Left = 478
      Top = 27
      Width = 86
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'runtime: category'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlFunctions: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 60
    Width = 257
    Height = 450
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 3
    object vstFunctions: TVirtualStringTree
      Left = 0
      Top = 29
      Width = 257
      Height = 421
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      IncrementalSearch = isAll
      TabOrder = 1
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toWheelPanning, toEditOnClick]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnFocusChanged = vstFunctionsFocusChanged
      OnGetText = vstFunctionsGetText
      OnPaintText = vstFunctionsPaintText
      OnIncrementalSearch = vstFunctionsIncrementalSearch
      Columns = <
        item
          Position = 0
          Width = 253
          WideText = 'Available functions'
        end>
    end
    object edtSearch: TEdit
      Tag = 1
      AlignWithMargins = True
      Left = 0
      Top = 0
      Width = 257
      Height = 21
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'Search (Ctrl+F)...'
      OnChange = edtSearchChange
      OnEnter = edtSearchEnter
      OnExit = edtSearchExit
      OnKeyDown = edtSearchKeyDown
      OnKeyUp = edtSearchKeyUp
    end
  end
  object ActionList: TActionList
    Left = 40
    Top = 136
    object actSearch: TAction
      Caption = 'actSearch'
      ShortCut = 16454
      OnExecute = actSearchExecute
    end
  end
end

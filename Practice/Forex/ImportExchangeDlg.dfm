object ImportExchange: TImportExchange
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'ImportExchange'
  ClientHeight = 584
  ClientWidth = 990
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 600
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pFileinput: TPanel
    Left = 0
    Top = 0
    Width = 990
    Height = 78
    Align = alTop
    TabOrder = 0
    DesignSize = (
      990
      78)
    object Label1: TLabel
      Left = 15
      Top = 14
      Width = 51
      Height = 13
      Caption = 'Import File'
    end
    object Label9: TLabel
      Left = 15
      Top = 41
      Width = 43
      Height = 13
      Caption = 'Skip lines'
      FocusControl = SkipLine
    end
    object Label12: TLabel
      Left = 752
      Top = 41
      Width = 41
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Delimiter'
      FocusControl = cbDelimiter
    end
    object BTNBrowse: TButton
      Left = 904
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Bro&wse'
      TabOrder = 0
      OnClick = BTNBrowseClick
    end
    object EPath: TEdit
      Left = 88
      Top = 11
      Width = 803
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 4
    end
    object chFirstline: TCheckBox
      Left = 184
      Top = 40
      Width = 161
      Height = 17
      Caption = 'Next line is &header line'
      TabOrder = 2
      OnClick = chFirstlineClick
    end
    object SkipLine: TRzSpinEdit
      Left = 88
      Top = 38
      Width = 65
      Height = 21
      AllowKeyEdit = True
      CheckRange = True
      Max = 99.000000000000000000
      TabOrder = 1
      OnChange = SkipLineChange
    end
    object cbDelimiter: TComboBox
      Left = 816
      Top = 38
      Width = 75
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = ','
      OnChange = cbDelimiterChange
      Items.Strings = (
        ','
        ';'
        '<tab>')
    end
  end
  object pBtn: TPanel
    Left = 0
    Top = 543
    Width = 990
    Height = 41
    Align = alBottom
    TabOrder = 4
    DesignSize = (
      990
      41)
    object BtnCancel: TButton
      Left = 904
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 816
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object pOut: TPanel
    Left = 0
    Top = 403
    Width = 990
    Height = 140
    Align = alClient
    Caption = 'pOut'
    TabOrder = 3
    object vsOut: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 988
      Height = 138
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Height = 20
      Header.MainColumn = -1
      Header.Options = [hoColumnResize, hoDrag, hoVisible]
      Header.ParentFont = True
      ParentBackground = False
      TabOrder = 0
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnBeforeCellPaint = vsOutBeforeCellPaint
      OnChange = vsOutChange
      OnGetText = vsOutGetText
      OnPaintText = vsOutPaintText
      OnHeaderClick = vsOutHeaderClick
      Columns = <>
      WideDefaultText = ''
    end
  end
  object PFormat: TPanel
    Left = 0
    Top = 268
    Width = 990
    Height = 135
    Align = alTop
    Caption = 'PFormat'
    TabOrder = 2
    object PCFormat: TPageControl
      Left = 1
      Top = 1
      Width = 988
      Height = 133
      ActivePage = TSDate
      Align = alClient
      TabOrder = 0
      OnChange = PCFormatChange
      object TSDate: TTabSheet
        Caption = '&Date'
        object Label2: TLabel
          Left = 15
          Top = 20
          Width = 34
          Height = 13
          Caption = 'Format'
        end
        object Label4: TLabel
          Left = 15
          Top = 47
          Width = 35
          Height = 13
          Caption = 'Column'
        end
        object EDate: TEdit
          Left = 83
          Top = 18
          Width = 97
          Height = 21
          ReadOnly = True
          TabOrder = 0
          Text = 'dd/mm/yyyy'
        end
        object cbDate: TComboBox
          Left = 83
          Top = 45
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = cbDateChange
        end
      end
    end
  end
  object pFile: TPanel
    Left = 0
    Top = 78
    Width = 990
    Height = 190
    Align = alTop
    Color = clWindow
    ParentBackground = False
    TabOrder = 1
    object lbFile: TLabel
      Left = 1
      Top = 1
      Width = 988
      Height = 13
      Align = alTop
      Constraints.MaxHeight = 100
      WordWrap = True
      ExplicitWidth = 3
    end
    object vsFile: TVirtualStringTree
      Left = 1
      Top = 14
      Width = 988
      Height = 175
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Height = 20
      Header.MainColumn = -1
      Header.Options = [hoAutoResize, hoColumnResize, hoDblClickResize, hoVisible]
      Header.ParentFont = True
      ParentBackground = False
      TabOrder = 0
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      TreeOptions.StringOptions = []
      OnBeforeCellPaint = vsFileBeforeCellPaint
      OnChange = vsFileChange
      OnGetText = vsFileGetText
      OnPaintText = vsFilePaintText
      OnHeaderClick = vsFileHeaderClick
      Columns = <>
      WideDefaultText = ''
    end
  end
  object OpenDlg: TOpenDialog
    Filter = 'CSVFile|*.csv'
    Left = 512
    Top = 8
  end
  object ReloadTimer: TTimer
    Enabled = False
    OnTimer = ReloadTimerTimer
    Left = 160
    Top = 32
  end
end

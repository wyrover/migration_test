object RzLabelEditDlg: TRzLabelEditDlg
  Left = 186
  Top = 115
  BorderStyle = bsDialog
  Caption = ' - Label Editor'
  ClientHeight = 295
  ClientWidth = 539
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TRzLabel
    Left = 8
    Top = 13
    Width = 44
    Height = 13
    Caption = 'Caption'
    ParentColor = False
  end
  object GrpPreview: TRzGroupBox
    Left = 8
    Top = 44
    Width = 197
    Height = 209
    Caption = 'Preview'
    TabOrder = 1
    object LblPreview: TRzLabel
      Left = 3
      Top = 16
      Width = 191
      Height = 189
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      BevelWidth = 0
    end
  end
  object BtnOK: TRzButton
    Left = 368
    Top = 260
    Default = True
    ModalResult = 1
    Caption = 'OK'
    HotTrack = True
    TabOrder = 2
  end
  object BtnCancel: TRzButton
    Left = 453
    Top = 260
    ModalResult = 2
    Caption = 'Cancel'
    HotTrack = True
    TabOrder = 3
  end
  object EdtCaption: TRzEdit
    Left = 60
    Top = 8
    Width = 145
    Height = 21
    FrameVisible = True
    TabOrder = 0
    OnChange = EdtCaptionChange
  end
  object PgcFormat: TRzPageControl
    Left = 216
    Top = 8
    Width = 313
    Height = 245
    ActivePage = TabTextStyle
    ParentColor = False
    TabIndex = 0
    TabOrder = 4
    OnChanging = PgcFormatChanging
    FixedDimension = 19
    object TabTextStyle: TRzTabSheet
      Caption = 'Text Style'
      object Label2: TRzLabel
        Left = 8
        Top = 13
        Width = 24
        Height = 13
        Caption = 'Font'
        ParentColor = False
      end
      object Label3: TRzLabel
        Left = 8
        Top = 96
        Width = 31
        Height = 13
        Caption = 'Color'
        ParentColor = False
      end
      object Label6: TRzLabel
        Left = 8
        Top = 53
        Width = 24
        Height = 13
        Caption = 'Size'
        ParentColor = False
      end
      object TrkPointSize: TRzTrackBar
        Left = 44
        Top = 37
        Width = 257
        Height = 40
        Max = 18
        Position = 0
        TickStyle = tkOwnerDraw
        TrackOffset = 22
        OnChange = TrkPointSizeChange
        OnDrawTick = TrkPointSizeDrawTick
        TabOrder = 1
      end
      object GrpFontStyle: TRzGroupBox
        Left = 148
        Top = 87
        Width = 153
        Height = 61
        Caption = 'Font Style'
        ParentColor = True
        TabOrder = 3
        object ChkBold: TRzCheckBox
          Left = 9
          Top = 16
          Width = 56
          Height = 17
          Caption = 'Bold'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = [fsBold]
          HotTrack = True
          ParentFont = False
          State = cbUnchecked
          TabOrder = 0
          OnClick = ChkBoldClick
        end
        object ChkItalic: TRzCheckBox
          Left = 9
          Top = 36
          Width = 68
          Height = 17
          Caption = 'Italic'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = [fsItalic]
          HotTrack = True
          ParentFont = False
          State = cbUnchecked
          TabOrder = 1
          OnClick = ChkItalicClick
        end
        object ChkStrikeout: TRzCheckBox
          Left = 69
          Top = 16
          Width = 76
          Height = 17
          Caption = 'Strikeout'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = [fsStrikeOut]
          HotTrack = True
          ParentFont = False
          State = cbUnchecked
          TabOrder = 2
          OnClick = ChkStrikeoutClick
        end
        object ChkUnderline: TRzCheckBox
          Left = 69
          Top = 36
          Width = 76
          Height = 17
          Caption = 'Underline'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = [fsUnderline]
          HotTrack = True
          ParentFont = False
          State = cbUnchecked
          TabOrder = 3
          OnClick = ChkUnderlineClick
        end
      end
      object CbxFonts: TRzFontComboBox
        Left = 44
        Top = 9
        Width = 257
        Height = 22
        PreviewText = 'AaBbYyZz'
        ShowStyle = ssFontPreview
        Ctl3D = False
        FrameVisible = True
        ItemHeight = 16
        ParentCtl3D = False
        TabOrder = 0
        OnChange = CbxFontsChange
      end
      object GrpTextStyle: TRzRadioGroup
        Left = 8
        Top = 156
        Width = 293
        Height = 57
        Caption = 'Text Style'
        Columns = 4
        ItemHotTrack = True
        ItemIndex = 0
        Items.Strings = (
          'Normal'
          'Raised'
          'Recessed'
          'Shadow')
        ParentColor = True
        TabOrder = 4
        VerticalSpacing = 0
        OnClick = GrpTextStyleClick
        object ChkLightStyle: TRzCheckBox
          Left = 8
          Top = 36
          Width = 83
          Height = 17
          Caption = 'Light Style'
          HotTrack = True
          State = cbUnchecked
          TabOrder = 4
          OnClick = ChkLightStyleClick
        end
      end
      object EdtFontColor: TRzColorEdit
        Left = 44
        Top = 92
        Width = 97
        Height = 21
        CustomColors = RzCustomColors1
        DefaultColor = clWindowText
        SelectedColor = clWindowText
        ShowCustomColor = True
        ShowDefaultColor = True
        ShowSystemColors = True
        FlatButtons = True
        FrameVisible = True
        TabOrder = 2
        OnChange = EdtFontColorChange
      end
    end
    object TabOptions: TRzTabSheet
      Caption = 'Options'
      object GrpShadow: TRzGroupBox
        Left = 8
        Top = 8
        Width = 293
        Height = 101
        Caption = 'Options'
        ParentColor = True
        TabOrder = 0
        object Label4: TRzLabel
          Left = 8
          Top = 58
          Width = 80
          Height = 13
          Caption = 'Shadow Color'
          ParentColor = False
        end
        object Label5: TRzLabel
          Left = 160
          Top = 16
          Width = 83
          Height = 13
          Alignment = taCenter
          Caption = 'Shadow Depth'
          ParentColor = False
          WordWrap = True
        end
        object Label7: TRzLabel
          Left = 8
          Top = 16
          Width = 84
          Height = 13
          Caption = 'Highlight Color'
          ParentColor = False
        end
        object LblShadowDepth: TRzLabel
          Left = 212
          Top = 76
          Width = 14
          Height = 13
          Alignment = taCenter
          Caption = '00'
          ParentColor = False
        end
        object TrkShadow: TRzTrackBar
          Left = 160
          Top = 44
          Width = 125
          Height = 29
          Max = 20
          Position = 0
          ShowTicks = False
          TrackOffset = 10
          OnChange = TrkShadowChange
          Enabled = False
          TabOrder = 2
        end
        object EdtHighlightColor: TRzColorEdit
          Left = 8
          Top = 32
          Width = 121
          Height = 21
          CustomColors = RzCustomColors1
          DefaultColor = clBtnHighlight
          SelectedColor = clBtnHighlight
          ShowCustomColor = True
          ShowDefaultColor = True
          ShowSystemColors = True
          FlatButtons = True
          FrameVisible = True
          TabOrder = 0
          OnChange = EdtHighlightColorChange
        end
        object EdtShadowColor: TRzColorEdit
          Left = 8
          Top = 72
          Width = 121
          Height = 21
          CustomColors = RzCustomColors1
          DefaultColor = clBtnShadow
          SelectedColor = clBtnShadow
          ShowCustomColor = True
          ShowDefaultColor = True
          ShowSystemColors = True
          FlatButtons = True
          FrameVisible = True
          TabOrder = 1
          OnChange = EdtShadowColorChange
        end
      end
      object GrpRotation: TRzGroupBox
        Left = 8
        Top = 116
        Width = 293
        Height = 89
        Caption = 'Rotation'
        ParentColor = True
        TabOrder = 1
        object LblAngle: TRzLabel
          Left = 232
          Top = 61
          Width = 25
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0�'
          ParentColor = False
        end
        object BtnNone: TSpeedButton
          Left = 131
          Top = 12
          Width = 30
          Height = 23
          Hint = 'No Rotation'
          GroupIndex = 1
          Down = True
          Glyph.Data = {
            4E010000424D4E01000000000000760000002800000012000000120000000100
            040000000000D800000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7777770000007777777777777777770000007777777777777777770000007777
            7777777777777700000077777777777777777700000077777777777777777700
            0000844447444448784448000000447447447744744744000000447447447744
            7447770000007444474477447447770000004774474477447447440000008444
            8744444878444800000077777744777777777700000077777744777777777700
            0000777777777777777777000000777777777777777777000000777777777777
            777777000000777777777777777777000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = BtnRotationClick
        end
        object BtnFlat: TSpeedButton
          Tag = 1
          Left = 161
          Top = 12
          Width = 30
          Height = 23
          Hint = 'Flat Rotation'
          GroupIndex = 1
          Glyph.Data = {
            4E010000424D4E01000000000000760000002800000012000000120000000100
            040000000000D800000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7777770000007774447777777777770000007784844777777777770000007484
            7844777777777700000084784444777777777700000074484477447777777700
            0000784447744447777777000000777777448744777777000000777774487744
            7777770000007777444774487777770000007774484444474447770000007744
            8774487444447700000077787777774487748700000077777777774477747700
            0000777777777744777777000000777777777774447777000000777777777777
            877777000000777777777777777777000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = BtnRotationClick
        end
        object BtnCurve: TSpeedButton
          Tag = 2
          Left = 191
          Top = 12
          Width = 30
          Height = 23
          Hint = 'Curve Rotation'
          GroupIndex = 1
          Glyph.Data = {
            4E010000424D4E01000000000000760000002800000012000000120000000100
            040000000000D800000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7777770000007777777777777777770000007777777777777777770000007787
            7777777777777700000074447777777777448700000084874477777774487700
            0000747844777777847777000000474447444447848774000000478447447744
            7448440000007444774477447744470000007777774477447777770000007777
            7744774477777700000077777744444777777700000077777744777777777700
            0000777777447777777777000000777777777777777777000000777777777777
            777777000000777777777777777777000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = BtnRotationClick
        end
        object TrkAngle: TRzTrackBar
          Left = 8
          Top = 44
          Width = 217
          Max = 360
          Position = 0
          TickStyle = tkOwnerDraw
          OnChange = TrkAngleChange
          OnDrawTick = TrkAngleDrawTick
          TabOrder = 1
        end
        object Chk15Degrees: TRzCheckBox
          Left = 9
          Top = 16
          Width = 112
          Height = 17
          Caption = 'Restrict Angle'
          HotTrack = True
          State = cbUnchecked
          TabOrder = 0
          OnClick = Chk15DegreesClick
        end
        object OptUpperLeft: TRzRadioButton
          Left = 234
          Top = 10
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = OptCenterPointClick
        end
        object OptUpperCenter: TRzRadioButton
          Tag = 1
          Left = 250
          Top = 10
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnClick = OptCenterPointClick
        end
        object OptUpperRight: TRzRadioButton
          Tag = 2
          Left = 266
          Top = 10
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnClick = OptCenterPointClick
        end
        object OptLeftCenter: TRzRadioButton
          Tag = 3
          Left = 234
          Top = 25
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
          OnClick = OptCenterPointClick
        end
        object OptCenter: TRzRadioButton
          Tag = 4
          Left = 250
          Top = 25
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          Checked = True
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          TabStop = True
          OnClick = OptCenterPointClick
        end
        object OptRightCenter: TRzRadioButton
          Tag = 5
          Left = 266
          Top = 25
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
          OnClick = OptCenterPointClick
        end
        object OptLowerLeft: TRzRadioButton
          Tag = 6
          Left = 234
          Top = 40
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 8
          OnClick = OptCenterPointClick
        end
        object OptLowerCenter: TRzRadioButton
          Tag = 7
          Left = 250
          Top = 40
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 9
          OnClick = OptCenterPointClick
        end
        object OptLowerRight: TRzRadioButton
          Tag = 8
          Left = 266
          Top = 40
          Width = 17
          Height = 17
          Hint = 'Set Center Point'
          HotTrack = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 10
          OnClick = OptCenterPointClick
        end
      end
    end
  end
  object RzRegIniFile1: TRzRegIniFile
    PathType = ptRegistry
    Left = 12
    Top = 256
  end
  object RzCustomColors1: TRzCustomColors
    Colors.Strings = (
      'ColorA=FFFFFF'
      'ColorB=FFFFFF'
      'ColorC=FFFFFF'
      'ColorD=FFFFFF'
      'ColorE=FFFFFF'
      'ColorF=FFFFFF'
      'ColorG=FFFFFF'
      'ColorH=FFFFFF'
      'ColorI=FFFFFF'
      'ColorJ=FFFFFF'
      'ColorK=FFFFFF'
      'ColorL=FFFFFF'
      'ColorM=FFFFFF'
      'ColorN=FFFFFF'
      'ColorO=FFFFFF'
      'ColorP=FFFFFF')
    RegIniFile = RzRegIniFile1
    Left = 48
    Top = 256
  end
end

object WPManageHeaderFooter: TWPManageHeaderFooter
  Left = 79
  Top = 135
  BorderStyle = bsDialog
  Caption = 'Manage Header&Footer'
  ClientHeight = 250
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object PageLayoutMode: TSpeedButton
    Left = 235
    Top = 9
    Width = 42
    Height = 54
    Hint = 'Edit in Page Layout Mode'
    GroupIndex = 10
    Flat = True
    Glyph.Data = {
      96030000424D9603000000000000760000002800000020000000320000000100
      0400000000002003000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDD7777777777777777777777777777DDD00000000000
      000000000000000007DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FCCCCCCCCC
      CCCCCCCCCCCCCCCF07DDD0FCFFFFFFFFFFFFFFFFFFFFFFCF07DDD0FCFFFFFFFF
      FFFFFFFFFFFFFFCF07DDD0FCFFFFFFFFFFFFFFFFFFFFFFCF07DDD0FCFFFFFFFF
      FFFFFFFFFFFFFFCF07DDD0FCCCCCCCCCCCCCCCCCCCCCCCCF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FCCCCCCCCCCCCCCCCCCCCCCCCF07DDD0FCFFFFFFFF
      FFFFFFFFFFFFFFCF07DDD0FCFFFFFFFFFFFFFFFFFFFFFFCF07DDD0FCFFFFFFFF
      FFFFFFFFFFFFFFCF07DDD0FCFFFFFFFFFFFFFFFFFFFFFFCF07DDD0FCFFFFFFFF
      FFFFFFFFFFFFFFCF07DDD0FCCCCCCCCCCCCCCCCCCCCCCCCF07DDD0FFFFFFFFFF
      FFFFFFFFFFFFFFFF07DDD0FFFFFFFFFFFFFFFFFFFFFFFFFF07DDD00000000000
      00000000000000000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
    OnClick = PageLayoutModeClick
  end
  object NormalMode: TSpeedButton
    Left = 278
    Top = 9
    Width = 42
    Height = 54
    Hint = 'Edit in Normal Mode'
    GroupIndex = 10
    Down = True
    Flat = True
    Glyph.Data = {
      96030000424D9603000000000000760000002800000020000000320000000100
      0400000000002003000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000FFFFF0000000000
      00000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000FFFFFFF0000000000
      000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000FFFFF0000000000
      00000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000FFFFF0000000000
      00000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000FFFFFFFF0000000000
      00000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000FFFFFFF0000000000
      000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000FF0000000000
      00000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
    OnClick = PageLayoutModeClick
  end
  object OptionsBut: TButton
    Left = 216
    Top = 148
    Width = 120
    Height = 25
    Caption = 'Options'
    TabOrder = 0
    OnClick = OptionsButClick
  end
  object CloseButton: TButton
    Left = 216
    Top = 208
    Width = 120
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = CloseButtonClick
  end
  object AllHeaderFooter: TListBox
    Left = 8
    Top = 8
    Width = 201
    Height = 225
    ItemHeight = 16
    PopupMenu = SaveLoadHeaderOrFooter
    TabOrder = 2
    OnClick = EdHeaderClick
    OnMouseDown = AllHeaderFooterMouseDown
  end
  object AddHeader: TButton
    Left = 216
    Top = 84
    Width = 120
    Height = 25
    Caption = 'Add Header'
    TabOrder = 3
    OnClick = AddHeaderClick
  end
  object AddFooter: TButton
    Left = 216
    Top = 116
    Width = 120
    Height = 25
    Caption = 'Add Footer'
    TabOrder = 4
    OnClick = AddHeaderClick
  end
  object GotoBody: TButton
    Left = 216
    Top = 178
    Width = 120
    Height = 25
    Caption = 'Goto Body'
    TabOrder = 5
    OnClick = ShowBodyClick
  end
  object PopupMenu1: TPopupMenu
    Left = 136
    Top = 23
  end
  object SaveLoadHeaderOrFooter: TPopupMenu
    Left = 168
    Top = 24
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = DeleteTextClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object LoadText1: TMenuItem
      Caption = 'Load Text'
      OnClick = LoadText1Click
    end
    object SaveText1: TMenuItem
      Caption = 'Save Text'
      OnClick = SaveText1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Copy: TMenuItem
      Caption = 'Copy Text'
      OnClick = CopyClick
    end
    object InsertText1: TMenuItem
      Caption = 'Replace with copied Text'
      Enabled = False
      OnClick = InsertText1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 167
    Top = 56
  end
  object SaveDialog1: TSaveDialog
    Left = 142
    Top = 54
  end
end

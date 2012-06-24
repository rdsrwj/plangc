object CreateRoomForm: TCreateRoomForm
  Left = 247
  Top = 245
  BorderStyle = bsDialog
  Caption = 'Room creation'
  ClientHeight = 165
  ClientWidth = 315
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  PixelsPerInch = 96
  TextHeight = 13
  object LblRoomName: TsLabel
    Left = 5
    Top = 5
    Width = 60
    Height = 13
    Caption = 'Room name:'
    ParentFont = False
    OnMouseDown = FormMouseDown
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object LblGameName: TsLabel
    Left = 5
    Top = 45
    Width = 60
    Height = 13
    Caption = 'Game name:'
    ParentFont = False
    OnMouseDown = FormMouseDown
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object LblRoomChannel: TsLabel
    Left = 5
    Top = 88
    Width = 72
    Height = 13
    Caption = 'Room channel:'
    ParentFont = False
    OnMouseDown = FormMouseDown
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object EdRoomName: TsEdit
    Left = 5
    Top = 20
    Width = 212
    Height = 21
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    SkinData.SkinSection = 'EDIT'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'MS Sans Serif'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
  end
  object CbGameName: TsComboBox
    Left = 5
    Top = 60
    Width = 212
    Height = 21
    Alignment = taLeftJustify
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'MS Sans Serif'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'COMBOBOX'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 15
    ItemIndex = -1
    ParentFont = False
    TabOrder = 1
    OnKeyPress = CbGameNameKeyPress
  end
  object BtnOK: TsButton
    Left = 230
    Top = 20
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = BtnOKClick
    SkinData.SkinSection = 'BUTTON'
  end
  object BtnCancel: TsButton
    Left = 230
    Top = 50
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtnCancelClick
    SkinData.SkinSection = 'BUTTON'
  end
  object EdRoomChannel: TsEdit
    Left = 5
    Top = 104
    Width = 212
    Height = 21
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnKeyPress = EdRoomChannelKeyPress
    SkinData.SkinSection = 'EDIT'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'MS Sans Serif'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
  end
end

object DetailedErrorForm: TDetailedErrorForm
  Left = 460
  Top = 243
  BorderStyle = bsDialog
  Caption = 'Error info'
  ClientHeight = 580
  ClientWidth = 614
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
  object Memo1: TsMemo
    Left = 5
    Top = 5
    Width = 604
    Height = 540
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'MS Sans Serif'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'EDIT'
  end
  object BtnExit: TsButton
    Left = 269
    Top = 550
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = BtnExitClick
    SkinData.SkinSection = 'BUTTON'
  end
end

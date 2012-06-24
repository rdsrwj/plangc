object OVPNInitForm: TOVPNInitForm
  Left = 725
  Top = 643
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsToolWindow
  Caption = 'Initialization of OpenVPN'
  ClientHeight = 57
  ClientWidth = 299
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LblInit: TsLabel
    Left = 5
    Top = 15
    Width = 66
    Height = 13
    Caption = 'Please, wait...'
    ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object sProgressBar1: TsProgressBar
    Left = 5
    Top = 35
    Width = 286
    Height = 13
    Max = 10
    Smooth = True
    TabOrder = 0
    SkinData.SkinSection = 'GAUGE'
  end
  object Timer1: TTimer
    Interval = 200
    OnTimer = Timer1Timer
    Left = 23
    Top = 8
  end
end

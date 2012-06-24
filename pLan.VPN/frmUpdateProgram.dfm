object UpdateForm: TUpdateForm
  Left = 473
  Top = 378
  BorderStyle = bsToolWindow
  Caption = 'Checking for updates'
  ClientHeight = 26
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 13
    Width = 332
    Height = 13
    TabOrder = 0
  end
  object HTTPGet1: THTTPGet
    AcceptTypes = '*/*'
    Agent = 'UtilMind HTTPGet'
    BinaryData = False
    UseCache = False
    WaitThread = False
    OnProgress = HTTPGet1Progress
    OnDoneFile = HTTPGet1DoneFile
    OnDoneString = HTTPGet1DoneString
    OnError = HTTPGet1Error
    Left = 44
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 80
  end
end

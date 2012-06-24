object FileOpenForm: TFileOpenForm
  Left = 646
  Top = 339
  BorderStyle = bsDialog
  Caption = 'Creating shortcut'
  ClientHeight = 237
  ClientWidth = 380
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
  object LblCaption: TsLabel
    Left = 8
    Top = 8
    Width = 39
    Height = 13
    Caption = 'Caption:'
    ParentFont = False
    OnMouseDown = FormMouseDown
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object LblFileName: TsLabel
    Left = 8
    Top = 33
    Width = 56
    Height = 13
    Caption = 'Executable:'
    ParentFont = False
    OnMouseDown = FormMouseDown
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object Image: TImage
    Left = 20
    Top = 60
    Width = 32
    Height = 32
    Proportional = True
    Stretch = True
    OnMouseDown = FormMouseDown
  end
  object EdFile: TsEdit
    Left = 80
    Top = 30
    Width = 256
    Height = 21
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
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
  object Button1: TsButton
    Left = 340
    Top = 28
    Width = 26
    Height = 25
    Caption = '...'
    TabOrder = 4
    OnClick = Button1Click
    SkinData.SkinSection = 'BUTTON'
  end
  object BtnOK: TsButton
    Left = 225
    Top = 205
    Width = 66
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtnOKClick
    SkinData.SkinSection = 'BUTTON'
  end
  object BtnCancel: TsButton
    Left = 300
    Top = 205
    Width = 66
    Height = 25
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = BtnCancelClick
    SkinData.SkinSection = 'BUTTON'
  end
  object ChkCompatibility: TsCheckBox
    Left = 80
    Top = 180
    Width = 197
    Height = 19
    Caption = 'Run program with compatibility mode'
    Checked = True
    State = cbChecked
    TabOrder = 2
    SkinData.SkinSection = 'CHECKBOX'
    ImgChecked = 0
    ImgUnchecked = 0
  end
  object sGroupBox1: TsGroupBox
    Left = 80
    Top = 55
    Width = 291
    Height = 121
    Caption = 'ForceBindIP'
    TabOrder = 3
    OnMouseDown = FormMouseDown
    SkinData.SkinSection = 'GROUPBOX'
    object ChkInjectIntoProcess: TsCheckBox
      Left = 10
      Top = 45
      Width = 111
      Height = 19
      Caption = 'Inject into process'
      TabOrder = 3
      OnClick = ChkInjectIntoProcessClick
      SkinData.SkinSection = 'CHECKBOX'
      ImgChecked = 0
      ImgUnchecked = 0
    end
    object EdProcessToInject: TsEdit
      Left = 10
      Top = 70
      Width = 241
      Height = 21
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
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
    object ChkWaitAWhile: TsCheckBox
      Left = 10
      Top = 95
      Width = 207
      Height = 19
      Caption = 'Wait a while before injecting into game'
      TabOrder = 0
      SkinData.SkinSection = 'CHECKBOX'
      ImgChecked = 0
      ImgUnchecked = 0
    end
    object Button2: TsButton
      Left = 255
      Top = 67
      Width = 26
      Height = 25
      Caption = '...'
      TabOrder = 1
      OnClick = Button2Click
      SkinData.SkinSection = 'BUTTON'
    end
    object ChkUseForceBindIP: TsCheckBox
      Left = 10
      Top = 20
      Width = 105
      Height = 19
      Caption = 'Use ForceBindIP'
      TabOrder = 4
      OnClick = ChkUseForceBindIPClick
      SkinData.SkinSection = 'CHECKBOX'
      ImgChecked = 0
      ImgUnchecked = 0
    end
  end
  object CbCaption: TsComboBox
    Left = 80
    Top = 5
    Width = 286
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
    TabOrder = 6
  end
  object sOpenDialog1: TsOpenDialog
    DefaultExt = 'exe'
    Filter = 'Applications (*.exe)|*.exe|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Choose executable'
    Left = 21
    Top = 125
  end
end

object FormInternalSkins: TFormInternalSkins
  Left = 395
  Top = 234
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Internal skins'
  ClientHeight = 240
  ClientWidth = 354
  Color = clBtnFace
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox1: TsListBox
    Left = 13
    Top = 13
    Width = 198
    Height = 212
    Color = clWhite
    Ctl3D = True
    ItemHeight = 13
    ParentCtl3D = False
    ParentFont = False
    Sorted = True
    TabOrder = 0
    OnClick = ListBox1Click
    SkinData.SkinSection = 'EDIT'
  end
  object sBitBtn1: TsButton
    Left = 240
    Top = 203
    Width = 90
    Height = 25
    Action = ActionClose
    Cancel = True
    Default = True
    TabOrder = 1
    SkinData.SkinSection = 'BUTTON'
  end
  object sPanel1: TsPanel
    Left = 228
    Top = 13
    Width = 117
    Height = 180
    BevelOuter = bvLowered
    Caption = ' '
    TabOrder = 2
    SkinData.SkinSection = 'PANEL_LOW'
    object sButton2: TsButton
      Left = 13
      Top = 12
      Width = 90
      Height = 25
      Action = ActionAddNew
      TabOrder = 0
      SkinData.SkinSection = 'BUTTON'
    end
    object sButton3: TsButton
      Left = 13
      Top = 39
      Width = 90
      Height = 25
      Action = ActionRename
      TabOrder = 1
      SkinData.SkinSection = 'BUTTON'
    end
    object sButton4: TsButton
      Left = 13
      Top = 66
      Width = 90
      Height = 25
      Action = ActionExtract
      TabOrder = 2
      SkinData.SkinSection = 'BUTTON'
    end
    object sButton1: TsButton
      Left = 13
      Top = 93
      Width = 90
      Height = 25
      Action = ActionDelete
      TabOrder = 3
      SkinData.SkinSection = 'BUTTON'
    end
    object sButton5: TsButton
      Left = 13
      Top = 120
      Width = 90
      Height = 25
      Action = ActionClear
      TabOrder = 4
      SkinData.SkinSection = 'BUTTON'
    end
    object sButton6: TsButton
      Left = 13
      Top = 147
      Width = 90
      Height = 25
      Action = ActionUpdateAll
      TabOrder = 5
      SkinData.SkinSection = 'BUTTON'
    end
  end
  object ActionList1: TActionList
    Left = 76
    Top = 95
    object ActionAddNew: TAction
      Caption = 'Add new'
      OnExecute = ActionAddNewExecute
    end
    object ActionDelete: TAction
      Caption = 'Delete'
      Enabled = False
      OnExecute = ActionDeleteExecute
    end
    object ActionRename: TAction
      Caption = 'Rename'
      Enabled = False
      OnExecute = ActionRenameExecute
    end
    object ActionClose: TAction
      Caption = 'Close'
      ShortCut = 27
      OnExecute = ActionCloseExecute
    end
    object ActionClear: TAction
      Caption = 'Clear'
      OnExecute = ActionClearExecute
    end
    object ActionExtract: TAction
      Caption = 'Extract'
      Enabled = False
      OnExecute = ActionExtractExecute
    end
    object ActionUpdateAll: TAction
      Caption = 'Update all'
      OnExecute = ActionUpdateAllExecute
    end
  end
  object sSkinProvider1: TsSkinProvider
    CaptionAlignment = taCenter
    SkinData.SkinSection = 'FORM'
    ShowAppIcon = False
    TitleButtons = <>
    Left = 104
    Top = 95
  end
end

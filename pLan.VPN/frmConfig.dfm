object ConfigForm: TConfigForm
  Left = 405
  Top = 271
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 365
  ClientWidth = 513
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
  object sTreeView1: TsTreeView
    Left = 0
    Top = 0
    Width = 146
    Height = 330
    Align = alLeft
    Color = 15855332
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    HideSelection = False
    Indent = 19
    ParentFont = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    OnChange = sTreeView1Change
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
  object sPanel1: TsPanel
    Left = 146
    Top = 0
    Width = 367
    Height = 330
    Align = alClient
    BevelOuter = bvLowered
    BevelWidth = 2
    TabOrder = 1
    SkinData.SkinSection = 'PANEL_LOW'
    object sLabel18: TsLabel
      Left = 2
      Top = 2
      Width = 363
      Height = 18
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'sLabel18'
      ParentFont = False
      Layout = tlCenter
      OnMouseDown = FormMouseDown
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16182738
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object sPageControl1: TsPageControl
      Left = 2
      Top = 20
      Width = 363
      Height = 308
      ActivePage = sTabSheet1
      Align = alClient
      TabOrder = 0
      SkinData.SkinSection = 'PAGECONTROL'
      object sTabSheet1: TsTabSheet
        Caption = 'General settings'
        TabVisible = False
        OnMouseDown = FormMouseDown
        SkinData.CustomColor = False
        SkinData.CustomFont = False
        object sLabel1: TsLabel
          Left = 5
          Top = 5
          Width = 25
          Height = 13
          Caption = 'Nick:'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16182738
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object sLabel22: TsLabel
          Left = 5
          Top = 205
          Width = 51
          Height = 13
          Caption = 'Language:'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16182738
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object sLabel16: TsLabel
          Left = 5
          Top = 245
          Width = 24
          Height = 13
          Caption = 'Skin:'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16182738
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object ChkStartOnSystemBoot: TsCheckBox
          Left = 5
          Top = 50
          Width = 146
          Height = 19
          Caption = 'Run on Windows startup'
          TabOrder = 0
          SkinData.SkinSection = 'CHECKBOX'
          ImgChecked = 0
          ImgUnchecked = 0
        end
        object ChkMinimizeOnStartup: TsCheckBox
          Left = 5
          Top = 75
          Width = 119
          Height = 19
          Caption = 'Minimize on startup'
          TabOrder = 1
          SkinData.SkinSection = 'CHECKBOX'
          ImgChecked = 0
          ImgUnchecked = 0
        end
        object sGroupBox3: TsGroupBox
          Left = 8
          Top = 111
          Width = 151
          Height = 76
          Caption = 'Do not show Join/Part'
          TabOrder = 2
          OnMouseDown = FormMouseDown
          SkinData.SkinSection = 'GROUPBOX'
          object ChkIgnoreJoinsOnIRC: TsCheckBox
            Left = 5
            Top = 25
            Width = 58
            Height = 19
            Caption = 'in IRC'
            TabOrder = 0
            SkinData.SkinSection = 'CHECKBOX'
            ImgChecked = 0
            ImgUnchecked = 0
          end
          object ChkIgnoreJoinsOnRoom: TsCheckBox
            Left = 5
            Top = 50
            Width = 68
            Height = 19
            Caption = 'in Room'
            TabOrder = 1
            SkinData.SkinSection = 'CHECKBOX'
            ImgChecked = 0
            ImgUnchecked = 0
          end
        end
        object ComboLanguage: TsComboBox
          Left = 5
          Top = 220
          Width = 170
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
          Style = csDropDownList
          Color = 15855332
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 15
          ItemIndex = -1
          ParentFont = False
          TabOrder = 3
          Items.Strings = (
            'English')
        end
        object ComboSkin: TsComboBox
          Left = 5
          Top = 260
          Width = 170
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
          Style = csDropDownList
          Color = 15855332
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 15
          ItemIndex = -1
          ParentFont = False
          TabOrder = 4
          OnChange = ComboSkinChange
        end
        object EdName: TsEdit
          Left = 5
          Top = 20
          Width = 170
          Height = 21
          Color = 15855332
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
      end
      object sTabSheet2: TsTabSheet
        Caption = 'Connection'
        TabVisible = False
        OnMouseDown = FormMouseDown
        SkinData.CustomColor = False
        SkinData.CustomFont = False
        object sGroupBox1: TsGroupBox
          Left = 1
          Top = 0
          Width = 351
          Height = 246
          Caption = 'Advanced'
          TabOrder = 0
          OnMouseDown = FormMouseDown
          SkinData.SkinSection = 'GROUPBOX'
          object sLabel3: TsLabel
            Left = 10
            Top = 25
            Width = 73
            Height = 13
            Caption = 'OpenVPN Port:'
            ParentFont = False
            OnMouseDown = FormMouseDown
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 16182738
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object sLabel4: TsLabel
            Left = 170
            Top = 25
            Width = 53
            Height = 13
            Caption = 'Room Port:'
            ParentFont = False
            OnMouseDown = FormMouseDown
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 16182738
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object sLabel5: TsLabel
            Left = 10
            Top = 94
            Width = 113
            Height = 13
            Caption = 'Public network address:'
            ParentFont = False
            OnMouseDown = FormMouseDown
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 16182738
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object sLabel8: TsLabel
            Left = 10
            Top = 140
            Width = 106
            Height = 13
            Caption = 'OpenVPN executable:'
            ParentFont = False
            OnMouseDown = FormMouseDown
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 16182738
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object sLabel6: TsLabel
            Left = 10
            Top = 195
            Width = 64
            Height = 13
            Caption = 'OpenVPN IP:'
            ParentFont = False
            OnMouseDown = FormMouseDown
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 16182738
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object sLabel7: TsLabel
            Left = 185
            Top = 195
            Width = 79
            Height = 13
            Caption = 'OpenVPN mask:'
            ParentFont = False
            OnMouseDown = FormMouseDown
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 16182738
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object ChkAutomaticIP: TsCheckBox
            Left = 10
            Top = 70
            Width = 140
            Height = 19
            Caption = 'Auto IP (recommended)'
            TabOrder = 0
            OnClick = ChkAutomaticIPClick
            SkinData.SkinSection = 'CHECKBOX'
            ImgChecked = 0
            ImgUnchecked = 0
          end
          object sEdit1: TsEdit
            Left = 10
            Top = 40
            Width = 131
            Height = 21
            Color = 15855332
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            Text = '1'#160'097'
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
          object UdOpenVPNPort: TsUpDown
            Left = 141
            Top = 40
            Width = 16
            Height = 21
            Associate = sEdit1
            Min = 1025
            Max = 32535
            Position = 1097
            TabOrder = 2
          end
          object sEdit2: TsEdit
            Left = 165
            Top = 40
            Width = 131
            Height = 21
            Color = 15855332
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 3
            Text = '1'#160'098'
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
          object UdRoomPort: TsUpDown
            Left = 296
            Top = 40
            Width = 16
            Height = 21
            Associate = sEdit2
            Min = 1025
            Max = 32535
            Position = 1098
            TabOrder = 4
          end
          object ComboInterface: TsComboBox
            Left = 10
            Top = 109
            Width = 145
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
            Color = 15855332
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ItemHeight = 15
            ItemIndex = -1
            ParentFont = False
            TabOrder = 5
          end
          object EdOpenVPNExe: TsEdit
            Left = 10
            Top = 155
            Width = 291
            Height = 21
            Color = 15855332
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            ReadOnly = True
            TabOrder = 6
            Text = 'C:\Program Files\OpenVPN\bin\openvpn.exe'
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
          object sButton3: TsButton
            Left = 307
            Top = 152
            Width = 26
            Height = 25
            Hint = 'Browse'
            Caption = '...'
            TabOrder = 7
            OnClick = sButton3Click
            SkinData.SkinSection = 'BUTTON'
          end
          object EdOpenVPNIP: TsMaskEdit
            Left = 10
            Top = 210
            Width = 161
            Height = 21
            Color = 15855332
            EditMask = '000.000.000.000;1;'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            MaxLength = 15
            ParentFont = False
            TabOrder = 8
            Text = '   .   .   .   '
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
          object EdOpenVPNMask: TsMaskEdit
            Left = 185
            Top = 210
            Width = 156
            Height = 21
            Color = 15855332
            EditMask = '000.000.000.000;1;'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            MaxLength = 15
            ParentFont = False
            TabOrder = 9
            Text = '   .   .   .   '
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
          object sButton6: TsButton
            Left = 160
            Top = 106
            Width = 129
            Height = 25
            Caption = 'Network connections'
            TabOrder = 10
            OnClick = sButton6Click
            SkinData.SkinSection = 'BUTTON'
          end
        end
      end
      object sTabSheet3: TsTabSheet
        Caption = 'Notifications'
        TabVisible = False
        OnMouseDown = FormMouseDown
        SkinData.CustomColor = False
        SkinData.CustomFont = False
        object sLabel14: TsLabel
          Left = 25
          Top = 30
          Width = 60
          Height = 13
          Caption = 'Check every'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16182738
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object sLabel13: TsLabel
          Left = 5
          Top = 55
          Width = 71
          Height = 13
          Caption = 'Notification list:'
          ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16182738
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object sLabel15: TsLabel
          Left = 195
          Top = 30
          Width = 42
          Height = 13
          Caption = 'minute(s)'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 16182738
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object ChkAutoNotifies: TsCheckBox
          Left = 5
          Top = 5
          Width = 121
          Height = 19
          Caption = 'Enable notifications'
          TabOrder = 0
          SkinData.SkinSection = 'CHECKBOX'
          ImgChecked = 0
          ImgUnchecked = 0
        end
        object sEdit3: TsEdit
          Left = 135
          Top = 27
          Width = 40
          Height = 21
          Color = 15855332
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          Text = '2'
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
        object UdAutoNotifyPeriod: TsUpDown
          Left = 175
          Top = 27
          Width = 16
          Height = 21
          Associate = sEdit3
          Min = 1
          Max = 60
          Position = 2
          TabOrder = 2
        end
        object sListView1: TsListView
          Left = 1
          Top = 72
          Width = 350
          Height = 149
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
          Checkboxes = True
          Color = 15855332
          Columns = <
            item
              Width = 325
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ReadOnly = True
          RowSelect = True
          ParentFont = False
          ShowColumnHeaders = False
          TabOrder = 3
          ViewStyle = vsReport
        end
        object sGroupBox2: TsGroupBox
          Left = 1
          Top = 225
          Width = 350
          Height = 70
          Caption = 'Sound notifications'
          TabOrder = 4
          OnMouseDown = FormMouseDown
          SkinData.SkinSection = 'GROUPBOX'
          object ChkSoundNotifyOnInterestingGame: TsCheckBox
            Left = 5
            Top = 20
            Width = 201
            Height = 19
            Caption = 'Room for interesting game is created'
            TabOrder = 0
            SkinData.SkinSection = 'CHECKBOX'
            ImgChecked = 0
            ImgUnchecked = 0
          end
          object ChkSoundNotifyOnUserJoined: TsCheckBox
            Left = 5
            Top = 45
            Width = 208
            Height = 19
            Caption = 'User joined (in minimized to tray mode)'
            TabOrder = 1
            SkinData.SkinSection = 'CHECKBOX'
            ImgChecked = 0
            ImgUnchecked = 0
          end
        end
      end
    end
  end
  object sPanel2: TsPanel
    Left = 0
    Top = 330
    Width = 513
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    OnMouseDown = FormMouseDown
    SkinData.SkinSection = 'CHECKBOX'
    object sButton1: TsButton
      Left = 345
      Top = 5
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = sButton1Click
      SkinData.SkinSection = 'BUTTON'
    end
    object sButton2: TsButton
      Left = 430
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = sButton2Click
      SkinData.SkinSection = 'BUTTON'
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'OpenVPN executable|openvpn.exe|All files|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 3
    Top = 225
  end
  object ImageListGames: TImageList
    Left = 33
    Top = 225
  end
end

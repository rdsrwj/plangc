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
    Color = clWhite
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
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object sPageControl1: TsPageControl
      Left = 2
      Top = 20
      Width = 363
      Height = 308
      ActivePage = sTabSheet5
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
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object sLabel22: TsLabel
          Left = 5
          Top = 133
          Width = 51
          Height = 13
          Caption = 'Language:'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object sLabel16: TsLabel
          Left = 5
          Top = 181
          Width = 24
          Height = 13
          Caption = 'Skin:'
          ParentFont = False
          OnMouseDown = FormMouseDown
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object ChkStartOnSystemBoot: TsCheckBox
          Left = 5
          Top = 50
          Width = 142
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
          Width = 115
          Height = 19
          Caption = 'Minimize on startup'
          TabOrder = 1
          SkinData.SkinSection = 'CHECKBOX'
          ImgChecked = 0
          ImgUnchecked = 0
        end
        object sGroupBox3: TsGroupBox
          Left = 200
          Top = 47
          Width = 151
          Height = 76
          Caption = 'Do not show Join/Part'
          TabOrder = 2
          OnMouseDown = FormMouseDown
          SkinData.SkinSection = 'GROUPBOX'
          object ChkIgnoreJoinsOnIRC: TsCheckBox
            Left = 5
            Top = 25
            Width = 54
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
            Width = 64
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
          Top = 148
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
          Color = clWhite
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
          Top = 196
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
          Color = clWhite
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
            Font.Color = clBlack
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
            Font.Color = clBlack
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
            Font.Color = clBlack
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
            Font.Color = clBlack
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
            Font.Color = clBlack
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
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
          end
          object ChkAutomaticIP: TsCheckBox
            Left = 10
            Top = 70
            Width = 60
            Height = 19
            Caption = 'Auto IP'
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
            Color = clWhite
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
            Color = clWhite
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
            Color = clWhite
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
            Color = clWhite
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
            Color = clWhite
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
            Color = clWhite
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
          Font.Color = clBlack
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
          Font.Color = clBlack
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
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
        end
        object ChkAutoNotifies: TsCheckBox
          Left = 5
          Top = 5
          Width = 117
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
          Color = clWhite
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
          Color = clWhite
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
            Width = 197
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
            Width = 204
            Height = 19
            Caption = 'User joined (in minimized to tray mode)'
            TabOrder = 1
            SkinData.SkinSection = 'CHECKBOX'
            ImgChecked = 0
            ImgUnchecked = 0
          end
        end
      end
      object sTabSheet5: TsTabSheet
        Caption = 'About'
        TabVisible = False
        OnMouseDown = FormMouseDown
        SkinData.CustomColor = False
        SkinData.CustomFont = False
        object sRichEditURL1: TsRichEditURL
          Left = 0
          Top = 0
          Width = 355
          Height = 298
          Align = alClient
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
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
          SkinData.CustomColor = True
          SkinData.CustomFont = True
          SkinData.SkinSection = 'EDIT'
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
  object FcAbout: TFileContainer
    FileName = 'about.rtf'
    Left = 65
    Top = 225
    Data = {
      7B5C727466315C616E73695C616E7369637067313235315C64656666307B5C66
      6F6E7474626C7B5C66305C6673776973735C66707271325C6663686172736574
      3020417269616C3B7D7B5C66315C6673776973735C66707271325C6663686172
      7365743230347B5C2A5C666E616D6520417269616C3B7D417269616C20435952
      3B7D7B5C66325C666E696C5C6663686172736574302043616C696272693B7D7D
      0D0A7B5C636F6C6F7274626C203B5C726564305C677265656E305C626C756531
      32383B7D0D0A7B5C2A5C67656E657261746F72204D7366746564697420352E34
      312E31352E313531353B7D5C766965776B696E64345C7563315C706172645C71
      635C6C616E67313033335C625C66305C6673323020704C616E204F70656E5650
      4E2045646974696F6E5C6366315C7061720D0A5C706172645C7061720D0A4175
      74686F72735C6C616E67313034395C6631203A5C6366305C6C616E6731303333
      5C62305C66302020444B54696772612C204A6F65735C7061720D0A5C6366315C
      6220436F6E7472696275746F72733A5C6366305C62302020416E64726F732C20
      48657263756C65732C204B2E5370656374722C205368696E2C2053756E6E7944
      72616B655C7061720D0A5C6366315C62205370656369616C207468616E6B7320
      666F7220737570706F72743A205F5C6366305C623020616D7374795F2C20416C
      6578616E6465722C2046696C696E2C20566972745C7061720D0A5C6366315C62
      205472616E736C61746F72733A5C6366305C62305C7061720D0A20202020456E
      676C69736828454E2920704C616E204465765465616D5C7061720D0A20202020
      4765726D616E2844452920465269545A205B4E696B6F6C6179202872756E3840
      676D782E6465295D5C7061720D0A202020205275737369616E2852552920704C
      616E204465765465616D5C7061720D0A5C6366315C6220486F6D65706167653A
      5C6366305C62302020687474703A2F2F706C616E67632E72752F5C7061720D0A
      5C6366315C6220466F72756D3A5C6366305C62302020687474703A2F2F706C61
      6E67632E72752F666F72756D2E68746D6C5C7061720D0A5C6C616E67395C6632
      5C667332325C7061720D0A7D0D0A00}
  end
end

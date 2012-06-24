// $Id$
unit frmConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Buttons, Mask, ImgList, CheckLst,
  sPanel, sButton, sPageControl, sGroupBox, sCheckBox, sLabel, sComboBox,
  sEdit, sUpDown, sMaskEdit, sListView, sTreeView, sRichEdit, FileContainer,
  sRichEditURL;

type
  TConfigForm = class(TForm)
    OpenDialog1: TOpenDialog;
    ImageListGames: TImageList;
    sButton1: TsButton;
    sButton2: TsButton;
    sPageControl1: TsPageControl;
    sTabSheet1: TsTabSheet;
    sTabSheet2: TsTabSheet;
    sTabSheet3: TsTabSheet;
    sLabel1: TsLabel;
    ChkStartOnSystemBoot: TsCheckBox;
    ChkMinimizeOnStartup: TsCheckBox;
    sLabel22: TsLabel;
    sGroupBox2: TsGroupBox;
    ChkSoundNotifyOnInterestingGame: TsCheckBox;
    ChkSoundNotifyOnUserJoined: TsCheckBox;
    sGroupBox3: TsGroupBox;
    ChkIgnoreJoinsOnIRC: TsCheckBox;
    ChkIgnoreJoinsOnRoom: TsCheckBox;
    sGroupBox1: TsGroupBox;
    sLabel3: TsLabel;
    sLabel4: TsLabel;
    sLabel5: TsLabel;
    sLabel8: TsLabel;
    ChkAutomaticIP: TsCheckBox;
    sLabel6: TsLabel;
    sLabel7: TsLabel;
    ChkAutoNotifies: TsCheckBox;
    sLabel14: TsLabel;
    sLabel13: TsLabel;
    sLabel15: TsLabel;
    sLabel16: TsLabel;
    ComboLanguage: TsComboBox;
    ComboSkin: TsComboBox;
    EdName: TsEdit;
    sEdit1: TsEdit;
    UdOpenVPNPort: TsUpDown;
    sEdit2: TsEdit;
    UdRoomPort: TsUpDown;
    ComboInterface: TsComboBox;
    EdOpenVPNExe: TsEdit;
    sButton3: TsButton;
    EdOpenVPNIP: TsMaskEdit;
    EdOpenVPNMask: TsMaskEdit;
    sEdit3: TsEdit;
    UdAutoNotifyPeriod: TsUpDown;
    sListView1: TsListView;
    sTreeView1: TsTreeView;
    sTabSheet5: TsTabSheet;
    FcAbout: TFileContainer;
    sRichEditURL1: TsRichEditURL;
    sLabel18: TsLabel;
    sPanel1: TsPanel;
    sPanel2: TsPanel;
    sButton6: TsButton;
    procedure FormCreate(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sButton1Click(Sender: TObject);
    procedure sButton2Click(Sender: TObject);
    procedure ComboSkinChange(Sender: TObject);
    procedure sButton3Click(Sender: TObject);
    procedure sTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ChkAutomaticIPClick(Sender: TObject);
    procedure sButton6Click(Sender: TObject);
  private
    { Private declarations }
    procedure SaveSettings;
    procedure FillLanguageCombo;
    procedure FillSkinCombo;
    procedure FillAdaptersCombo(LastAdress: String = '');
  public
    { Public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.dfm}

uses
  IniFiles, ShellAPI, UGlobal, USettings, ULanguage, AdaptItems,
  frmShowRooms;

procedure TConfigForm.FormCreate(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
  LV: TListItem;
  TreeNode: TTreeNode;
  MS: TMemoryStream;
begin
  Language.Apply(Self);

  sPageControl1.ActivePage := sTabSheet1;
  for I := 0 to sPageControl1.PageCount - 1 do
  begin
    TreeNode := sTreeView1.Items.Add(nil, sPageControl1.Pages[I].Caption);
    TreeNode.Data := sPageControl1.Pages[I];
    sPageControl1.Pages[I].Tag := Integer(TreeNode);
  end;
  sTreeView1.Selected := TTreeNode(Pointer(sTabSheet1.Tag));

  EdName.Text := Settings.UserName;
  ChkStartOnSystemBoot.Checked := Settings.StartOnSystemBoot;
  ChkMinimizeOnStartup.Checked := Settings.MinimizeOnStartup;

  UdOpenVPNPort.Position := Settings.OpenVPNPort;
  UdRoomPort.Position := Settings.RoomPort;
  ComboInterface.Text := Settings.NetworkIP;
  EdOpenVPNIP.Text := Settings.OpenVPNIP;
  EdOpenVPNMask.Text := Settings.OpenVPNMask;
  EdOpenVPNExe.Text := Settings.OpenVPNExeFile;

  ChkIgnoreJoinsOnIRC.Checked := Settings.IgnoreJoinOnIRC;
  ChkIgnoreJoinsOnRoom.Checked := Settings.IgnoreJoinOnRoom;

  ChkSoundNotifyOnInterestingGame.Checked :=
    Settings.SoundNotifyOnInterestingGame;
  ChkSoundNotifyOnUserJoined.Checked := Settings.SoundNotifyOnUserJoined;

  ChkAutomaticIP.Checked := Settings.AutomaticIP;

  ChkAutoNotifies.Checked := Settings.AutoNotify;
  UdAutoNotifyPeriod.Position := Settings.AutoNotifyPeriod;

  if FileExists(UGlobal.DataPath + 'gamelist.txt') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(UGlobal.DataPath + 'gamelist.txt');
      for I := 0 to SL.Count - 1 do
      begin
        if (SL[I] <> '') then
        begin
          LV := sListView1.Items.Add;
          LV.Caption := SL.Strings[I];
          LV.Checked := (Settings.SelectedGames.IndexOf(LV.Caption) <> -1);
        end;
      end;
    finally
      SL.Free;
    end;
  end;

  FillAdaptersCombo;
  ComboInterface.Enabled := not ChkAutomaticIP.Checked;

  FillLanguageCombo;
  ComboLanguage.ItemIndex := ComboLanguage.Items.IndexOf(Settings.LanguageName);

  FillSkinCombo;
  ComboSkin.ItemIndex :=
    ComboSkin.Items.IndexOf(ShowRoomsForm.sSkinManager1.SkinName);

  MS := TMemoryStream.Create;
  try
    fcAbout.SaveToStream(MS);
    if (MS.Size > 0) then
    begin
      MS.Seek(0, soFromBeginning);
      sRichEditURL1.Lines.LoadFromStream(MS);
    end;
  finally
    MS.Free;
  end;
end;

procedure TConfigForm.SaveSettings;
var
  I: Integer;
begin
  Settings.UserName := EdName.Text;

  Settings.OpenVPNPort := UdOpenVPNPort.Position;
  Settings.RoomPort := UdRoomPort.Position;
  Settings.NetworkIP := ComboInterface.Text;
  Settings.OpenVPNIP := EdOpenVPNIP.Text;
  Settings.OpenVPNMask := EdOpenVPNMask.Text;
  Settings.OpenVPNExeFile := EdOpenVPNExe.Text;

  Settings.StartOnSystemBoot := ChkStartOnSystemBoot.Checked;
  Settings.MinimizeOnStartup := ChkMinimizeOnStartup.Checked;

  Settings.IgnoreJoinOnIRC := ChkIgnoreJoinsOnIRC.Checked;
  Settings.IgnoreJoinOnRoom := ChkIgnoreJoinsOnRoom.Checked;

  Settings.SoundNotifyOnInterestingGame :=
    ChkSoundNotifyOnInterestingGame.Checked;

  Settings.SoundNotifyOnUserJoined := ChkSoundNotifyOnUserJoined.Checked;

  Settings.LanguageName := ComboLanguage.Text;
  Settings.SkinName := ComboSkin.Text;

  Settings.AutomaticIP := ChkAutomaticIP.Checked;

  Settings.AutoNotify := ChkAutoNotifies.Checked;
  Settings.AutoNotifyPeriod := UdAutoNotifyPeriod.Position;

  Settings.SelectedGames.Clear;
  for I := 0 to sListView1.Items.Count - 1 do
  begin
    if sListView1.Items[I].Checked then
      Settings.SelectedGames.Add(sListView1.Items[I].Caption);
  end;

  Settings.Save;

  if ShowRoomsForm.IdIRC1.Connected and
    (ShowRoomsForm.IdIRC1.Nick <> Settings.UserName) then
  try
    ShowRoomsForm.IdIRC1.Nick := Settings.UserName;
  except
  end;
end;

procedure TConfigForm.Label12Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
    PAnsiChar('http://www.teamspeak.org'), nil, nil, SW_NORMAL);
end;

procedure TConfigForm.FillLanguageCombo;
var
  SR: TSearchRec;
  S: String;
begin
  S := UGlobal.AppPath + 'Languages\';
  if (FindFirst(S + '*.xml', {faHidden + faSysFile}faAnyFile, SR) = 0) then
  begin
    repeat
      {if (SR.Name <> '..') then}
      ComboLanguage.Items.Add(ChangeFileExt(SR.Name, ''));
    until (FindNext(SR) <> 0);
    FindClose(SR);
  end;
end;

procedure TConfigForm.FillSkinCombo;
var
  StrList: TStringList;
  I: Integer;
begin
  StrList := TStringList.Create;
  ShowRoomsForm.sSkinManager1.GetSkinNames(StrList);
  if (StrList.Count > 0) then
  begin
    StrList.Sort;
    for I := 0 to StrList.Count - 1 do
      ComboSkin.Items.Add(StrList.Strings[I]);
  end;
  StrList.Free;
end;

procedure TConfigForm.FillAdaptersCombo(LastAdress: String = '');
var
  I: Integer;
  Item: TAdapterItem;
  AdapterList: TAdapterList;
begin
  ComboInterface.Items.Clear;
  AdapterList := TAdapterList.Create;
  for I := 0 to AdapterList.Count - 1 do
  begin
    Item := AdapterList.Items[I];
    ComboInterface.Items.Add(Item.IPAddress);
    if (Item.IPAddress = LastAdress) then
      ComboInterface.ItemIndex := I;
  end;
end;

procedure TConfigForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TConfigForm.sButton1Click(Sender: TObject);
begin
  if (ComboInterface.Text = '') and (not ChkAutomaticIP.Checked) then
  begin
    Application.MessageBox(PChar(Language.msgYouNeedToSelectIP),
      PChar(Language.msgError));
  end
  else
  begin
    if (Settings.LanguageName <> ComboLanguage.Text) then
    begin
      Application.MessageBox(PChar(Language.msgYouNeedToRestart),
        PChar(Language.msgWarning));
    end;

    SaveSettings;

    ModalResult := mrOK;
  end;
end;

procedure TConfigForm.sButton2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TConfigForm.ComboSkinChange(Sender: TObject);
begin
  ShowRoomsForm.sSkinManager1.SkinName := ComboSkin.Text;
end;

procedure TConfigForm.sButton3Click(Sender: TObject);
begin
  OpenDialog1.InitialDir := UGlobal.AppPath;
  OpenDialog1.Filter := 'OpenVPN executable|openvpn.exe|All files|*.*';
  OpenDialog1.FileName := 'openvpn.exe';
  if OpenDialog1.Execute then
    EdOpenVPNExe.Text := OpenDialog1.FileName;
end;

procedure TConfigForm.sTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  sPageControl1.ActivePage := TsTabSheet(Node.Data);
  sLabel18.Caption := Node.Text;
end;

procedure TConfigForm.ChkAutomaticIPClick(Sender: TObject);
begin
  ComboInterface.Enabled := not ChkAutomaticIP.Checked;
end;

procedure TConfigForm.sButton6Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', 'control.exe', 'ncpa.cpl', nil,
    SW_NORMAL);
end;

end.

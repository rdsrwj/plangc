// $Id$
unit frmShowRooms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Registry, Buttons, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer, IdSocketHandle, HTTPGet,CoolTrayIcon,
  MPlayer, FileContainer, Menus, SHFolder, sSkinManager, sListView,
  sRichEdit, sButton, sLabel, acAlphaHints, sBitBtn, sPageControl, sPanel,
  IRCRichEdit, sStatusBar, IdTCPConnection, IdTCPClient, IdIRC, sSplitter,
  sEdit, OpenVPNManager, ChatServer, ChatClient, sMemo, sComboBox,
  FileLauncher, ImgList, acAlphaImageList, acTitleBar, sSkinProvider;

const
  diGetCreateServerLog = 12;
  diGetConnectLog      = 13;

type
  TWorkMode = (wmIdle, wmClient, wmServer);

type
  TDLLProc = procedure;

  TShowRoomsForm = class(TForm)
    HTTPVpnGet: THTTPGet;
    LblServerInfo: TsLabel;
    UDPPinger: TIdUDPServer;
    PingTimer: TTimer;
    HTTPVpnGetShort: THTTPGet;
    TimerVpnGetShort: TTimer;
    CoolTrayIcon1: TCoolTrayIcon;
    MediaPlayer1: TMediaPlayer;
    FcNotifyWav: TFileContainer;
    FcServerKey: TFileContainer;
    FcServerPEM: TFileContainer;
    FcDHPem: TFileContainer;
    FcClientKey: TFileContainer;
    FcClientPem: TFileContainer;
    FcCAPem: TFileContainer;
    FcCAKey: TFileContainer;
    PopupMenu1: TPopupMenu;
    MiOpen: TMenuItem;
    N3: TMenuItem;
    MiQuit1: TMenuItem;
    FcNotify2Wav: TFileContainer;
    FcPLanDLL: TFileContainer;
    FcDataXML: TFileContainer;
    TimerGetData: TTimer;
    sSkinManager1: TsSkinManager;
    LvRoomsList: TsListView;
    sAlphaHints1: TsAlphaHints;
    sPageControl1: TsPageControl;
    TsRoomList: TsTabSheet;
    FcRussianXML: TFileContainer;
    FcEnglishXML: TFileContainer;
    FcGermanXML: TFileContainer;
    sStatusBar1: TsStatusBar;
    sPageControl2: TsPageControl;
    TsMainChat: TsTabSheet;
    sPanel2: TsPanel;
    EdMainChat: TsEdit;
    BtnMainChatSend: TsButton;
    LvMainChatUsers: TsListView;
    sSplitter1: TsSplitter;
    ReMainChat: TIRCRichEdit;
    IdIRC1: TIdIRC;
    TsRoom: TsTabSheet;
    sPanel3: TsPanel;
    EdRoom: TsEdit;
    BtnRoomSend: TsButton;
    LvRoomUsers: TsListView;
    sSplitter2: TsSplitter;
    ReRoom: TIRCRichEdit;
    TsNews: TsTabSheet;
    TimerVpnAdd: TTimer;
    VPNManager: TOpenVPNManager;
    sSplitter3: TsSplitter;
    sPanel4: TsPanel;
    ChatServer1: TChatServer;
    BtnDisconnect: TsButton;
    HTTPVpnAdd: THTTPGet;
    HTTPVpnDel: THTTPGet;
    sMemo1: TsMemo;
    HTTPGetNews: THTTPGet;
    TimerGetNews: TTimer;
    TsIRCServer: TsTabSheet;
    ReServer: TIRCRichEdit;
    ReRoomInfo: TIRCRichEdit;
    sPanel5: TsPanel;
    EdServer: TsEdit;
    BtnServerSend: TsButton;
    TsMyGames: TsTabSheet;
    LvMyGames: TsListView;
    sPanel6: TsPanel;
    BtnAdd: TsButton;
    BtnDelete: TsButton;
    PopupMenu2: TPopupMenu;
    MiAdd: TMenuItem;
    MiEdit: TMenuItem;
    MiDelete: TMenuItem;
    sAlphaImageList1: TsAlphaImageList;
    TimerVpnGet: TTimer;
    sTitleBar1: TsTitleBar;
    PopupMenu3: TPopupMenu;
    MiQuit: TMenuItem;
    N5: TMenuItem;
    MiConnect: TMenuItem;
    MiCreateRoom: TMenuItem;
    MiSettings: TMenuItem;
    sSkinProvider1: TsSkinProvider;
    N9: TMenuItem;
    MiMakeReport: TMenuItem;
    MiRefresh: TMenuItem;
    MiHelp: TMenuItem;
    MiForum: TMenuItem;
    MiHomePage: TMenuItem;
    MiAbout: TMenuItem;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure LvRoomsListDblClick(Sender: TObject);
    procedure LvRoomsListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure HTTPVpnGetDoneString(Sender: TObject; Result: String);
    procedure HTTPVpnGetShortDoneString(Sender: TObject; Result: String);
    procedure HTTPGetNewsDoneString(Sender: TObject; Result: String);
    procedure TimerVpnGetTimer(Sender: TObject);
    procedure TimerVpnGetShortTimer(Sender: TObject);
    procedure TimerGetDataTimer(Sender: TObject);
    procedure TimerVpnAddTimer(Sender: TObject);
    procedure TimerGetNewsTimer(Sender: TObject);
    procedure PingTimerTimer(Sender: TObject);
    procedure UDPPingerUDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
    procedure CoolTrayIcon1Click(Sender: TObject);
    procedure CoolTrayIcon1MinimizeToTray(Sender: TObject);
    procedure MiOpenClick(Sender: TObject);
    procedure MiQuit1Click(Sender: TObject);
    procedure IdIRC1Disconnect(Sender: TObject);
    procedure IdIRC1Disconnected(Sender: TObject);
    procedure IdIRC1Error(Sender: TObject; AUser: TIdIRCUser; ANumeric,
      AError: String);
    procedure IdIRC1Join(Sender: TObject; AUser: TIdIRCUser;
      AChannel: TIdIRCChannel);
    procedure IdIRC1Message(Sender: TObject; AUser: TIdIRCUser;
      AChannel: TIdIRCChannel; Content: String);
    procedure IdIRC1Part(Sender: TObject; AUser: TIdIRCUser;
      AChannel: TIdIRCChannel);
    procedure IdIRC1Names(Sender: TObject; AUsers: TIdIRCUsers;
      AChannel: TIdIRCChannel);
    procedure IdIRC1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: String);
    procedure IdIRC1Joined(Sender: TObject; AChannel: TIdIRCChannel);
    procedure EdMainChatKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure IdIRC1Quit(Sender: TObject; AUser: TIdIRCUser);
    procedure IdIRC1NickChange(Sender: TObject; AUser: TIdIRCUser;
      ANewNick: String);
    procedure IdIRC1NickChanged(Sender: TObject; AOldNick: String);
    procedure BtnMainChatSendClick(Sender: TObject);
    procedure IdIRC1Raw(Sender: TObject; AUser: TIdIRCUser; ACommand,
      AContent: String; var Suppress: Boolean);
    procedure LvMainChatUsersDblClick(Sender: TObject);
    procedure VPNManagerConnected(Sender: TObject);
    procedure VPNManagerDisconnected(Sender: TObject);
    procedure BtnRoomSendClick(Sender: TObject);
    procedure EdRoomKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LvRoomUsersDblClick(Sender: TObject);
    procedure BtnDisconnectClick(Sender: TObject);
    procedure IdIRC1Connected(Sender: TObject);
    procedure BtnServerSendClick(Sender: TObject);
    procedure EdServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure IdIRC1Notice(Sender: TObject; AUser: TIdIRCUser;
      AChannel: TIdIRCChannel; Content: String);
    procedure IdIRC1Topic(Sender: TObject; AUser: TIdIRCUser;
      AChannel: TIdIRCChannel; const AChanName, ATopic: String);
    procedure IdIRC1System(Sender: TObject; AUser: TIdIRCUser;
      ACmdCode: Integer; ACommand, AContent: String);
    procedure MiAddClick(Sender: TObject);
    procedure MiDeleteClick(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure MiEditClick(Sender: TObject);
    procedure LvMyGamesDblClick(Sender: TObject);
    procedure IdIRC1Kick(Sender: TObject; AUser, AVictim: TIdIRCUser;
      AChannel: TIdIRCChannel);
    procedure IdIRC1Kicked(Sender: TObject; AUser: TIdIRCUser;
      AChannel: TIdIRCChannel);
    procedure MiConnectClick(Sender: TObject);
    procedure MiCreateRoomClick(Sender: TObject);
    procedure MiSettingsClick(Sender: TObject);
    procedure MiMakeReportClick(Sender: TObject);
    procedure MiQuitClick(Sender: TObject);
    procedure MiRefreshClick(Sender: TObject);
    procedure MiHomePageClick(Sender: TObject);
    procedure MiForumClick(Sender: TObject);
    procedure MiAboutClick(Sender: TObject);
  private
    FWorkMode: TWorkMode;
    FReportList: TStringList;
    FMyGamesList: TFileLauncherList;
    FShortList: TStringList;
    FlgClosing: Boolean;
    FlgMinimized: Boolean;
    FlgCanJoinToRoomChannel: Boolean;
    procedure Reconnect(Err: String);
    procedure LvMyGamesRefresh;
    procedure ParseList(Data: String);
    function FindUser(LV: TsListView; Nick: String; var Prefix: String): Integer;
  end;

var
  ShowRoomsForm: TShowRoomsForm;
  pLanDLLHandle: THandle;
  ProcHooker: TDLLProc;
  ProcUnhooker: TDLLProc;
  ProcVersion: TDLLProc;
  ReconnectNum: Integer = 0; // Начальное значение количества переподключений.

implementation

{$R *.dfm}

uses
  PsAPI, ShellAPI, UGlobal, USettings, ULanguage, frmConfig, AdaptItems,
  frmCreateRoom, frmOVPNInit, frmDetailedError, frmFileOpen;

procedure TShowRoomsForm.FormCreate(Sender: TObject);
var
  AList: TAdapterList;
  StrList: TStringList;
  I: Integer;
  Reg: TRegistry;
begin
  Language.Apply(Self);

  Self.Caption := UGlobal.AppTitle + ' v' + UGlobal.AppVersion;

  // Скины.
  sSkinManager1.SkinDirectory := AppPath + 'Skins';
  StrList := TStringList.Create;
  sSkinManager1.GetSkinNames(StrList);
  if (StrList.Count > 0) then
  begin
    StrList.Sort;
    for I := 0 to StrList.Count - 1 do
    begin
      if (StrList.Strings[I] = Settings.SkinName) then
      begin
        sSkinManager1.SkinName := Settings.SkinName;
        Break;
      end;
    end;
  end;
  StrList.Free;

  // Устанавливаем начальные значения.
  FWorkMode := wmIdle;
  FlgClosing := False;
  FlgMinimized := False;
  FlgCanJoinToRoomChannel := False;

  // Применяем языковые настройки.
  LvRoomsList.Columns[0].Caption := Language.msgPing;
  LvRoomsList.Columns[1].Caption := Language.msgGame;
  LvRoomsList.Columns[2].Caption := Language.msgRoomName;
  LvRoomsList.Columns[3].Caption := Language.msgPlayersCount;
  LvRoomsList.DoubleBuffered := True;
  sStatusBar1.Panels[0].Text := Language.msgYourIP + ':';
  sStatusBar1.Panels[0].Width := TextExtent(sStatusBar1.Panels[0].Text,
    sStatusBar1.Font).cx + 20;
  sStatusBar1.Panels[2].Text := Language.msgRoomsCount + ':';
  sStatusBar1.Panels[2].Width := TextExtent(sStatusBar1.Panels[2].Text,
    sStatusBar1.Font).cx + 20;
  sStatusBar1.Panels[4].Text := Language.msgPlayersCount + ':';
  sStatusBar1.Panels[4].Width := TextExtent(sStatusBar1.Panels[4].Text,
    sStatusBar1.Font).cx + 20;
  MiAdd.Caption := Language.msgAdd;
  MiEdit.Caption := Language.msgEdit;
  MiDelete.Caption := Language.msgDelete;
  MiConnect.Caption := Language.msgConnect;
  MiCreateRoom.Caption := Language.msgCreateRoom;
  MiRefresh.Caption := Language.msgRefresh;
  MiSettings.Caption := Language.msgSettings;
  MiMakeReport.Caption := Language.msgMakeReport;
  MiHelp.Caption := Language.msgHelp;
  MiHomePage.Caption := Language.msgHomePage;
  MiForum.Caption := Language.msgForum;
  MiAbout.Caption := Language.msgAbout;
  MiQuit.Caption := Language.msgQuit;

  // Распаковываем ресурсы.
  FcNotifyWav.CheckAndSaveToFile(UGlobal.DataPath + 'notify.wav');
  FcNotifyWav.Free;
  //
  FcNotify2Wav.CheckAndSaveToFile(UGlobal.DataPath + 'notify2.wav');
  FcNotify2Wav.Free;
  //
  FcServerPEM.CheckAndSaveToFile(UGlobal.DataPath + 'server.pem');
  FcServerPEM.Free;
  //
  FcServerKey.CheckAndSaveToFile(UGlobal.DataPath + 'server.key');
  FcServerKey.Free;
  //
  FcClientPEM.CheckAndSaveToFile(UGlobal.DataPath + 'client.pem');
  FcClientPEM.Free;
  //
  FcClientKey.CheckAndSaveToFile(UGlobal.DataPath + 'client.key');
  FcClientKey.Free;
  //
  FcCaPEM.CheckAndSaveToFile(UGlobal.DataPath + 'ca.pem');
  FcCaPEM.Free;
  //
  FcCaKey.CheckAndSaveToFile(UGlobal.DataPath + 'ca.key');
  FcCaKey.Free;
  //
  FcDHPem.CheckAndSaveToFile(UGlobal.DataPath + 'dh1024.pem');
  FcDHPem.Free;
  //
  FcDataXML.CheckAndSaveToFile(UGlobal.DataPath + 'data.xml');
  FcDataXML.Free;
  //
  FcPlanDLL.CheckAndSaveToFile(UGlobal.DataPath + 'pLan.dll');
  FcPlanDLL.Free;
  //
  FcEnglishXML.CheckAndSaveToFile(UGlobal.AppPath + 'Languages\English.xml.txt');
  FcEnglishXML.Free;
  //
  FcRussianXML.CheckAndSaveToFile(UGlobal.AppPath + 'Languages\Russian.xml');
  FcRussianXML.Free;
  //
  FcGermanXML.CheckAndSaveToFile(UGlobal.AppPath + 'Languages\German.xml');
  FcGermanXML.Free;

  // Загружаем библиотеку pLan.dll, устанавливаем ловушку.
  pLanDLLHandle := LoadLibrary(PChar(UGlobal.DataPath + 'pLan.dll'));
  if (pLanDLLHandle <> 0) then
  begin
    ProcHooker   := GetProcAddress(pLanDLLHandle, 'Hooker');
    ProcUnhooker := GetProcAddress(pLanDLLHandle, 'Unhooker');
    ProcVersion  := GetProcAddress(pLanDLLHandle, 'Version');
    ProcHooker;
  end
  else
  begin
    Application.MessageBox(PChar('Error loading pLan.dll'),
      PChar('Error loading pLan.dll'));
  end;

  // Открываем форму настроек.
  AList := TAdapterList.Create;
  try
    if (AList.GetByIP(Settings.NetworkIP) = nil) and
      (not Settings.AutomaticIP) then
    begin
      Settings.NetworkIP := '';
      MiSettings.Click;
    end;
  finally
    AList.Free;
  end;

  // Завершаем процесс OpenVPN.
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\pLan', True) then
    begin
      if not Reg.ValueExists('OpenVPNHandle') then
        Reg.WriteInteger('OpenVPNHandle', 32000);
      VPNManager.VPNHandle := Reg.ReadInteger('OpenVPNHandle');
    end;
  finally
    Reg.Free;
  end;
  VPNManager.TerminateOpenVPN;

  // Устанавливаем UserAgent для HTTPGet'ов
  HTTPVpnGet.Agent      := UGlobal.HTTPAgent;
  HTTPVpnGetShort.Agent := UGlobal.HTTPAgent;
  HTTPVpnAdd.Agent      := UGlobal.HTTPAgent;
  HTTPVpnDel.Agent      := UGlobal.HTTPAgent;
  HTTPGetNews.Agent     := UGlobal.HTTPAgent;

  // Запускаем таймер оповещений.
  FShortList := TStringList.Create;
  TimerVpnGetShort.Interval := Settings.AutoNotifyPeriod * 60 * 1000;
  TimerVpnGetShort.Enabled := Settings.AutoNotify;

  // Подключаемся к IRC серверу.
  IdIRC1.Host := IRCHost;
  IdIRC1.Port := IRCPort;
  IdIRC1.Nick := Settings.UserName;
  IdIRC1.Username := UGlobal.IRCUsername;
  IdIRC1.Replies.ClientInfo := UGlobal.IRCUsername;
  IdIRC1.Replies.Version := UGlobal.IRCUsername + ' ' + UGlobal.AppVersion;
  IdIRC1.AltNick := Settings.UserName + '_' + IntToStr(Random(3000));
  try
    IdIRC1.Connect;
  except
    on E:Exception do
      ReRoom.AddFormatedString(TAG_COLOR + '4' + E.Message);
  end;

  // Устанавливаем вкладки по умолчанию.
  sPageControl1.ActivePage := TsRoomList;
  TsRoom.TabVisible := False;
  sPageControl2.ActivePage := TsMainChat;

  // Загружаем список игр.
  FMyGamesList := TFileLauncherList.Create;
  FMyGamesList.Load;
  LvMyGamesRefresh;

  LvMainChatUsers.Columns[0].Width := LvMainChatUsers.Width -
    GetSystemMetrics(SM_CXVSCROLL);

  // Запуск в свёрнутом виде.
  {if Settings.MinimizeOnStartup then
    CoolTrayIcon1.HideMainForm;}

  if Settings.MinimizeOnStartup then
    Application.ShowMainForm := False;
end;

procedure TShowRoomsForm.FormShow(Sender: TObject);
begin
  // Открываем форму в центре экрана.
  Self.Left := (GetSystemMetrics(SM_CXSCREEN) - Self.Width)  div 2;
  Self.Top  := (GetSystemMetrics(SM_CYSCREEN) - Self.Height) div 2;

  // Обновляем список комнат.
  MiRefresh.Click;

  // Запускаем таймер обновления списка комнат.
  TimerVpnGet.Enabled := True;
end;

procedure TShowRoomsForm.FormHide(Sender: TObject);
begin
  // Останавливаем таймер обновления списка комнат.
  TimerVpnGet.Enabled := False;
end;

procedure TShowRoomsForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TShowRoomsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not FlgClosing then
  begin
    CoolTrayIcon1.HideMainForm;
    FlgMinimized := True;
  end;
  CanClose := FlgClosing;
end;

procedure TShowRoomsForm.FormDestroy(Sender: TObject);
begin
  // Отключаемся от IRC сервера.
  try
    IdIRC1.Disconnect(True);
  except
  end;

  // Завершаем процесс OpenVPN.
  VPNManager.Disconnect;

  // Освобождаем память.
  FShortList.Free;
  FMyGamesList.Free;
  Language.Free;
  Settings.Free;
end;

procedure TShowRoomsForm.ParseList(Data: String);
var
  S: String;
  SL: TStringList;
  I, L, N: Integer;
  TrackerTime, CreationTime, RoomIP, RoomPort, VpnIP, VpnPort, IRCChannel,
  TeamSpeak, RoomName, GameName, PlayersCount, Players: String;
  RoomUptime: String;
  Item: TListItem;

  function Parse(var S: String): String;
  var
    P: Integer;
  begin
    P := Pos('$', S);
    if (P <> 0) then
    begin
      Result := Copy(S, 1, P - 1);
      S := Copy(S, P + 1, Length(S));
    end
    else
    begin
      Result := S;
    end;
  end;

begin
  UDPPinger.Active := True;
  LvRoomsList.Items.Clear;
  N := 0;

  SL := TStringList.Create;
  try
    SL.Text := Data;

    // IP адрес.
    if (SL.Count >= 1) then
    begin
      S := SL.Strings[0];
      TrackerTime := Parse(S);         // Время на трекере.
      sStatusBar1.Panels[1].Text := S; // Адрес клиента.
    end;

    // Список комнат.
    if (SL.Count > 1) and (Length(SL.Strings[1]) > 4) then
    begin
      for I := 1 to SL.Count - 1 do
      begin
        S := SL.Strings[I];
        S := StringReplace(S, '&amp;',  '&', [rfReplaceAll]);
        S := StringReplace(S, '&lt;',   '<', [rfReplaceAll]);
        S := StringReplace(S, '&gt;',   '>', [rfReplaceAll]);
        S := StringReplace(S, '&quot;', '"', [rfReplaceAll]);
        S := StringReplace(S, '&#039;', #39, [rfReplaceAll]);

        // Парсируем.
        CreationTime := Parse(S); // Время создания комнаты.
        RoomIP       := Parse(S); // Адрес комнаты.
        RoomPort     := Parse(S); // Порт комнаты.
        VpnIP        := Parse(S); // Адрес VPN.
        VpnPort      := Parse(S); // Порт VPN.
        IRCChannel   := Parse(S); // IRC канал комнаты.
        Teamspeak    := Parse(S); // Адрес Teamspeak.
        RoomName     := Parse(S); // Название комнаты.
        GameName     := Parse(S); // Название игры.
        PlayersCount := Parse(S); // Количество игроков.
        Players      := S;        // Список игроков.

        try
          StrToInt(RoomPort);
          StrToInt(VpnPort);
        except
          Continue;
        end;

        // Удаляем запятую в конце строки.
        L := Length(Players);
        if (L > 0) and (Players[L] = ',') then
          Delete(Players, L, 1);

        Inc(N, StrToInt(PlayersCount));

        // ToDo: подсчитывать RoomUptime при выборе комнаты из списка.
        RoomUptime := IntToStr(StrToInt('$' + TrackerTime) -
          StrToInt('$' + CreationTime));

        // Добавляем комнату в список.
        Item := LvRoomsList.Items.Add;
        Item.Caption := '  ';
        Item.SubItems.Add(GameName);     //  0 - Название игры.
        Item.SubItems.Add(RoomName);     //  1 - Название комнаты.
        Item.SubItems.Add(PlayersCount); //  2 - Количество игроков.
        Item.SubItems.Add(CreationTime); //  3 - Время создания.
        Item.SubItems.Add(RoomIP);       //  4 - Адрес комнаты.
        Item.SubItems.Add(RoomPort);     //  5 - Порт комнаты.
        Item.SubItems.Add(VpnIP);        //  6 - Адрес VPN.
        Item.SubItems.Add(VpnPort);      //  7 - Порт VPN.
        Item.SubItems.Add(IRCChannel);   //  8 - IRC канал.
        Item.SubItems.Add(TeamSpeak);    //  9 - Адрес TeamSpeak.
        Item.SubItems.Add(Players);      // 10 - Список игроков.
        Item.SubItems.Add(RoomUptime);   // 11 - Uptime комнаты.
        Item.SubItems.Add('');           // 12 - TickCount на момент проверки.
      end;
    end;

  finally
    SL.Free;
  end;

  sStatusBar1.Panels[3].Text := IntToStr(LvRoomsList.Items.Count); // Количество комнат.
  sStatusBar1.Panels[5].Text := IntToStr(N);                       // Количество игроков.
end;

procedure TShowRoomsForm.LvRoomsListDblClick(Sender: TObject);
begin
  MiConnect.Click;
end;

procedure TShowRoomsForm.HTTPVpnGetDoneString(Sender: TObject; Result: String);
begin
  ParseList(Result);
  PingTimerTimer(Self);
  PingTimer.Enabled := True;
end;

procedure TShowRoomsForm.LvRoomsListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  TickCount: String;
  B: Cardinal;

  function SecToTime(Sec: Integer): String;
  var
    H, M, S: String;
    ZH, ZM, ZS: Integer;
  begin
    ZH := Sec div 3600;
    ZM := Sec div 60 - ZH * 60;
    ZS := Sec - (ZH * 3600 + ZM * 60);
    H := IntToStr(ZH);
    M := Format('%.*d', [2, ZM]);
    S := Format('%.*d', [2, ZS]);
    Result := H + 'h' + M + 'm' + S + 's';
  end;

begin
  ReRoomInfo.Lines.Clear;

  if Selected then
  begin
    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgGame + ': ' +
      TAG_BOLD + Item.SubItems[0], False, False);

    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgRoomName + ': ' +
      TAG_BOLD + Item.SubItems[1], False, False);

    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgRoomIP + ': ' +
      TAG_BOLD + Item.SubItems[4] + ':' + Item.SubItems[5], False, False);

    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgOpenVPNIP + ': ' +
      TAG_BOLD + Item.SubItems[6] + ':' + Item.SubItems[7], False, False);

    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgUptime + ': ' +
      TAG_BOLD + SecToTime(StrToInt(Item.SubItems[11])), False, False);

    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgChannel + ': ' +
      TAG_BOLD + Item.SubItems[8], False, False);

    ReRoomInfo.AddFormatedString(TAG_BOLD + Language.msgPlayers + ': ' +
      TAG_BOLD + Item.SubItems[10], False, False);

    // Пингуем.
    try
      SetLength(TickCount, SizeOf(Cardinal));
      B := GetTickCount;
      Move(B, TickCount[1], SizeOf(Cardinal));

      UDPPinger.Send(Item.SubItems[4], StrToInt(Item.SubItems[5]),
        Char(mtRoomPing) + TickCount + Item.SubItems[4] + ' ' +
          Item.SubItems[5]);
    except
    end;

  end;
end;

procedure TShowRoomsForm.PingTimerTimer(Sender: TObject);
var
  TickCount: String;
  B: Cardinal;
  Item: TListItem;
  I, J: Integer;
begin
  if (LvRoomsList.Items.Count > 0) then
  begin
    SetLength(TickCount, SizeOf(Cardinal));
    B := GetTickCount;
    Move(B, TickCount[1], SizeOf(Cardinal));
    J := 0;
    for I := 0 to LvRoomsList.Items.Count - 1 do
    begin
      Item := LvRoomsList.Items[I];
      if (Item.SubItems[12] = '') then
      begin
        try
          UDPPinger.Send(Item.SubItems[4], StrToInt(Item.SubItems[5]),
            Char(mtRoomPing) + TickCount + Item.SubItems[4] + ' ' +
            Item.SubItems[5]);
        except
        end;
        Item.SubItems[12] := IntToStr(GetTickCount);
        Inc(J);
      end;
      if (J >= 20) then
        Break;
    end;
  end;
end;

procedure TShowRoomsForm.UDPPingerUDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
var
  S: String;
  B: Cardinal;
  I: Integer;
  IP: String;
  Port: String;
begin
  SetLength(S, AData.Size);
  AData.ReadBuffer(S[1], AData.Size);
  S := Copy(S, 2, Length(S) - 1);
  Move(S[1], B, SizeOf(Cardinal));
  S := Copy(S, SizeOf(Cardinal) + 1, Length(S));
  if (Pos(' ', S) <> 0) then
  begin
    IP := Copy(S, 1, Pos(' ', S) - 1);
    Port := Copy(S, Pos(' ', S) + 1, Length(S));
  end;
  if not FlgClosing then
  begin
    for I := 0 to LvRoomsList.Items.Count - 1 do
    begin
      if (LvRoomsList.Items[I].SubItems[4] = IP) and
        (LvRoomsList.Items[I].SubItems[5] = Port) then
      begin
        LvRoomsList.Items[I].Caption := IntToStr(GetTickCount - B);
        Break;
      end;
    end;
  end;
end;

procedure TShowRoomsForm.TimerVpnGetTimer(Sender: TObject);
begin
  MiRefresh.Click;
end;

procedure TShowRoomsForm.TimerVpnGetShortTimer(Sender: TObject);
begin
  //HTTPVpnGetShort.URL := UGlobal.URLTracker + '?do=vpn_getshort';
  HTTPVpnGetShort.URL := UGlobal.URLTracker;
  HTTPVpnGetShort.PostQuery := 'do=vpn_getshort';
  HTTPVpnGetShort.GetString;
end;

procedure TShowRoomsForm.HTTPVpnGetShortDoneString(Sender: TObject;
  Result: String);
var
  I, J: Integer;
  SL: TStringList;
  Flag: Boolean;
  S1, S2: String;
  Count1, Count2: Integer;
  Temp: Integer;
  S: String;
begin
  SL := TStringList.Create;
  S := '';
  try
    SL.Text := Result;
    for I := 0 to SL.Count - 1 do
    begin
      S1 := Copy(SL[I], 1, Pos('|', SL[I]) - 1);
      if (SL[I] <> '') and (Settings.SelectedGames.IndexOf(S1) <> -1) then
      begin
        try
          Val(Copy(SL[I], Pos('|', SL[I]) + 1, Length(SL[I])), Count1, Temp);
        except
          Count1 := 0;
        end;
        Flag := True;
        for J := 0 to FShortList.Count - 1 do
        begin
          S2 := Copy(FShortList[I], 1, Pos('|', FShortList[I]) - 1);
          if S1 = S2 then
          begin
            try
              Val(Copy(FShortList[I], Pos('|', FShortList[I]) + 1,
                Length(FShortList[I])), Count2, Temp);
            except
              Count2 := 0;
            end;
            if (Count1 >= Count2) then
            begin
              Flag := False;
              Break;
            end;
          end;
        end;
        if Flag then
          S := S + S1 + ',';
      end;
    end;
  finally
    FShortList := SL;
  end;
  if (S <> '') then
  begin
    SetLength(S, Length(S) - 1);
    CoolTrayIcon1.ShowBalloonHint('pLan', 'New servers for games: ' + S,
      bitInfo, 10);
    if FileExists(UGlobal.DataPath + 'notify.wav') and
      Settings.SoundNotifyOnInterestingGame then
    begin
      MediaPlayer1.FileName := UGlobal.DataPath + 'notify.wav';
      MediaPlayer1.Open;
      MediaPlayer1.Play;
    end;
  end;
end;

procedure TShowRoomsForm.CoolTrayIcon1Click(Sender: TObject);
begin
  CoolTrayIcon1.ShowMainForm;
  FlgMinimized := False;
end;

procedure TShowRoomsForm.MiQuit1Click(Sender: TObject);
begin
  MiQuit.Click;
end;

procedure TShowRoomsForm.MiOpenClick(Sender: TObject);
begin
  CoolTrayIcon1.ShowMainForm;
  FlgMinimized := False;
end;

procedure TShowRoomsForm.CoolTrayIcon1MinimizeToTray(Sender: TObject);
begin
  FlgMinimized := True;
end;

procedure TShowRoomsForm.TimerGetDataTimer(Sender: TObject);
var
  SL: TStringList;
begin
  if (TimerGetData.Tag = diGetCreateServerLog) then
  begin
    VPNManager.Disconnect;

    repeat
      Application.ProcessMessages;
      Sleep(100);
    until (VPNManager.GetStatus = ovpnDisconnected);

    SL := TStringList.Create;
    try
      try
        SL.LoadFromFile(UGlobal.DataPath + 'log.txt');
        FReportList.Add('=============== Create server log: ===============');
        FReportList.Add(SL.Text);
      except
        FReportList.Add('=============== Create server log: ===============');
        FReportList.Add('Server log.txt not found');
      end;
    finally
      SL.Free;
    end;

    if (Settings.RemoteRoomIP <> '') then
      VPNManager.Connect(Settings.RemoteRoomIP, Settings.RemoteVPNPort, True,
        UGlobal.DataPath)
    else
      VPNManager.Connect('192.168.251.1', 1098, True, UGlobal.DataPath);

    TimerGetData.Interval := 10000;
    TimerGetData.Tag := diGetConnectLog;
    TimerGetData.Enabled := True;
  end
  else
  if (TimerGetData.Tag = diGetConnectLog) then
  begin
    VPNManager.Disconnect;

    repeat
      Application.ProcessMessages;
      Sleep(100);
    until (VPNManager.GetStatus = ovpnDisconnected);

    SL := TStringList.Create;
    try
      try
        SL.LoadFromFile(UGlobal.DataPath + 'log.txt');
        FReportList.Add('=============== Connect log: ===============');
        FReportList.Add(SL.Text);
      except
        FReportList.Add('=============== Connect log: ===============');
        FReportList.Add('client log.txt not found');
      end;
    finally
      SL.Free;
    end;

    TimerGetData.Interval := 30000;
    TimerGetData.Tag := 0;
    TimerGetData.Enabled := False;

    FReportList.SaveToFile(UGlobal.DataPath + 'log.txt');

    Self.Enabled := True;

    OVPNInitForm.Close;
    OVPNInitForm.Free;

    Application.MessageBox(PChar(Language.msgYourReportText +
      UGlobal.DataPath + 'log.txt'), PChar(Language.msgYourReportCaption));
  end;
end;

procedure TShowRoomsForm.IdIRC1Disconnect(Sender: TObject);
begin
  ReMainChat.AddFormatedString(TAG_COLOR + '4Disconnect...');
  ReRoom.AddFormatedString(TAG_COLOR + '4Disconnect...');
  FlgCanJoinToRoomChannel := False;
end;

procedure TShowRoomsForm.IdIRC1Disconnected(Sender: TObject);
begin
  ReMainChat.AddFormatedString(TAG_COLOR + '4Disconnected');
  ReRoom.AddFormatedString(TAG_COLOR + '4Disconnected');
  FlgCanJoinToRoomChannel := False;
end;

procedure TShowRoomsForm.IdIRC1Error(Sender: TObject; AUser: TIdIRCUser;
  ANumeric, AError: String);
begin
  ReMainChat.AddFormatedString(TAG_COLOR + '4Error: ' + AError);
end;

procedure TShowRoomsForm.IdIRC1Join(Sender: TObject; AUser: TIdIRCUser;
  AChannel: TIdIRCChannel);
var
  Item: TListItem;
begin
  // Общий канал.
  if (AChannel.Name = UGlobal.IRCMainChannel) then
  begin
    Item := LvMainChatUsers.Items.Add;
    Item.Caption := AUser.Nick;
    if not Settings.IgnoreJoinOnIRC then
      ReMainChat.AddFormatedString(TAG_COLOR + '15User joined: ' + AUser.Nick);
    Exit;
  end;

  // Комната.
  if (AChannel.Name = Settings.RoomChannel) then
  begin
    Item := LvRoomUsers.Items.Add;
    Item.Caption := AUser.Nick;
    if not Settings.IgnoreJoinOnRoom then
      ReRoom.AddFormatedString(TAG_COLOR + '15User joined: ' + AUser.Nick);
  end;
end;

procedure TShowRoomsForm.IdIRC1Message(Sender: TObject; AUser: TIdIRCUser;
  AChannel: TIdIRCChannel; Content: String);
begin
  if (AChannel <> nil) then
  begin
    // Общий канал.
    if (AChannel.Name = UGlobal.IRCMainChannel) then
    begin
      ReMainChat.AddFormatedString(TAG_COLOR + '1' + TAG_BOLD + '<' +
        AUser.Nick + '>' + TAG_BOLD + ' ' + Content);
      Exit;
    end;

    // Комната.
    if (AChannel.Name = Settings.RoomChannel) then
    begin
      ReRoom.AddFormatedString(TAG_COLOR + '1' + TAG_BOLD + '<' +
        AUser.Nick + '>' + TAG_BOLD + ' ' + Content);
    end;
  end
  else
  begin
    ReMainChat.AddFormatedString(TAG_COLOR + '12(private) ' + AUser.Nick + '->'
      + IdIRC1.Nick + ': ' + Content);
    ReRoom.AddFormatedString(TAG_COLOR + '12(private) ' + AUser.Nick + '->'
      + IdIRC1.Nick + ': ' + Content);
  end;
end;

procedure TShowRoomsForm.IdIRC1Part(Sender: TObject; AUser: TIdIRCUser;
  AChannel: TIdIRCChannel);
var
  Idx: Integer;
  Dummy: String;
begin
  // Общий канал.
  if (AChannel.Name = UGlobal.IRCMainChannel) then
  begin
    Idx := FindUser(LvMainChatUsers, AUser.Nick, Dummy);
    if (Idx <> -1) then
    begin
      LvMainChatUsers.Items.Delete(Idx);
      if not Settings.IgnoreJoinOnIRC then
        ReMainChat.AddFormatedString(TAG_COLOR + '15User parted ' + AUser.Nick);
    end;
    Exit;
  end;

  // Комната.
  if (AChannel.Name = Settings.RoomChannel) then
  begin
    Idx := FindUser(LvRoomUsers, AUser.Nick, Dummy);
    if (Idx <> -1) then
    begin
      LvRoomUsers.Items.Delete(Idx);
      if not Settings.IgnoreJoinOnRoom then
        ReRoom.AddFormatedString(TAG_COLOR + '15User parted ' + AUser.Nick);
    end;
  end;
end;

const
  IRC_OP = 1;
  IRC_VOICE = 2;

type
  TIRCUserState = (ircOp, ircVoice);
  TIRCUserStates = set of TIRCUserState;

function SneakyGetUserState(Data: Integer): TIRCUserStates;
begin
  Result := [];
  if ((Data and IRC_OP) <> 0) then
    Include(Result, ircOp);
  if ((Data and IRC_VOICE) <> 0) then
    Include(Result, ircVoice);
end;

procedure TShowRoomsForm.IdIRC1Names(Sender: TObject; AUsers: TIdIRCUsers;
  AChannel: TIdIRCChannel);
var
  I, Index: Integer;
  Item: TListItem;
  pState: TIRCUserStates;
begin
  // Общий канал.
  if (AChannel.Name = UGlobal.IRCMainChannel) then
  begin
    LvMainChatUsers.Items.Clear;
    for I := 0 to AUsers.Count - 1 do
    begin
      if AChannel.Find(AUsers.Items[I].Nick, Index) then
      begin
        Item := LvMainChatUsers.Items.Add;
        pState := SneakyGetUserState(Integer(AChannel.Names.Objects[Index]));
        if (ircOp in pState) then
          Item.Caption := '@' + AUsers.Items[I].Nick;
        if (ircVoice in pState) then
          Item.Caption := '+' + AUsers.Items[I].Nick;
        if (pState = []) then
          Item.Caption := AUsers.Items[I].Nick;
      end;
    end;
    Exit;
  end;

  // Комната.
  if (AChannel.Name = Settings.RoomChannel) then
  begin
    LvRoomUsers.Items.Clear;
    for I := 0 to AUsers.Count - 1 do
    begin
      if AChannel.Find(AUsers.Items[I].Nick, Index) then
      begin
        Item := LvRoomUsers.Items.Add;
        pState := SneakyGetUserState(Integer(AChannel.Names.Objects[Index]));
        if (ircOp in pState) then
          Item.Caption := '@' + AUsers.Items[I].Nick;
        if (ircVoice in pState) then
          Item.Caption := '+' + AUsers.Items[I].Nick;
        if (pState = []) then
          Item.Caption := AUsers.Items[I].Nick;
      end;
    end;
  end;
end;

procedure TShowRoomsForm.IdIRC1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
  ReMainChat.AddFormatedString(TAG_COLOR + '3' + AStatusText);
end;

procedure TShowRoomsForm.IdIRC1Joined(Sender: TObject; AChannel: TIdIRCChannel);
begin
  // Общий канал.
  if (AChannel.Name = UGlobal.IRCMainChannel) then
  begin
    LvMainChatUsers.Items.Clear;
    ReMainChat.AddFormatedString(TAG_COLOR + '3Joined to channel ' +
      AChannel.Name);
    Exit;
  end;

  // Комната.
  if (AChannel.Name = Settings.RoomChannel) then
  begin
    LvRoomUsers.Items.Clear;
    ReRoom.AddFormatedString(TAG_COLOR + '3Joined to channel ' + AChannel.Name);
  end;
end;

procedure TShowRoomsForm.EdMainChatKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg: TMsg;
begin
  if (Key = VK_RETURN) then
  begin
    PeekMessage(Msg, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    BtnMainChatSend.Click;
  end;
end;

procedure TShowRoomsForm.IdIRC1Quit(Sender: TObject; AUser: TIdIRCUser);
var
  Idx: Integer;
  Dummy: String;
begin
  // Общий канал.
  Idx := FindUser(LvMainChatUsers, AUser.Nick, Dummy);
  if (Idx <> -1) then
  begin
    LvMainChatUsers.Items.Delete(Idx);
    if not Settings.IgnoreJoinOnIRC then
      ReMainChat.AddFormatedString(TAG_COLOR + '15User parted ' + AUser.Nick);
  end;

  // Комната.
  Idx := FindUser(LvRoomUsers, AUser.Nick, Dummy);
  if (Idx <> -1) then
  begin
    LvRoomUsers.Items.Delete(Idx);
    if not Settings.IgnoreJoinOnRoom then
      ReRoom.AddFormatedString(TAG_COLOR + '15User parted ' + AUser.Nick);
  end;    
end;

function TShowRoomsForm.FindUser(LV: TsListView; Nick: String;
  var Prefix: String): Integer;
var
  I: Integer;
  S: String;
  P: String;
begin
  Result := -1;
  Prefix := '';
  for I := 0 to LV.Items.Count - 1 do
  begin
    S := LV.Items[I].Caption;
    if (S[1] in ['&', '@', '+', '~', '%']) then
    begin
      P := S[1];
      Delete(S, 1, 1);
    end
    else
    begin
      P := '';
    end;
    if (S = Nick) then
    begin
      Result := I;
      Prefix := P;
      Break;
    end;
  end;
end;

procedure TShowRoomsForm.IdIRC1NickChange(Sender: TObject; AUser: TIdIRCUser;
  ANewNick: String);
var
  Idx: Integer;
  P: String;
begin
  // Общий канал.
  Idx := FindUser(LvMainChatUsers, AUser.Nick, P);
  if (Idx <> -1) then
    LvMainChatUsers.Items[Idx].Caption := P + ANewNick;

  // Комната.
  Idx := FindUser(LvRoomUsers, AUser.Nick, P);
  if (Idx <> -1) then
    LvRoomUsers.Items[Idx].Caption := P + ANewNick;
end;

procedure TShowRoomsForm.IdIRC1NickChanged(Sender: TObject; AOldNick: String);
var
  Idx: Integer;
  P: String;
begin
  // Общий канал.
  Idx := FindUser(LvMainChatUsers, AOldNick, P);
  if (Idx <> -1) then
    LvMainChatUsers.Items[Idx].Caption := P + IdIRC1.Nick;
  ReMainChat.AddFormatedString(TAG_COLOR + '3Your new nickname: ' + IdIRC1.Nick);

  // Комната.
  Idx := FindUser(LvRoomUsers, AOldNick, P);
  if (Idx <> -1) then
    LvRoomUsers.Items[Idx].Caption := P + IdIRC1.Nick;
  ReRoom.AddFormatedString(TAG_COLOR + '3Your new nickname: ' + IdIRC1.Nick);

  Settings.UserName := IdIRC1.Nick;
end;

procedure TShowRoomsForm.BtnMainChatSendClick(Sender: TObject);
var
  Name: String;
  S: String;
  I: Integer;
begin
  if (Trim(EdMainChat.Text) <> '') then
  begin
    if (Pos('/msg', EdMainChat.Text) = 1) then // Личное сообщение.
    begin
      I := Pos(' ', EdMainChat.Text);
      if (I <> 0) then
        S := Copy(EdMainChat.Text, I + 1, Length(EdMainChat.Text) - I);
      I := Pos(' ', S);
      if (I <> 0) then
      begin
        Name := Copy(S, 1, I - 1);
        S := Copy(S, I + 1, Length(S));
        try
          IdIRC1.Say(Name, S);
          ReMainChat.AddFormatedString(TAG_COLOR + '2(private) ' + IdIRC1.Nick
            + '->' + Name + ': ' + S);
        except
          on E:Exception do
            Reconnect(E.Message);
        end;
      end;
    end
    else
    if (Pos('/', EdMainChat.Text) = 1) then // Другая управляющая команда.
    begin
      S := Copy(EdMainChat.Text, 2, Length(EdMainChat.Text) - 1);
      try
        IdIRC1.WriteLn(S);
      except
        on E:Exception do
          Reconnect(E.Message);
      end;
    end
    else
    begin
      // Иначе посылаем сообщение на общий канал.
      try
        IdIRC1.Say(UGlobal.IRCMainChannel, EdMainChat.Text);
        ReMainChat.AddFormatedString(TAG_COLOR + '1' + TAG_BOLD + '<' +
          IdIRC1.Nick + '>' + TAG_BOLD + ' ' + EdMainChat.Text);
      except
        on E:Exception do
          Reconnect(E.Message);
      end;
    end;
    EdMainChat.Text := '';
  end;
end;

procedure TShowRoomsForm.IdIRC1Raw(Sender: TObject; AUser: TIdIRCUser;
  ACommand, AContent: String; var Suppress: Boolean);
begin
  {ReServer.AddFormatedString(TAG_COLOR + '2' + AUser.Nick + TAG_COLOR + '5 ' +
    ACommand + TAG_COLOR + '1 ' + AContent);}

  // После команды ":End of MOTD command" заходим на основной канал.
  if (ACommand = '376') then
  begin
    FlgCanJoinToRoomChannel := True;
    try
      IdIRC1.Join(UGlobal.IRCMainChannel);
    except
      on E:Exception do
        Reconnect(E.Message);
    end;
  end;
end;

procedure TShowRoomsForm.LvMainChatUsersDblClick(Sender: TObject);
var
  S: String;
begin
  if (LvMainChatUsers.Selected <> nil) then
  begin
    S := LvMainChatUsers.Selected.Caption;
    if (S[1] in ['&', '@', '+', '~', '%']) then
      Delete(S, 1, 1);
    EdMainChat.Text := '/msg ' + S + ' ';
    Self.ActiveControl := EdMainChat;
    EdMainChat.SelStart := Length(EdMainChat.Text);
  end;
end;

procedure TShowRoomsForm.VPNManagerConnected(Sender: TObject);
begin
  ReRoom.AddFormatedString(TAG_COLOR + '3VPN Connection started');
end;

procedure TShowRoomsForm.VPNManagerDisconnected(Sender: TObject);
begin
  ReRoom.AddFormatedString(TAG_COLOR + '3VPN Connection terminated');
end;

procedure TShowRoomsForm.BtnRoomSendClick(Sender: TObject);
var
  Name: String;
  S: String;
  I: Integer;
begin
  if (Trim(EdRoom.Text) <> '') then
  begin
    // Личное сообщение.
    if (Pos('/msg', EdRoom.Text) = 1) then
    begin
      I := Pos(' ', EdRoom.Text);
      if (I <> 0) then
        S := Copy(EdRoom.Text, I + 1, Length(EdRoom.Text) - I);
      I := Pos(' ', S);
      if (I <> 0) then
      begin
        Name := Copy(S, 1, I - 1);
        S := Copy(S, I + 1, Length(S));
        try
          IdIRC1.Say(Name, S);
          ReRoom.AddFormatedString(TAG_COLOR + '2(private) ' + IdIRC1.Nick +
            '->' + Name + ': ' + S);
        except
          on E:Exception do
            Reconnect(E.Message);
        end;
      end;
    end
    else
    if (Pos('/', EdRoom.Text) = 1) then // Другая управляющая команда.
    begin
      S := Copy(EdRoom.Text, 2, Length(EdRoom.Text) - 1);
      try
        IdIRC1.WriteLn(S);
      except
        on E:Exception do
          Reconnect(E.Message);
      end;
    end
    else
    begin
      // Иначе посылаем сообщение в комнату.
      try
        IdIRC1.Say(Settings.RoomChannel, EdRoom.Text);
          ReRoom.AddFormatedString(TAG_COLOR + '1' + TAG_BOLD + '<' +
          IdIRC1.Nick + '>' + TAG_BOLD + ' ' + EdRoom.Text);
      except
        on E:Exception do
          Reconnect(E.Message);
      end;
    end;
    EdRoom.Text := '';
  end;
end;

procedure TShowRoomsForm.EdRoomKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg: TMsg;
begin
  if (Key = VK_RETURN) then
  begin
    PeekMessage(Msg, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    BtnRoomSend.Click;
  end;
end;

procedure TShowRoomsForm.LvRoomUsersDblClick(Sender: TObject);
var
  S: String;
begin
  if (LvRoomUsers.Selected <> nil) then
  begin
    S := LvRoomUsers.Selected.Caption;
    if (S[1] in ['&', '@', '+', '~', '%']) then
      Delete(S, 1, 1);
    EdRoom.Text := '/msg ' + S + ' ';
    Self.ActiveControl := EdRoom;
    EdRoom.SelStart := Length(EdRoom.Text);
  end;
end;

procedure TShowRoomsForm.BtnDisconnectClick(Sender: TObject);
begin
  if ChatServer1.Active then
  begin
    ChatServer1.SendMassMessage(Char(mtServerDies) +
      'Sorry, server disconnected');
  end;

  if (FWorkMode = wmServer) then
  begin
    // Отключаем таймер добавления комнаты на трекер.
    TimerVpnAdd.Enabled := False;

    // Сообщаем в чат комнаты о завершении работы сервера.
    if IdIRC1.Connected then
    try
      IdIRC1.Say(Settings.RoomChannel, 'Sorry, server disconnected');
    except
      on E:Exception do
        ReRoom.AddFormatedString(TAG_COLOR + '4' + E.Message);
    end;

    // Удаляем комнату с трекера.
    HTTPVpnDel.URL := UGlobal.URLTracker;
    HTTPVpnDel.PostQuery := 'do=vpn_del';
    HTTPVpnDel.GetString;
  end;

  // Покидаем канал.
  try
    if IdIRC1.Connected then
      IdIRC1.Part(Settings.RoomChannel);
  except
    {on E:Exception do
      ReRoom.AddFormatedString(TAG_COLOR + '4' + E.Message);}
  end;

  if ChatServer1.Active then
    ChatServer1.Active := False;

  // Завершаем OpenVPN.
  VPNManager.Disconnect;

  // Сбрасываем настройки в исходное состояние.
  Settings.RemoteRoomIP   := '';
  Settings.RemoteRoomPort := 0;
  Settings.RemoteVPNIP    := '';
  Settings.RemoteVPNPort  := 0;
  Settings.LocalRoomName  := '';
  Settings.LocalGameName  := '';
  Settings.RoomChannel    := '';

  FWorkMode := wmIdle;

  // Переключаемся на вкладку "Список комнат".
  TsRoom.TabVisible := False;
  sPageControl1.ActivePage := TsRoomList;

  // Включаем таймеры.
  PingTimer.Enabled := True;
  TimerVpnGetShort.Enabled := Settings.AutoNotify;
end;

function CheckAndFixString(S: String): String;
begin
  S := StringReplace(S, '&', '%26', [rfReplaceAll]);
  S := StringReplace(S, ' ', '%20', [rfReplaceAll]);
  S := StringReplace(S, '#', '',    [rfReplaceAll]);
  Result := S;
end;

procedure TShowRoomsForm.TimerVpnAddTimer(Sender: TObject);
var
  S, Addr: String;
  I: Integer;
  PL: String;
begin
  if Settings.AutomaticIP then
    Addr := ''
  else
    Addr := CheckAndFixString(Settings.NetworkIP);

  HTTPVpnAdd.URL := UGlobal.URLTracker;

  S := 'do=vpn_add'
    + '&addr='         + Addr
    + '&port='         + IntToStr(Settings.RoomPort)
    + '&vpnip=0.0.0.0'
    + '&vpnport='      + IntToStr(Settings.OpenVPNPort)
    + '&chan='         + CheckAndFixString(Settings.RoomChannel)
    + '&gamename='     + CheckAndFixString(Settings.LocalGameName)
    + '&roomname='     + CheckAndFixString(Settings.LocalRoomName)
    + '&playerscount=' + IntToStr(LvRoomUsers.Items.Count);

  PL := '';
  for I := 0 to LvRoomUsers.Items.Count - 1 do
    PL := PL + LvRoomUsers.Items[I].Caption + ', ';
  SetLength(PL, Length(PL) - 1);

  S := S + '&playerlist=' + CheckAndFixString(PL);

  HTTPVpnAdd.PostQuery := S;

  try
    HTTPVpnAdd.GetString;
  except
  end;
end;

procedure TShowRoomsForm.TimerGetNewsTimer(Sender: TObject);
begin
  TimerGetNews.Enabled := False;
  //HTTPGetNews.URL := URLTracker + '?do=getnews&lang=' + Language.Code;
  HTTPGetNews.URL := URLTracker;
  HTTPGetNews.PostQuery := 'do=getnews&lang=' + Language.Code;
  HTTPGetNews.GetString;
end;

procedure TShowRoomsForm.HTTPGetNewsDoneString(Sender: TObject; Result: String);
begin
  sMemo1.Text := Result;
end;

procedure TShowRoomsForm.IdIRC1Connected(Sender: TObject);
begin
  TsIRCServer.Caption := IdIRC1.Host;
  ReconnectNum := 0;
end;

procedure TShowRoomsForm.Reconnect(Err: String);
begin
  ReServer.AddFormatedString(TAG_COLOR + '4' + Err);
  if (ReconnectNum = 10) then
  begin
    IdIRC1.Disconnect;
    Exit;
  end
  else
  begin
    ReconnectNum := ReconnectNum + 1;
    IdIRC1.Disconnect;
    ReServer.Clear;

    try
      IdIRC1.Connect(1000);
    except
      on E:Exception do
        Reconnect(E.Message);
    end;
  end;
end;

procedure TShowRoomsForm.BtnServerSendClick(Sender: TObject);
begin
  if (EdServer.Text <> '') then
  begin
    try
      IdIRC1.WriteLn(EdServer.Text);
      ReServer.AddFormatedString(TAG_COLOR + '12' + EdServer.Text);
    except
      on E:Exception do
        Reconnect(E.Message);
    end;
    EdServer.Text := '';
  end;
end;

procedure TShowRoomsForm.EdServerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg: TMsg;
begin
  if (Key = VK_RETURN) then
  begin
    PeekMessage(Msg, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    BtnServerSend.Click;
  end;
end;

procedure TShowRoomsForm.IdIRC1Notice(Sender: TObject; AUser: TIdIRCUser;
  AChannel: TIdIRCChannel; Content: String);
var
  S: String;
begin
  S := TAG_COLOR + '7' + AUser.Nick + ' ' + Content;

  if (AChannel = nil) then
    ReServer.AddFormatedString(S)
  else
  begin
    if (AChannel.Name = UGlobal.IRCMainChannel) then
      ReMainChat.AddFormatedString(S)
    else
    if (AChannel.Name = Settings.RoomChannel) then
      ReRoom.AddFormatedString(S);
  end;
end;

procedure TShowRoomsForm.IdIRC1Topic(Sender: TObject; AUser: TIdIRCUser;
  AChannel: TIdIRCChannel; const AChanName, ATopic: String);
var
  S: String;
begin
  S := TAG_COLOR + '7' + ATopic;
  if (AChanName = UGlobal.IRCMainChannel) then
    ReMainChat.AddFormatedString(S)
  else
  if (AChanName = Settings.RoomChannel) then
    ReRoom.AddFormatedString(S);
end;

procedure TShowRoomsForm.IdIRC1System(Sender: TObject; AUser: TIdIRCUser;
  ACmdCode: Integer; ACommand, AContent: String);
var
  I: Integer;
  S: String;
begin
  if (ACommand = 'NAMES') or (ACmdCode = 329) then Exit;

  if (ACommand = 'WELCOME') then
  begin
    if (ACmdCode in [1..3]) then
      I := Pos(':', AContent)
    else
      I := Pos(' ', AContent);
    if (I <> 0) then
      S := Copy(AContent, I + 1, Length(AContent) - I);
  end
  else
  begin
    S := AContent;
  end;

  ReServer.AddFormatedString(TAG_COLOR + '1' + S);
end;

procedure TShowRoomsForm.MiAddClick(Sender: TObject);
begin
  BtnAdd.Click;
end;

procedure TShowRoomsForm.MiDeleteClick(Sender: TObject);
begin
  BtnDelete.Click;
end;

procedure TShowRoomsForm.PopupMenu2Popup(Sender: TObject);
begin
  PopupMenu2.Items[1].Enabled := (LvMyGames.ItemFocused <> nil);
  PopupMenu2.Items[2].Enabled := (LvMyGames.ItemFocused <> nil);
end;

procedure TShowRoomsForm.LvMyGamesRefresh;
var
  I: Integer;
  Item: TListItem;
  Icon: TIcon;
  S: String;
begin
  LvMyGames.Items.Clear;
  sAlphaImageList1.Items.Clear;
  for I := 0 to FMyGamesList.Count - 1 do
  begin
    Item := LvMyGames.Items.Add;
    Item.Caption := FMyGamesList.Item[I].Caption;
    // Загружаем иконку.
    S := UGlobal.DataPath + 'cache\' + FMyGamesList.Item[I].IconName;
    if FileExists(S) then
    begin
      Icon := TIcon.Create;
      try
        Icon.LoadFromFile(S);
        Item.ImageIndex := sAlphaImageList1.AddIcon(Icon);
      finally
        Icon.Free;
      end;
    end
    else
    begin
      Item.ImageIndex := -1;
    end;
  end;
end;

procedure TShowRoomsForm.BtnAddClick(Sender: TObject);
var
  FileOpenForm: TFileOpenForm;
  AItem: TFileLauncher;
  S: String;
begin
  FileOpenForm := TFileOpenForm.Create(Self);
  try
    if (FileOpenForm.ShowModal = mrOK) then
    begin
      AItem := TFileLauncher.Create;
      AItem.LaunchString := FileOpenForm.EdFile.Text;
      AItem.Caption := FileOpenForm.CbCaption.Text;
      AItem.UseForceBindIP := FileOpenForm.ChkUseForceBindIP.Checked;
      AItem.InjectIntoProcess := FileOpenForm.ChkInjectIntoProcess.Checked;
      AItem.InjectName := FileOpenForm.EdProcessToInject.Text;
      AItem.WaitAWhile := FileOpenForm.ChkWaitAWhile.Checked;
      {repeat
        S := IntToStr(Random(65535)) + '.ico';
      until not FileExists(UGlobal.DataPath + 'cache\' + S);}
      S := IntToHex(MakeHash(AItem.LaunchString), 8) + '.ico';
      AItem.IconName := S;

      CreateDir(UGlobal.DataPath + 'cache\');
      FileOpenForm.Image.Picture.SaveToFile(UGlobal.DataPath + 'cache\' + S);
      FMyGamesList.Add(AItem);

      FMyGamesList.Save;
      LvMyGamesRefresh;
    end;
  finally
    FileOpenForm.Free;
  end;
end;

procedure TShowRoomsForm.MiEditClick(Sender: TObject);
var
  FileOpenForm: TFileOpenForm;
  AItem: TFileLauncher;
  S: String;
begin
  FileOpenForm := TFileOpenForm.Create(Self);
  try
    AItem := FMyGamesList.Item[LvMyGames.ItemFocused.Index];

    FileOpenForm.CbCaption.Text := AItem.Caption;
    FileOpenForm.EdFile.Text := AItem.LaunchString;
    FileOpenForm.ChkUseForceBindIP.Checked := AItem.UseForceBindIP;
    FileOpenForm.ChkInjectIntoProcess.Checked := AItem.InjectIntoProcess;
    FileOpenForm.EdProcessToInject.Text := AItem.InjectName;
    FileOpenForm.ChkWaitAWhile.Checked := AItem.WaitAWhile;

    if FileExists(UGlobal.DataPath + 'cache\' + AItem.IconName) then
      FileOpenForm.Image.Picture.Icon.LoadFromFile(UGlobal.DataPath + 'cache\' +
        AItem.IconName)
    else
      FileOpenForm.Image.Picture.Icon := nil;

    if FileOpenForm.ShowModal = mrOK then
    begin
      AItem.Caption := FileOpenForm.CbCaption.Text;
      AItem.LaunchString := FileOpenForm.EdFile.Text;
      AItem.UseForceBindIP := FileOpenForm.ChkUseForceBindIP.Checked;
      AItem.InjectIntoProcess := FileOpenForm.ChkInjectIntoProcess.Checked;
      AItem.InjectName := FileOpenForm.EdProcessToInject.Text;
      AItem.WaitAWhile := FileOpenForm.ChkWaitAWhile.Checked;
      {repeat
        S := IntToStr(Random(65535)) + '.ico';
      until not FileExists(UGlobal.DataPath + 'cache\' + S);}
      S := IntToHex(MakeHash(AItem.LaunchString), 8) + '.ico';
      AItem.IconName := S;

      CreateDir(UGlobal.DataPath + 'cache\');
      FileOpenForm.Image.Picture.SaveToFile(UGlobal.DataPath + 'cache\' + S);

      FMyGamesList.Save;
      LvMyGamesRefresh;
    end;
  finally
    FileOpenForm.Free;
  end;
end;

procedure TShowRoomsForm.BtnDeleteClick(Sender: TObject);
var
  S: String;
begin
  if (LvMyGames.ItemFocused = nil) then Exit;

  if (Application.MessageBox(PChar(Language.msgConfirmDelete),
    PChar(Language.msgDelete), MB_YESNO) <> mrYes) then Exit;

  S := UGlobal.DataPath + 'cache\';
  try
    DeleteFile(S + FMyGamesList.Item[LvMyGames.ItemFocused.Index].IconName);
  except
  end;

  FMyGamesList.Delete(LvMyGames.ItemFocused.Index);
  FMyGamesList.Save;

  LvMyGamesRefresh;
end;

function GetProcHandle(ProcName: String): THandle;
var
  Procs: array[0..$FFF] of THandle;
  ProcsCount, Needed: Cardinal;
  I: Integer;
  PH: THandle;
  MH: HMODULE;
  ModuleName: array[0..300] of Char;
  S1, S2: String;
begin
  Result := 0;
  if (ProcName = '') and (not EnumProcesses(@Procs, SizeOf(Procs),
    ProcsCount)) then Exit;
  ProcsCount := ProcsCount div SizeOf(THandle);
  for I := 0 to ProcsCount - 1 do
  begin
    PH := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False,
      Procs[I]);
    if (PH <> 0) then
    begin
      EnumProcessModules(PH, @MH, SizeOf(MH), Needed);
      GetModuleFilenameEx(PH, MH, ModuleName, SizeOf(ModuleName));
      S1 := ExtractFileName(String(ModuleName));
      S2 := ExtractFileName(ProcName);
      CloseHandle(PH);
      if LowerCase(S1) = LowerCase(S2) then
      begin
        Result := Procs[I];
        Break;
      end;
    end;
  end;
end;

procedure AttachDllToProcess(PID: Integer; LibName: String);
var
  ThreadID: Cardinal;
  ThreadHndl: THandle;
  AllocBuffer: Pointer;
  BytesWritten: Cardinal;
  ProcAddr: Pointer;
  ExitCode: Cardinal;
  hProcess: Integer;
begin
  hProcess := OpenProcess(PROCESS_ALL_ACCESS or PROCESS_CREATE_THREAD or
    PROCESS_VM_OPERATION or PROCESS_VM_WRITE, False, PID);
  if (hProcess = 0) then Exit;

  AllocBuffer := VirtualAllocEx(hProcess, nil, Length(LibName) + 1, MEM_COMMIT,
    PAGE_READWRITE);

  LibName := LibName + #0;

  if (AllocBuffer <> nil) then
    WriteProcessMemory(hProcess, AllocBuffer, PChar(LibName), Length(LibName),
      BytesWritten)
  else
    Exit;

  {ProcAddr := GetProcAddress(LoadLibrary(PChar('Kernel32.dll')),
    PChar('LoadLibraryA'));}

  ProcAddr := GetProcAddress(GetModuleHandle(PChar('Kernel32')),
    PChar('LoadLibraryA'));
  if (ProcAddr = nil) then Exit;

  ThreadHndl := CreateRemoteThread(hProcess, nil, 0, ProcAddr, AllocBuffer, 0,
    ThreadID);

  if (ThreadHndl = 0) then
    ExitCode := GetLastError;

  WaitForSingleObject(ThreadHndl, INFINITE);
  GetExitCodeThread(ThreadHndl, ExitCode);
  CloseHandle(ThreadHndl);
  VirtualFreeEx(hProcess, AllocBuffer, 0, MEM_RELEASE);
  CloseHandle(hProcess);
end;

procedure TShowRoomsForm.LvMyGamesDblClick(Sender: TObject);
var
  S: String;
  DataDir: String;
  CurItem: TFileLauncher;
  InjModule: Integer;
  CurDate: TDateTime;
begin
  // Если неактивно VPN-подключение или невыбран элемент из списка, то выходим.
  if (VPNManager.GetStatus <> ovpnConnected) or
    (LvMyGames.Selected = nil) then Exit;

  CurItem := FMyGamesList.Item[LvMyGames.Selected.Index];

  DataDir := IncludeTrailingBackSlash(ExtractFilePath(CurItem.LaunchString));

  if CurItem.UseForceBindIP then
  begin
    if CurItem.InjectIntoProcess and CurItem.WaitAWhile then
      S := '-i '
    else
      S := '';

    ShellExecute(Application.Handle, PChar('open'),
      PChar('"' + UGlobal.AppPath + 'ForceBindIP.exe' + '"'),
      PChar(S + VPNManager.GetOVPNIP + ' ' +
      ExtractFileName(CurItem.LaunchString)), PChar(DataDir), SW_HIDE);

    if CurItem.InjectIntoProcess and (CurItem.InjectName <> '') then
    begin
      CurDate := Time();

      repeat
        InjModule := GetProcHandle(CurItem.InjectName);
        Application.ProcessMessages;
      until (InjModule <> 0) or (Time() > CurDate + EncodeTime(0, 0, 30, 0));

      if (InjModule <> 0) then
        AttachDllToProcess(InjModule, IncludeTrailingBackSlash(
          GetSpecialFolder(CSIDL_SYSTEM)) + 'BindIP.dll');
    end;
  end
  else
  begin
    ShellExecute(Application.Handle, PChar('open'), PChar(CurItem.LaunchString),
      nil, PChar(DataDir), SW_NORMAL);
  end;
end;

procedure TShowRoomsForm.IdIRC1Kick(Sender: TObject; AUser, AVictim: TIdIRCUser;
  AChannel: TIdIRCChannel);
var
  Idx: Integer;
  S, Dummy: String;
begin
  S := TAG_COLOR + '4*User ' + AUser.Nick + ' kick ' + AVictim.Nick + ' [' +
    AVictim.Address + ']:' + AUser.Reason;

  // Общий канал.
  if (AChannel.Name = UGlobal.IRCMainChannel) then
  begin
    Idx := FindUser(LvMainChatUsers, AVictim.Nick, Dummy);
    if (Idx <> -1) then
      LvMainChatUsers.Items.Delete(Idx);
    ReMainChat.AddFormatedString(S);
    Exit;
  end;

  // Комната.
  if (AChannel.Name = Settings.RoomChannel) then
  begin
    Idx := FindUser(LvRoomUsers, AVictim.Nick, Dummy);
    if (Idx <> -1) then
      LvRoomUsers.Items.Delete(Idx);
    ReRoom.AddFormatedString(S);
  end;
end;

procedure TShowRoomsForm.IdIRC1Kicked(Sender: TObject; AUser: TIdIRCUser;
  AChannel: TIdIRCChannel);
var
  Idx: Integer;
  S, Dummy: String;
begin
  S := TAG_COLOR + '4*User ' + AUser.Nick + ' kicked you: ' + AUser.Reason;

  // Общий канал.
  if (AChannel.Name = UGlobal.IRCMainChannel) then
  begin
    Idx := FindUser(LvMainChatUsers, IdIRC1.Nick, Dummy);
    if (Idx <> -1) then
      LvMainChatUsers.Items.Delete(Idx);
    ReMainChat.AddFormatedString(S);
    Exit;
  end;

  // Комната.
  if (AChannel.Name = Settings.RoomChannel) then
  begin
    Idx := FindUser(LvRoomUsers, IdIRC1.Nick, Dummy);
    if (Idx <> -1) then
      LvRoomUsers.Items.Delete(Idx);
    ReRoom.AddFormatedString(S);
  end;
end;

procedure TShowRoomsForm.MiConnectClick(Sender: TObject);
var
  Status: Integer;
  SL: TStringList;
begin
  // Если активно VPN-подключение или не выбрана комната из списка, то выходим.
  if (VPNManager.GetStatus <> ovpnDisconnected) or
    (LvRoomsList.ItemFocused = nil) then Exit;

  // Если комната как IRC-канал и незавершено подключение к IRC-серверу, то выходим.
  if (LvRoomsList.ItemFocused.SubItems.Strings[8] <> 'none') and
    (not FlgCanJoinToRoomChannel) then Exit;

  // Если нет пинга, то предупреждаем.
  try
    StrToInt(LvRoomsList.ItemFocused.Caption);
  except
    if (MessageBox(Application.Handle, PChar(Language.msgRoomHasNoPing),
      PChar(UGlobal.AppTitle), MB_YESNO or MB_DEFBUTTON2) = ID_NO) then Exit;
  end;

  // Отключаем таймеры.
  PingTimer.Enabled := False;
  TimerVpnGetShort.Enabled := False;

  // Запоминаем данные комнаты.
  Settings.RemoteRoomIP   := LvRoomsList.ItemFocused.SubItems.Strings[4];
  Settings.RemoteRoomPort := StrToInt(LvRoomsList.ItemFocused.SubItems.Strings[5]);
  Settings.RemoteVPNIP    := LvRoomsList.ItemFocused.SubItems.Strings[6];
  Settings.RemoteVPNPort  := StrToInt(LvRoomsList.ItemFocused.SubItems.Strings[7]);
  Settings.RoomChannel    := LvRoomsList.ItemFocused.SubItems.Strings[8];

  // Чистим списки.
  LvRoomUsers.Items.Clear;
  ReRoom.Clear;

  // Подключаемся.
  OVPNInitForm := TOVPNInitForm.Create(Self);
  try
    OVPNInitForm.Show;
    repeat
      Application.ProcessMessages;
      Status := VPNManager.GetStatus;
      Sleep(100);
    until (Status = ovpnDisconnected);
    VPNManager.Connect(Settings.RemoteVPNIP, Settings.RemoteVPNPort, True,
      UGlobal.DataPath);
    repeat
      Application.ProcessMessages;
      Status := VPNManager.GetStatus;
      Sleep(100);
    until (Status <> ovpnConnecting);
  finally
    OVPNInitForm.Close;
    OVPNInitForm.Free;
  end;

  if (Status = ovpnConnected) then
  begin
    // Режим работы - клиент.
    FWorkMode := wmClient;

    // Переключаемся на вкладку "Комната".
    TsRoom.TabVisible := True;
    sPageControl1.ActivePage := TsRoom;

    ReRoom.AddFormatedString(TAG_COLOR + '3' +
      'Connected to VPN server with local ip: ' + VPNManager.OVPNIP);

    ReRoom.AddFormatedString(TAG_COLOR + '3' +
      'Connecting chat to ' + LvRoomsList.ItemFocused.SubItems.Strings[1] +
      ' / ' + LvRoomsList.ItemFocused.SubItems.Strings[0]);

    // Подключаемся к чату.
    Settings.RoomChannel := '#' + Settings.RoomChannel;
    if IdIRC1.Connected then
    try
      IdIRC1.Join(Settings.RoomChannel);
    except
      on E:Exception do
        ReRoom.AddFormatedString(TAG_COLOR + '4' + E.Message);
    end;
  end
  else
  begin
    // Завершаем OpenVPN.
    VPNManager.Disconnect;

    Sleep(300);

    // Загружаем лог и показываем окно с ошибкой.
    SL := TStringList.Create;
    try
      SL.LoadFromFile(UGlobal.DataPath + 'log.txt');
      while (SL.Count > 30) do
        SL.Delete(0);
      with TDetailedErrorForm.Create(Self) do
      try
        Memo1.Lines := SL;
        ShowModal;
      finally
        Free;
      end;
    finally
      SL.Free;
    end;

    // Сбрасываем настройки, измененные на этом этапе, в исходное состояние.
    Settings.RemoteRoomIP   := '';
    Settings.RemoteRoomPort := 0;
    Settings.RemoteVPNIP    := '';
    Settings.RemoteVPNPort  := 0;
    Settings.RoomChannel    := '';

    FWorkMode := wmIdle;
  end;
end;

procedure TShowRoomsForm.MiCreateRoomClick(Sender: TObject);
var
  Status: Integer;
  SL: TStringList;
begin
  // Если активно VPN-подключение или незавершено подключение к IRC-серверу, то выходим.
  if (VPNManager.GetStatus <> ovpnDisconnected) or
    (not FlgCanJoinToRoomChannel) then Exit;

  with TCreateRoomForm.Create(Self) do
  try
    EdRoomName.Text    := Settings.UserName + '-s room';
    CbGameName.Text    := '';
    EdRoomChannel.Text := 'plan_' + IntToStr(Random(10000));

    if (ShowModal = mrOK) then
    begin
      // Отключаем таймеры.
      PingTimer.Enabled := False;
      TimerVpnGetShort.Enabled := False;

      // Запоминаем данные комнаты.
      Settings.LocalRoomName := EdRoomName.Text;
      Settings.LocalGameName := CbGameName.Text;
      Settings.RoomChannel   := EdRoomChannel.Text;

      // "Защита от дурака".
      Settings.RoomChannel := StringReplace(Settings.RoomChannel, '#', '',
        [rfReplaceAll]);
      Settings.RoomChannel := StringReplace(Settings.RoomChannel, ' ', '',
        [rfReplaceAll]);
      if Length(Settings.RoomChannel) < 2 then
        Settings.RoomChannel := 'plan_' + IntToStr(Random(10000));
      Settings.RoomChannel := '#' + Settings.RoomChannel;

      // Чистим списки.
      LvRoomUsers.Items.Clear;
      ReRoom.Clear;

      ReRoom.AddFormatedString(TAG_COLOR + '3' + 'Creating VPN-server');

      // Запускаем VPN сервер.
      OVPNInitForm := TOVPNInitForm.Create(Self);
      try
        OVPNInitForm.Show;
        repeat
          Application.ProcessMessages;
          Status := VPNManager.GetStatus;
          Sleep(100);
        until (Status = ovpnDisconnected);
        Caption := 'Disconnected';
        VPNManager.CreateServer(Settings.OpenVPNPort, True, UGlobal.DataPath);
        repeat
          Application.ProcessMessages;
          Status := VPNManager.GetStatus;
          Sleep(100);
        until (Status <> ovpnConnecting);
      finally
        OVPNInitForm.Close;
        OVPNInitForm.Free;
      end;

      if (Status = ovpnConnected) then
      begin
        // Режим работы - сервер.
        FWorkMode := wmServer;

        // Переключаемся на вкладку "Комната".
        TsRoom.TabVisible := True;
        sPageControl1.ActivePage := TsRoom;

        ReRoom.AddFormatedString(TAG_COLOR + '3' + 'Created VPNServer with IP: '
          + VPNManager.OVPNIP);

        ChatServer1.Port := Settings.RoomPort;
        ChatServer1.Active := True;

        ReRoom.AddFormatedString(TAG_COLOR + '3' + 'Creating room for ' +
          Settings.LocalGameName);

        // Заходим на канал комнаты.
        if IdIRC1.Connected then
        try
          IdIRC1.Join(Settings.RoomChannel);
        except
          on E:Exception do
            ReRoom.AddFormatedString(TAG_COLOR + '4' + E.Message);
        end;

        // Запускаем таймер добавления комнаты на трекер.
        TimerVpnAdd.Enabled := True;
        TimerVpnAddTimer(Self);
      end
      else
      begin
        // Завершаем OpenVPN.
        VPNManager.Disconnect;

        Sleep(300);

        // Загружаем лог и показываем окно с ошибкой.
        SL := TStringList.Create;
        try
          SL.LoadFromFile(UGlobal.DataPath + 'log.txt');
          while (SL.Count > 30) do
            SL.Delete(0);
          with TDetailedErrorForm.Create(Self) do
          try
            Memo1.Lines := SL;
            ShowModal;
          finally
            Free;
          end;
        finally
          SL.Free;
        end;

        // Сбрасываем настройки, измененные на этом этапе, в исходное состояние.
        Settings.LocalRoomName := '';
        Settings.LocalGameName := '';
        Settings.RoomChannel   := '';

        FWorkMode := wmIdle;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TShowRoomsForm.MiSettingsClick(Sender: TObject);
begin
  with TConfigForm.Create(Self) do
  try
    if IdIRC1.Connected then
      EdName.Text := IdIRC1.Nick;

    if (ShowModal = mrOK) then
    begin
      TimerVpnGetShort.Interval := Settings.AutoNotifyPeriod * 60 * 1000;
      TimerVpnGetShort.Enabled := Settings.AutoNotify;
    end;
  finally
    Free;
  end;
end;

procedure TShowRoomsForm.MiMakeReportClick(Sender: TObject);
var
  SL: TStringList;
  AdapterList: TAdapterList;
  I: Integer;
begin
  if (MessageBox(Self.Handle,
    'Report generation takes 1-2 minutes. Do you want to continue?',
    PChar(UGlobal.AppTitle), MB_YESNO or MB_DEFBUTTON2) = ID_NO) then Exit;

  FReportList := TStringList.Create;
  SL := FReportList;

  SL.Add('pLan Diagnostic System Report');
  SL.Add('Program version: '                       + UGlobal.AppVersion);
  SL.Add('=============== Local settings: ===============');
  SL.Add('Settings.UserName: '                     + Settings.UserName);
  SL.Add('Settings.RoomPort: '                     + IntToStr(Settings.RoomPort));
  SL.Add('Settings.NetworkIP: '                    + Settings.NetworkIP);
  SL.Add('Settings.OpenVPNPort: '                  + IntToStr(Settings.OpenVPNPort));
  SL.Add('Settings.OpenVPNIP: '                    + Settings.OpenVPNIP);
  SL.Add('Settings.OpenVPNMask: '                  + Settings.OpenVPNMask);
  SL.Add('Settings.OpenVPNExeFile: '               + Settings.OpenVPNExeFile);
  SL.Add('Settings.RemoteRoomIP: '                 + Settings.RemoteRoomIP);
  SL.Add('Settings.RemoteRoomPort: '               + IntToStr(Settings.RemoteRoomPort));
  SL.Add('Settings.RemoteVPNIP: '                  + Settings.RemoteVPNIP);
  SL.Add('Settings.RemoteVPNPort: '                + IntToStr(Settings.RemoteVPNPort));
  SL.Add('Settings.MinimizeOnStartup: '            + IntToStr(Byte(Settings.MinimizeOnStartup)));
  SL.Add('Settings.StartOnSystemBoot: '            + IntToStr(Byte(Settings.StartOnSystemBoot)));
  SL.Add('Settings.AutoNotify: '                   + IntToStr(Byte(Settings.AutoNotify)));
  SL.Add('Settings.AutoNotifyPeriod: '             + IntToStr(Settings.AutoNotifyPeriod));
  SL.Add('Settings.SelectedGames: ');
  SL.Add(Settings.SelectedGames.Text);
  SL.Add('Settings.SoundNotifyOnInterestingGame: ' + IntToStr(Byte(Settings.SoundNotifyOnInterestingGame)));
  SL.Add('Settings.SoundNotifyOnUserJoined: '      + IntToStr(Byte(Settings.SoundNotifyOnUserJoined)));
  SL.Add('Settings.AutomaticIP: '                  + IntToStr(Byte(Settings.AutomaticIP)));
  SL.Add('');
  SL.Add('=============== Paths Settings: ===============');
  if FileExists(Settings.OpenVPNExeFile) then
    SL.Add('openvpn.exe found')
  else
    SL.Add('!!!!! openvpn.exe not found !!!!!');

  SL.Add('=============== Adapter List: =================');

  AdapterList := TAdapterList.Create;
  try
    for I := 0 to AdapterList.Count - 1 do
    begin
      SL.Add(AdapterList.Items[I].Description + ': ' +
        AdapterList.Items[I].IPAddress);
    end;
  finally
    AdapterList.Free;
  end;

  OVPNInitForm := TOVPNInitForm.Create(nil);
  OVPNInitForm.Caption := 'Create system report';
  OVPNInitForm.LblInit.Caption := 'Please, wait...';
  OVPNInitForm.Show;

  VPNManager.CreateServer(Settings.OpenVPNPort, True, UGlobal.DataPath);

  Self.Enabled := False;

  TimerGetData.Interval := 30000;
  TimerGetData.Tag := diGetCreateServerLog;
  TimerGetData.Enabled := True;
end;

procedure TShowRoomsForm.MiQuitClick(Sender: TObject);
begin
  // Не знаю почему, но при включении диалога возникает ошибка.
  {if (Application.MessageBox(PChar(Language.msgConfirmQuit),
    PChar(UGlobal.AppTitle), MB_YESNO or MB_DEFBUTTON2) <> mrYes) then Exit;}

  // Отключаемся.
  BtnDisconnectClick(nil);

  FlgClosing := True;
  Self.Close;
end;

procedure TShowRoomsForm.MiRefreshClick(Sender: TObject);
begin
  LvRoomsList.Items.Clear;
  ReRoomInfo.Clear;

  //HTTPVpnGet.URL := UGlobal.URLTracker + '?do=vpn_get&ver=3';
  HTTPVpnGet.URL := UGlobal.URLTracker;
  HTTPVpnGet.PostQuery := 'do=vpn_get&ver=3';
  HTTPVpnGet.GetString;
end;

procedure TShowRoomsForm.MiHomePageClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', 'http://plangc.ru/', nil, nil,
    SW_NORMAL);
end;

procedure TShowRoomsForm.MiForumClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', 'http://plangc.ru/forum.html', nil,
    nil, SW_NORMAL);
end;

procedure TShowRoomsForm.MiAboutClick(Sender: TObject);
begin
//*
end;

end.

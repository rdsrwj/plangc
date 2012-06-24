// $Id$
unit USettings;

interface

uses
  Windows, Classes, SysUtils, Forms;

type
  TSettings = class(TObject)
  public
    UserName: String;
    RoomPort: Integer;
    NetworkIP: String;
    OpenVPNPort: Integer;
    OpenVPNIP: String;
    OpenVPNMask: String;
    OpenVPNExeFile: String;
    OpenVPNProto: String;
    MinimizeOnStartup: Boolean;
    StartOnSystemBoot: Boolean;
    LanguageName: String;
    SkinName: String;
    ForceIPAPI: Boolean;
    AutoNotify: Boolean;
    AutoNotifyPeriod: Integer;
    SelectedGames: TStringList;
    SoundNotifyOnInterestingGame: Boolean;
    SoundNotifyOnUserJoined: Boolean;
    AutomaticIP: Boolean;
    ShowIRCUserJoinPart: Boolean;
    ShowChatUserJoinPart: Boolean;
    IgnoreJoinOnIRC: Boolean;
    IgnoreJoinOnRoom: Boolean;
  public
    // Переменные Remote* хранят настройки удаленной комнаты при подключении.
    RemoteRoomIP: String;
    RemoteRoomPort: Integer;
    RemoteVPNIP: String;
    RemoteVPNPort: Integer;
    // Переменные Local* хранят настройки комнаты для отправки на трекер.
    LocalRoomName: String;
    LocalGameName: String;
    RoomChannel: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    procedure Save;
  end;

var
  Settings: TSettings;

implementation

uses
  IniFiles, Registry, UGlobal;

{ TSettings }

constructor TSettings.Create;
begin
  inherited;
  SelectedGames := TStringList.Create;
end;

destructor TSettings.Destroy;
begin
  SelectedGames.Free;
  inherited;
end;

procedure TSettings.Load;
var
  Ini: TIniFile;
  Count: Integer;
  I: Integer;
  Reg: TRegistry;
begin
  Ini := TIniFile.Create(UGlobal.DataPath + 'config.ini');
  try
    OpenVPNProto := Ini.ReadString('General', 'OpenVPNProto', 'udp');
    UserName := Ini.ReadString('General', 'UserName', 'NewUser');
    OpenVPNPort := Ini.ReadInteger('General', 'OpenVPNPort', 1097);
    RoomPort := Ini.ReadInteger('General', 'RoomPort', 1098);
    NetworkIP := Ini.ReadString('General', 'NetworkIP', '');
    AutomaticIP := Ini.ReadBool('General', 'AutomaticIP', True);
    IgnoreJoinOnIRC := Ini.ReadBool('General', 'IgnoreJoinOnIRC', True);
    IgnoreJoinOnRoom := Ini.ReadBool('General', 'IgnoreJoinOnRoom', True);
    OpenVPNIP := Ini.ReadString('General', 'OpenVPNIP', '192.168.251.000');
    OpenVPNMask := Ini.ReadString('General', 'OpenVPNMask', '255.255.255.000');
    OpenVPNExeFile := Ini.ReadString('General', 'OpenVPNExeFile',
      'C:\Program Files\OpenVPN\bin\openvpn.exe');
    LanguageName := Ini.ReadString('General', 'Language', 'Russian');
    SkinName := Ini.ReadString('General', 'Skin', 'Beijing Ext (internal)');
    SoundNotifyOnInterestingGame := Ini.ReadBool('General',
      'SoundNotifyOnInterestingGame', True);
    SoundNotifyOnUserJoined := Ini.ReadBool('General',
      'SoundNotifyOnUserJoined', True);

    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey('Software\OpenVPN', False) and
        Reg.ValueExists('exe_path') then
        OpenVPNExeFile := Reg.ReadString('exe_path');
    finally
      Reg.Free;
    end;

    StartOnSystemBoot := Ini.ReadBool('General', 'StartOnSystemBoot', False);
    MinimizeOnStartup := Ini.ReadBool('General', 'MinimizeOnStartup', False);

    ForceIPAPI := Ini.ReadBool('General', 'ForceIPAPI', False);

    AutoNotify := Ini.ReadBool('Notifies', 'EnableAutoNotifies', False);
    AutoNotifyPeriod := Ini.ReadInteger('Notifies', 'AutoNotifyPeriod', 5);

    Count := Ini.ReadInteger('Notifies', 'NotifyCount', 0);
    for I := 0 to Count - 1 do
      SelectedGames.Add(Ini.ReadString('Notifies', 'Notify_' + IntToStr(I), ''));

  finally
    Ini.Free;
  end;
end;

procedure TSettings.Save;
var
  Ini: TIniFile;
  I: Integer;
  Reg: TRegistry;
begin
  Ini := TIniFile.Create(UGlobal.DataPath + 'config.ini');
  try
    Ini.WriteString('General', 'UserName', UserName);
    Ini.WriteInteger('General', 'OpenVPNPort', OpenVPNPort);
    Ini.WriteInteger('General', 'RoomPort', RoomPort);
    Ini.WriteString('General', 'NetworkIP', NetworkIP);
    Ini.WriteString('General', 'OpenVPNIP', OpenVPNIP);
    Ini.WriteString('General', 'OpenVPNMask', OpenVPNMask);
    Ini.WriteString('General', 'OpenVPNExeFile', OpenVPNExeFile);
    Ini.WriteBool('General', 'AutomaticIP', AutomaticIP);
    Ini.WriteBool('General', 'IgnoreJoinOnIRC', IgnoreJoinOnIRC);
    Ini.WriteBool('General', 'IgnoreJoinOnRoom', IgnoreJoinOnRoom);
    Ini.WriteBool('General', 'SoundNotifyOnInterestingGame',
      SoundNotifyOnInterestingGame);
    Ini.WriteBool('General', 'SoundNotifyOnUserJoined',
      SoundNotifyOnUserJoined);
    Ini.WriteString('General', 'Language', LanguageName);
    Ini.WriteString('General', 'Skin', SkinName);

    for I := 0 to SelectedGames.Count - 1 do
    begin
      Ini.WriteString('Notifies', 'Notify_' + IntToStr(I),
        SelectedGames.Strings[I]);
    end;
    Ini.WriteInteger('Notifies','NotifyCount', SelectedGames.Count);

    Ini.WriteBool('Notifies', 'EnableAutoNotifies', AutoNotify);
    Ini.WriteInteger('Notifies', 'AutoNotifyPeriod', AutoNotifyPeriod);

    Ini.WriteBool('General', 'MinimizeOnStartup', MinimizeOnStartup);
  finally
    Ini.Free;
  end;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Settings.StartOnSystemBoot then
    begin
      if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
        Reg.WriteString('pLan OpenVPN', Application.ExeName)
    end
    else
    begin
      if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
        Reg.DeleteValue('pLan OpenVPN');
    end;
  finally
    Reg.Free;
  end;
end;

end.

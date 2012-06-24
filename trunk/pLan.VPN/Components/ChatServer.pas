// $Id$
unit ChatServer;

interface

uses
  Classes, ExtCtrls, IdUDPServer, IdSocketHandle;

type
  TUserJoinedNotify = procedure(Sender: TObject; UserName: String) of object;

  TMessageArrivedNotify = procedure(Sender: TObject; UserName: String;
    Text: String);

  TMessageType = (
    mtUserJoined              = 0,
    mtUserParted              = 1,
    mtTimedOut                = 2,
    mtPing                    = 6,
    mtPong                    = 7,
    mtMessage                 = 9,
    mtDLLMessage              = 10,
    mtServerDies              = 50,
    mtRoomPing                = 60,
    mtRoomPong                = 61,
    mtTeamSpeakServerAnnounce = 70
  );

  TUserItem = class(TObject)
  public
    IP: String;
    Port: Integer;
    UserName: String;
    LastPongSuccessfull: Boolean;
  end;

  TServerInfo = record
    ServerCreated: Boolean;
    ServerUpdated: Boolean;
    TeamSpeakServAddr: String;
    GameName: String;
  end;  

  TUserList = class(TList)
  private
    function GetItem(Index: Integer): TUserItem;
    procedure Delete(Index: Integer);
  public
    destructor Destroy; override;
    property Items[Index: Integer]: TUserItem read GetItem;
    function GetByIP(IP: String; Port: Integer): TUserItem;
    function GetByName(UserName: String): TUserItem;
  end;

  TChatServer = class(TComponent)
  private
    FActive: Boolean;
    FUserList: TUserList;
    UDPServ: TIdUDPServer;
    FServerInfo: TServerInfo;
    FUpdateTimer: TTimer;
    FPingTimer: TTimer;
    procedure OnUpdateTimer(Sender: TObject);
    procedure OnPingTimer(Sender: TObject);        
    procedure ProcessMessage(Msg: TMessageType; S: String; IP: String;
      Port: Integer);
    procedure UDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
    procedure UserJoined(UserName: String; IP: String; Port: Integer);
    procedure UserParted(UserName: String; IP: String; Port: Integer);
    procedure UserTimedOut(UserName: String; IP: String; Port: Integer);
    procedure SetActive(Value: Boolean);
    function GetPort: Integer;
    procedure SetPort(APort: Integer);
  published
    property Active: Boolean read FActive write SetActive;
    property Port: Integer read GetPort write SetPort;
    procedure CloseServer;
    constructor Create(FParent: TComponent); override;
    destructor Destroy; override;
  public
    property UserList: TUserList read FUserList;
    property TeamSpeakServAddr: String read FServerInfo.TeamSpeakServAddr
      write FServerInfo.TeamSpeakServAddr;
    procedure SendMassMessage(S: String);
  end;

  procedure Register;

implementation

uses
  Windows, SysUtils, Forms;

function TUserList.GetItem(Index: Integer): TUserItem;
begin
  Result := TUserItem(Self.Get(Index));
end;

procedure TUserList.Delete(Index: Integer);
begin
  Items[Index].Free;
  inherited Delete(Index);
end;

destructor TUserList.Destroy;
var
  I: Integer;
begin
  for I := Self.Count - 1 downto 0 do Self.Delete(I);
  inherited;
end;

function TUserList.GetByIP(IP: String; Port: Integer): TUserItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (Items[I].IP = IP) and (Items[I].Port = Port) then
    begin
      Result := Items[I];
      Break;
    end;
end;

function TUserList.GetByName(UserName: String): TUserItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (Items[I].UserName = UserName) then
    begin
      Result := Items[I];
      Break;
    end;
end;

procedure TChatServer.ProcessMessage(Msg: TMessageType; S: String; IP: String;
  Port: Integer);
var
  UI: TUserItem;
begin
  case Msg of
    mtUserJoined: UserJoined(S, IP, Port);
    mtUserParted: UserParted(S, IP, Port);
    mtPong:
      begin
        UI := FUserList.GetByIP(IP, Port);
        UI.LastPongSuccessfull := True;
      end;
    mtMessage:
      begin
        UI := FUserList.GetByIP(IP, Port);
        SendMassMessage(Char(mtMessage) + '<' + UI.UserName + '> ' + S);
      end;
    mtDLLMessage:
      begin
        FServerInfo.ServerCreated := True;
        FServerInfo.ServerUpdated := True;
        FServerInfo.GameName := S;
      end;
    mtRoomPing:
      begin
        UDPServ.Send(IP, Port, Char(mtRoomPong) + S);
      end;
    {mtServerDies:
      begin
        SendMassMessage(Char(mtServerDies) + S);
      end;}
  end;
end;

procedure TChatServer.UserJoined(UserName: String; IP: String; Port: Integer);
var
  UI: TUserItem;
  I: Integer;
begin
  UI := FUserList.GetByIP(IP, Port);
  if (UI = nil) then
  begin
    UI := TUserItem.Create;
    UI.IP := IP;
    UI.Port := Port;
    UI.UserName := UserName;
    UI.LastPongSuccessfull := True;
    FUserList.Add(UI);
    SendMassMEssage(Char(mtUserJoined) + UserName);
  end;

  for I := 0 to FUserList.Count - 1 do
  begin
    if (FUserList.Items[I] <> UI) then
       UDPServ.Send(UI.IP, UI.Port, Char(mtUserJoined) +
         FUserList.Items[I].UserName);
  end;

  if (FServerInfo.TeamSpeakServAddr <> '') then
    UDPServ.Send(UI.IP, UI.Port, Char(mtTeamSpeakServerAnnounce) +
      FServerInfo.TeamSpeakServAddr);
end;

procedure TChatServer.SendMassMessage(S: String);
var
  I: Integer;
begin
  for I := FUserList.Count - 1 downto 0 do
    if (I <> 0) or (S[1] <> Char(mtServerDies)) then
      UDPServ.Send(FUserList.Items[I].IP, FUserList.Items[I].Port, S);
end;

procedure TChatServer.UserParted(UserName: String; IP: String; Port: Integer);
var
  UI: TUserItem;
  S: String;
begin
  UI := FUserList.GetByIP(IP, Port);
  if (UI <> nil) then
  begin
    S := UI.UserName;
    FUserList.Delete(FUserList.IndexOf(UI));
    SendMassMessage(Char(mtUserParted) + S);
  end;
end;

procedure TChatServer.UserTimedOut(UserName: String; IP: String; Port: Integer);
var
  UI: TUserItem;
begin
  UI := FUserList.GetByIP(IP, Port);
  if (UI <> nil) then
  begin
    FUserList.Delete(FUserList.IndexOf(UI));
    SendMassMessage(Char(mtUserParted) + UserName);
  end;
end;

procedure TChatServer.SetActive(Value: Boolean);
begin
  if (UDPServ <> nil) then
  begin
    FUserList.Clear;
    if Value then
    begin
      UDPServ.Active := True;
      FUpdateTimer.Enabled := True;
      FPingTimer.Enabled := True;
    end
    else
    if UDPServ.Active then
    begin
      FUpdateTimer.Enabled := False;
      FPingTimer.Enabled := False;
      UDPServ.Active := False;
    end;
    FActive := UDPServ.Active;
  end;
end;

constructor TChatServer.Create(FParent: TComponent);
begin
  inherited Create(FParent);

  FUserList := TUserList.Create;

  UDPServ := TIdUDPServer.Create(Self);
  UDPServ.Active := False;
  UDPServ.OnUDPRead := UDPRead;

  FServerInfo.ServerCreated := False;
  FServerInfo.ServerUpdated := False;
  FServerInfo.GameName := '';

  FUpdateTimer := TTimer.Create(Self);
  FUpdateTimer.Enabled := False;
  FUpdateTimer.Interval := 60000 * 4;
  FUpdateTimer.OnTimer := OnUpdateTimer;

  FPingTimer := TTimer.Create(Self);
  FPingTimer.Interval := 20000;
  FPingTimer.Enabled := False;
  FPingTimer.OnTimer := OnPingTimer;  
end;

destructor TChatServer.Destroy;
begin
  FUserList.Free;
  FUpdateTimer.Free;
  inherited;
end;

procedure TChatServer.UDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
var
  Msg: TMessageType;
  S: String;
begin
  SetLength(S, AData.Size);
  AData.ReadBuffer(S[1], AData.Size);
  Msg := TMessageType(S[1]);
  S := Copy(S, 2, Length(S) - 1);
  ProcessMessage(Msg, S, ABinding.PeerIP, ABinding.PeerPort);
end;

procedure TChatServer.SetPort(APort: Integer);
begin
  if (UDPServ <> nil) then
    if not UDPServ.Active then
      UDPServ.DefaultPort := APort;
end;

procedure TChatServer.OnPingTimer(Sender: TObject);
begin
  SendMassMessage(Char(mtPing));
end;

function TChatServer.GetPort: Integer;
begin
  if (UDPServ <> nil) then
    Result := UDPServ.DefaultPort;
end;

procedure TChatServer.OnUpdateTimer(Sender: TObject);
var
  I: Integer;
begin
  for I := FUserList.Count - 1 downto 0 do
  begin
    if FUserList.Items[I].LastPongSuccessfull then
      FUserList.Items[I].LastPongSuccessfull := False
    else
      UserTimedOut(FUserList.Items[I].UserName, FUserList.Items[I].IP,
        FUserList.Items[I].Port);
  end;
  if FServerInfo.ServerCreated then
  begin
    if FServerInfo.ServerUpdated then
      FServerInfo.ServerUpdated := False
    else
    begin
      FServerInfo.ServerCreated := False;
      SendMassMessage(Char(Byte(mtDLLMessage)) + ' сервер игры отключен');
    end;
  end;
end;

procedure TChatServer.CloseServer;
begin
  Active := False;
end;

procedure Register;
begin
  //RegisterComponents('DKTigra Chat components', [TChatServer]);
  RegisterComponents('pLan Components', [TChatServer]);  
end;

end.


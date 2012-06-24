// $Id$
unit ChatClient;

interface

uses
  Classes, ExtCtrls, IdUDPServer, IdSocketHandle, ChatServer;

type
  TOnUserEvent = procedure(Sender: TObject; UserName: String) of object;

  TChatClient = class(TComponent)
  private
    FUserName: String;
    UDPServ: TIdUDPServer;
    FUpdateTimer: TTimer;
    FOnTimeOut: TNotifyEvent;
    FOnUserJoined: TOnUserEvent;
    FOnUserParted: TOnUserEvent;
    FOnMessage: TOnUserEvent;
    FOnTeamSpeakAnnounce: TOnUserEvent;
    FServerIP: String;
    FServerPort: Integer;
    FReconnectTimer: TTimer;
    FServerUpdated: Boolean;
    FOnDisconnect: TNotifyEvent;
    FDisconnectTimer: TTimer;
    procedure ProcessMessage(Msg: TMessageType; S: String);
    function GetActive: Boolean;
    function GetPort: Integer;
    procedure SetPort(APort: Integer);
    procedure UDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
    procedure OnUpdateTimer(Sender: TObject);
    procedure OnReconnectTimer(Sender: TObject);
  public
    TeamSpeak2Server: String;
    property Active: Boolean read GetActive;
    procedure SendMessage(S: String);
    procedure SendChatString(S: String);
    procedure Connect(AServerIP: String; AServerPort: Integer;
      MyUsername: String; MyPort: Integer);
    procedure Disconnect(Sender: TObject);
    constructor Create(FParent: TComponent); override;
    destructor Destroy; override;
  published
    property OnTimeOut: TNotifyEvent read FOnTimeOut write FOnTimeOut;
    property OnUserJoined: TOnUserEvent read FOnUserJoined write FOnUserJoined;
    property OnUserParted: TOnUserEvent read FOnUserParted write FOnUserParted;
    property OnMessage: TOnUserEvent read FOnMessage write FOnMessage;
    property OnTeamSpeakAnnounce: TOnUserEvent read FOnTeamSpeakAnnounce
      write FOnTeamSpeakAnnounce;
    property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
    property UserName: String read FUserName write FUserName;
    property Port: Integer read GetPort write SetPort;
    property ServerIP: String read FServerIP write FServerIP;
    property ServerPort: integer read FServerPort write FServerPort;
  end;

  procedure Register;

implementation

constructor TChatClient.Create(FParent: TComponent);
begin
  inherited Create(FParent);

  UDPServ := TIdUDPServer.Create(Self);
  UDPServ.OnUDPRead := UDPRead; 

  FUpdateTimer := TTimer.Create(Self);
  FUpdateTimer.Interval := 60000 * 4;
  FUpdateTimer.Enabled := False;
  FUpdateTimer.OnTimer := OnUpdateTimer;

  FDisconnectTimer := TTimer.Create(Self);
  FDisconnectTimer.Interval := 100;
  FDisconnectTimer.Enabled := False;
  FDisconnectTimer.OnTimer := Disconnect;

  FReconnectTimer := TTimer.Create(Self);
  FReconnectTimer.Interval := 200;
  FReconnectTimer.Enabled := False;
  FReconnectTimer.OnTimer := OnReconnectTimer;
end;

destructor TChatClient.Destroy;
begin
  UDPServ.Free;
  FUpdateTimer.Free;
  inherited;
end;

procedure TChatClient.OnUpdateTimer(Sender: TObject);
begin
  if (FServerUpdated = False) then
  begin
    UDPServ.Active := False;
    FServerPort := 0;
    FServerIP := '';
    if Assigned(FOnTimeOut) then
      FOnTimeOut(Self);
    FDisconnectTimer.Enabled := True;
  end
  else
    FServerUpdated := False;
end;

procedure TChatClient.ProcessMessage(Msg: TMessageType; S: String);
begin
  FReconnectTimer.Enabled := False;
  FServerUpdated := True;
  case Msg of
    mtUserJoined:
      begin
        if Assigned(FOnUserJoined) then
          FOnUserJoined(Self, S);
      end;
    mtUserParted:
      begin
        if Assigned(FOnUserParted) then
          FOnUserParted(Self, S);
      end;
    mtTimedOut:
      begin
        if Assigned(FOnUserParted) then
          FOnUserParted(Self, S);
        FDisconnectTimer.Enabled := True;
      end;
    mtPing:
      begin
        if UDPServ.Active then
          UDPServ.Send(FServerIP, FServerPort, Char(mtPong));
      end;
    mtMessage:
      begin
        if Assigned(FOnMessage) then
          FOnMessage(Self, S);
      end;
    mtDLLMessage:
      begin
        if Assigned(FOnMessage) then
          FOnMessage(Self, S);
      end;
    mtServerDies:
      begin
        if Assigned(FOnMessage) then
          FOnMessage(Self, S);
        FDisconnectTimer.Enabled := True;
      end;
    mtTeamSpeakServerAnnounce:
      begin
        TeamSpeak2Server := S;
        if Assigned(FOnTeamSpeakAnnounce) then
          FOnTeamSpeakAnnounce(Self, S);
      end;
  end;  
end;

function TChatClient.GetActive: Boolean;
begin
  if (UDPServ <> nil) then
    Result := UDPServ.Active
  else
    Result := False;
end;

function TChatClient.GetPort: Integer;
begin
  if (UDPServ <> nil) then
    Result := UDPServ.DefaultPort;
end;

procedure TChatClient.SetPort(APort: Integer);
begin
  if (UDPServ <> nil) then
    UDPServ.DefaultPort := APort;
end;

procedure TChatClient.SendMessage(S: String);
begin
  if UDPServ.Active then
    UDPServ.Send(FServerIP, FServerPort, S);
end;

procedure TChatClient.UDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
var
  Msg: TMessageType;
  S: String;
begin
  {if (ABinding.PeerIP = FServerIP) and (ABinding.PeerPort = FServerPort) then}
  begin
    SetLength(S, AData.Size);
    AData.ReadBuffer(S[1], AData.Size);
    Msg := TMessageType(S[1]);
    S := Copy(S, 2, Length(S) - 1);
    ProcessMessage(Msg, S);
  end;
end;

{$O-}
procedure TChatClient.Connect(AServerIP: String; AServerPort: Integer;
  MyUsername: String; MyPort: Integer);
var
  S: String;
begin
  FServerUpdated := False;
  FServerIP := AServerIP;
  FServerPort := AServerPort;
  FUserName := MyUserName;
  FUpdateTimer.Enabled := False;
  FUpdateTimer.Enabled := True;
  UDPServ.DefaultPort := MyPort;
  UDPServ.Active := True;
  S := Char(mtUserJoined) + MyUserName;
  SendMessage(Char(mtUserJoined) + MyUserName);
  FReconnectTimer.Enabled := True;
end;

procedure TChatClient.OnReconnectTimer(Sender: TObject);
begin
  Self.Connect(FServerIP, FServerPort,FUserName, UDPServ.DefaultPort);
end;

procedure TChatClient.SendChatString(S: String);
begin
  SendMessage(Char(mtMessage) + S);
end;

procedure TChatClient.Disconnect(Sender: TObject);
begin
  SendMessage(Char(mtUserParted) + UserName);
  FServerUpdated := False;
  FServerIP := '';
  FServerPort := 0;
  FUserName := '';
  if Assigned(FOnDisconnect) then
    FOnDisconnect(Self);
  UDPServ.Active := False;
  FDisconnectTimer.Enabled := False;
  FUpdateTimer.Enabled := False;
end;

procedure Register;
begin
  //RegisterComponents('DKTigra Chat components', [TChatClient]);
  RegisterComponents('pLan Components', [TChatClient]);  
end;

end.

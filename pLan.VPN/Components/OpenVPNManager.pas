// $Id$
unit OpenVPNManager;

interface

uses
  Classes, PsAPI, ExtCtrls, ShellAPI;

const
  ovpnDisconnected = 0;
  ovpnConnecting   = 1;
  ovpnConnected    = 2;
  ovpnTimedOut     = 3;

type
  TOpenVPNManager = class(TComponent)
  private
    oVPNHandle: THandle;
    FOVPNIP: String;
    FOnConnected: TNotifyEvent;
    FOnDisconnected: TNotifyEvent;
    FTimer: TTimer;
    FAdapterName: String;
    Status: Integer;
    FTimerAttempts: Integer;
    procedure OnTimer(Sender: TObject);
    procedure WriteIPToRegistry;
  public
    property VPNHandle: THandle read oVPNHandle write oVPNHandle;
    function Connect(IP: String; Port: Integer; Log: Boolean;
      Path: String): Boolean;
    function CreateServer(Port: Integer; Log: Boolean; Path: String): Boolean;
    procedure Disconnect;
    procedure WriteHandleToRegistry;
    procedure TerminateOpenVPN;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetStatus: Integer;
    function GetOVPNIP: String;
    property OVPNIP: String read GetOVPNIP;
    property GetAdapterName: String read FAdapterName;
  published
    property OnConnected: TNotifyEvent read FOnConnected write FOnConnected;
    property OnDisconnected: TNotifyEvent read FOnDisconnected
      write FOnDisconnected;
  end;

  procedure Register;

implementation

uses
  Windows, Forms, SysUtils, Registry, USettings, AdaptItems;

type
  OSVERSIONINFOEX = packed record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of Char;
    wServicePackMajor: WORD;
    wServicePackMinor: WORD;
    wSuiteMask: WORD;
    wProductType: BYTE;
    wReserved: BYTE;
  end;
  TOSVersionInfoEx = OSVERSIONINFOEX;
  POSVersionInfoEx = ^TOSVersionInfoEx;

function GetVersionEx(var VersionInformation: OSVERSIONINFOEX): Integer;
  stdcall; external 'kernel32.dll' name 'GetVersionExA';

function HasNetSH: Boolean;
var
  osVersionInfo: OSVERSIONINFOEX;
begin
  Result := True;
  FillChar(osVersionInfo, SizeOf(osVersionInfo), 0);
  osVersionInfo.dwOSVersionInfoSize := SizeOf(osVersionInfo);
  GetVersionEx(OsVersionInfo);
  if (OSVersionInfo.dwMajorVersion = 5) then
    if (OSVersionInfo.dwMinorVersion = 0) then
      Result := False;
end;

function TOpenVPNManager.Connect(IP: String; Port: Integer; Log: Boolean;
  Path: String): Boolean;
var
  SL{, SL2}: TStringList;
  FileName, S: String;
  SI:  _STARTUPINFOA;
  PI: _PROCESS_INFORMATION;
begin
  Status := oVPNConnecting;
  Result := False;
  FTimerAttempts := 0;
  SL := TStringList.Create;
  try
    SL.Add('proto ' + Settings.OpenVPNProto);
    SL.Add('remote ' + IP + ' ' + IntToStr(Port));
    SL.Add('float');
    SL.Add('auth none');
    //SL.Add('port ' + IntToStr(Port));
    SL.Add('dhcp-release');
    SL.Add('dev tap');
    SL.Add('ping-restart 120');
    SL.Add('ping-timer-rem');
    SL.Add('resolv-retry 86400');
    SL.Add('ping 10');
    SL.Add('ca ca.pem');
    SL.Add('dh dh1024.pem');
    SL.Add('cert client.pem');
    SL.Add('persist-key');
    SL.Add('persist-tun');
    SL.Add('status openvpn-status.log');
    SL.Add('tun-mtu 1500');
    SL.Add('key client.key');
    SL.Add('verb 4');
    SL.Add('no-replay');
    SL.Add('win-sys ''env''');
    {if HasNetSH and (Settings.ForceIPAPI = False) then
      SL.Add('ip-win32 netsh')
    else
      SL.Add('ip-win32 ipapi');}
    SL.Add('tls-client');
    SL.Add('client');
    SL.Add('mssfix');
    if Log then
      SL.Add('log log.txt');
    {if (Settings.ProxyType = proxyHTTP) then
    begin
      if (Settings.ProxyLogin <> '') then
      begin
        SL.Add('http-proxy ' + Settings.ProxyAddr + ' ' + Settings.ProxyPort +
          ' proxy.dat');
        SL2 := TStringList.Create;
        try
          SL2.Add(Settings.ProxyLogin);
          SL2.Add(Settings.ProxyPassword);
          SL2.SaveToFile(ExtractFilePath(Application.ExeName) + 'proxy.dat');
        finally
         SL2.Free;
        end;
      end
      else
        SL.Add('http-proxy ' + Settings.ProxyAddr + ' ' + Settings.ProxyPort);
    end
    else
    if Settings.ProxyType = proxySocks then
      SL.Add('socks-proxy ' + Settings.ProxyAddr + ' ' + Settings.ProxyPort);}
    FileName := Path + 'script.ovpn';
    SL.SaveToFile(FileName);

    GetStartupInfo(SI);
    SI.lpReserved := nil;
    SI.lpDesktop := nil;
    SI.lpTitle := nil;
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.wShowWindow := SW_HIDE;

    S := '"' + Settings.OpenVPNExeFile + '" "' + FileName + '" ';

    if CreateProcess(PChar(Settings.OpenVPNExeFile), PChar(S), nil, nil, False,
      HIGH_PRIORITY_CLASS, nil, PChar(Path), SI, PI) then
    begin
      oVPNHandle := PI.dwProcessId;
      WriteHandleToRegistry;
      Result := True;
      if Assigned(FOnConnected) then
        FOnConnected(Self);
    end
    else
      Application.MessageBox(PChar(S +  '. Error: ' + IntToStr(GetLastError)),
        PChar('Error creating OpenVPN process'));
  finally
    SL.Free;
  end;
end;

{$O-}
function TOpenVPNManager.CreateServer(Port: Integer; Log: Boolean;
  Path: String): Boolean;
var
  SL: TStringList;
  FileName, S: String;
  SI: _STARTUPINFOA;
  PI: _PROCESS_INFORMATION;
begin
  Status := oVPNConnecting;
  Result := False;
  FTimerAttempts := 0;
  SL := TStringList.Create;
  try
    SL.Add('port ' + IntToStr(Port));
    SL.Add('proto '+ Settings.OpenVPNProto);
    SL.Add('dev tap');
    SL.Add('auth none');
    SL.Add('ca ca.pem');
    SL.Add('fast-io');
    SL.Add('cert server.pem');
    SL.Add('key server.key');
    SL.Add('dh dh1024.pem');
    //SL.Add('server ' + Settings.OpenVPNIP + ' ' + Settings.OpenVPNMask);
    SL.Add('mode server');
    SL.Add('tls-server');

    S := Copy(Settings.OpenVPNIP, 1, 12);
    SL.Add('ifconfig ' + S + '001 ' + Settings.OpenVPNMask);
    SL.Add('ifconfig-pool ' + S + '002 ' + S + '254 ' + Settings.OpenVPNMask);

    SL.Add('client-to-client');
    SL.Add('keepalive 10 120');
    SL.Add('status openvpn-status.log');
    SL.Add('verb 4');
    SL.Add('no-replay');
    SL.Add('tun-mtu 1500');
    SL.Add('mssfix');
    SL.Add('dhcp-release');
    SL.Add('duplicate-cn');
    SL.Add('win-sys ''env''');
    {if HasNetSH then
      SL.Add('ip-win32 netsh')
    else
      SL.Add('ip-win32 ipapi');}
    if Log then
      SL.Add('log log.txt');

    FileName := Path + 'script.ovpn';
    SL.SaveToFile(FileName);

    GetStartupInfo(SI);
    SI.lpReserved := nil;
    SI.lpDesktop := nil;
    SI.lpTitle := nil;
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.wShowWindow := SW_HIDE;

    S := '"' + Settings.OpenVPNExeFile + '" "' + FileName + '" ';

    if CreateProcess(PChar(Settings.OpenVPNExeFile), PChar(S), nil, nil, False,
      HIGH_PRIORITY_CLASS, nil, PChar(Path), SI, PI) then
    begin
      oVPNHandle := PI.dwProcessId;
      WriteHandleToRegistry;
      Result := True;
      if Assigned(FOnConnected) then
        FOnConnected(Self);
    end
    else
      Application.MessageBox(PChar(S +  '. Error: ' + IntToStr(GetLastError)),
        PChar('Error creating OpenVPN process'));
  finally
    SL.Free;
  end;
end;

function GetProcHandle(ProcName: String): THandle;
var
  PIDArray: array[0..1023] of DWORD;
  cb: DWORD;
  I: Integer;
  ProcCount: Integer;
  hMod: HMODULE;
  hProcess: THandle;
  ModuleName: array[0..300] of Char;
  S1, S2: String;
begin
  Result := 0;
  if (ProcName = '') then Exit;
  EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
  ProcCount := cb div SizeOf(DWORD);
  for I := 0 to ProcCount - 1 do
  begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
      False, PIDArray[I]);
    if (hProcess <> 0) then
    begin
      EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
      GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
      S1 := ExtractFileName(String(ModuleNAme));
      S2 := ExtractFileName(ProcName);
      CloseHandle(hProcess);
      if (LowerCase(S1) = LowerCase(S2)) then
      begin
        Result := PIDArray[i];
        Break;
      end;
    end;
  end;
end;

{$O-}
procedure TOpenVPNManager.TerminateOpenVPN;
var
  TempHandle: THandle;
  ResDW : DWORD;
  S: String;
  Sz: Integer;
begin
  TempHandle := GetProcHandle('openvpn.exe');
  TempHandle := OpenProcess(PROCESS_ALL_ACCESS, False, TempHandle);
  if (TempHandle <> 0) then
  begin
    GetExitCodeProcess(TempHandle, ResDW);
    if (ResDW = STILL_ACTIVE) then
    begin
      SetLength(S, MAX_PATH);
      Sz := GetModuleBaseName(TempHandle, 0, @S[1], MAX_PATH);
      SetLength(S, Sz);
      if (Pos('openvpn', S) <> 0) then
        TerminateProcess(TempHandle, 0);
    end;
  end;  
end;

procedure TOpenVPNManager.Disconnect;
begin
  TerminateOpenVPN;
  WriteIPToRegistry;
  if Assigned(FOnDisconnected) then
    FOnDisconnected(Self);
end;

constructor TOpenVPNManager.Create(AOwner: TComponent);
var
  AdapterList: TAdapterList;
  I: Integer;
  AdapterName: String;
  HasPLanAdapter: Boolean;
  Reg: TRegistry;
  S: String;
  Caption: String;
  //SL: TStringList;
begin
  inherited Create(AOwner);

  FTimer := TTimer.Create(Self);
  FTimer.OnTimer := OnTimer;
  FTimer.Interval := 1000;
  FTimer.Enabled := True;

  AdapterList := TAdapterList.Create;
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  try
    AdapterName := '';
    HasPLanAdapter := False;
    Caption := '';

    for I := 0 to AdapterList.Count - 1 do
    begin
      if (Pos('TAP-Win32', AdapterList.Items[I].Description) <> 0) or
        (AdapterList.Items[I].Description = 'pLan') then
      begin
        S := '';
        if Reg.OpenKeyReadOnly('System\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\' +
          AdapterList.Items[I].Name + '\Connection') then
        begin
          S := Reg.ReadString('Name');
        end;
        Reg.CloseKey;
        if (AdapterName = '') and (S <> '') then
        begin
          FAdapterName := AdapterName;
          AdapterName := AdapterList.Items[I].Name;
          Caption := S;
        end;
        if (S = 'pLan') then
        begin
          FAdapterName := AdapterName;
          HasPLanAdapter := True;
          Break;
        end;
      end;
    end;

    if (not HasPLanAdapter) and (AdapterName <> '') then
    begin
      Reg.Access := KEY_ALL_ACCESS;
      (*if Reg.OpenKey('System\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\' +
        AdapterName + '\Connection', False) then
      begin
        //Reg.WriteString('Name', 'pLan');
        Reg.CloseKey;
      end;*)
      (*if Reg.OpenKey('System\ControlSet001\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\' +
        AdapterName + '\Connection', False) then
      begin
        //Reg.WriteString('Name', 'pLan');
        Reg.CloseKey;
      end;*)
      {SL := TStringList.Create;
      SL.Add('offline');
      SL.Add('interface set interface "' + AdapterName + '" newname=pLan disable');
      SL.Add('interface set interface "pLan" enable');
      SL.Add('commit');
      SL.SaveToFile('netsh.sh');
      SL.Free;}
      {ShellExecute(Application.Handle, PChar('open'), PChar('netsh.exe'),
        PChar('interface set interface "' + AdapterName + '" newname=pLan'),
        PChar(GetCurrentDir), SW_SHOW);}
      //S := 'netsh.exe interface set interface name="' + AdapterName + '" newname="pLan"';
      S := 'netsh interface set interface name="' + AdapterName + '" newname="pLan"';
      {ShellExecute(Application.Handle, PChar('open'), PChar('netsh.exe'),
        PChar(S), PChar('\'), SW_HIDE);}
      //WinExec(PChar('netsh interface set interface pLan enable'), SW_HIDE);
      WinExec(PChar(S), SW_HIDE);
    end;
  except
  end;
  Reg.Free;
end;

destructor TOpenVPNManager.Destroy;
begin
  inherited;
end;

procedure TOpenVPNManager.WriteIPToRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\pLan', True) then
      Reg.WriteString('OpenVPNIP', FOVPNIP);
  finally
    Reg.Free;
  end;
end;

procedure TOpenVPNManager.WriteHandleToRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\pLan', True) then
      Reg.WriteInteger('OpenVPNHandle', oVPNHandle);
  finally
    Reg.Free;
  end;
end;

procedure TOpenVPNManager.OnTimer(Sender: TObject);
var
  AdapterList: TAdapterList;
  I: Integer;
  Flag: Boolean;
  TempHandle: THandle;
  ResDW: DWORD;
begin
  AdapterList := TAdapterList.Create;
  Flag := False;
  try
    for I := 0 to AdapterList.Count - 1 do
    begin
      if (Pos('TAP-Win32', AdapterList.Items[I].Description) <> 0) then
      begin
        if (AdapterList.Items[I].IPAddress = '0.0.0.0') then
        begin
          TempHandle := OpenProcess(PROCESS_ALL_ACCESS, False, oVPNHandle);
          GetExitCodeProcess(TempHandle, ResDW);
          if (Status <> ovpnConnecting) or (FTimerAttempts > 40) or
             (ResDW <> STILL_ACTIVE) then
          begin
            Status := ovpnDisconnected;
            WriteIPToRegistry;
          end;
        end
        else
        begin
          FOVPNIP := AdapterList.Items[I].IPAddress;
          WriteIPToRegistry;
          Status := ovpnConnected;
          Flag := True;
          Break;
        end;
      end
    end;
    if not Flag then
      if (FTimerAttempts > 40) then
      begin
        Status := ovpnDisconnected;
        FOVPNIP := '0.0.0.0';
        WriteIPToRegistry;
      end;
  finally
    AdapterList.Free;
  end;
  FTimerAttempts := (FTimerAttempts + 1) mod 45;
  FTimer.Enabled := True;
end;

function TOpenVPNManager.GetOVPNIP: String;
{var
  AdapterList: TAdapterList;
  I: Integer;
  Flag: Boolean;}
begin
  {AdapterList := TAdapterList.Create;
  Flag := False;
  FOVPNIP := '';
  try
    for I := 0 to AdapterList.Count - 1 do
    begin
      if (Pos('TAP-Win32', AdapterList.Items[I].Description) <> 0) then
      begin
        Flag := True;
        FOVPNIP := AdapterList.Items[I].IPAddress;
        Break;
      end;
    end;
  finally
    AdapterList.Free;
  end;
  if (FOVPNIP = '') then
    FOVPNIP := 'null';}
  Result := FOVPNIP;
end;

function TOpenVPNManager.GetStatus: integer;
begin
  Result := Status;
end;

procedure Register;
begin
  //RegisterComponents('DKTigra Chat components', [TOpenVPNManager]);
  RegisterComponents('pLan Components', [TOpenVPNManager]);
end;

end.

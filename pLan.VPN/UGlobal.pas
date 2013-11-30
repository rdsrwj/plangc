// $Id$
unit UGlobal;

interface

uses
  Windows, SysUtils, Graphics, Forms, WinInet, sRichEdit;

const
  AppTitle       = 'pLan OpenVPN Edition'; // Заголовок программы.

  // IRC
  IRCHost        = 'irc.ircluxe.ru';
  IRCPort        = 6667;
  IRCMainChannel = '#plan';
  IRCUsername    = 'plangc';

  // URL's
  URLTracker     = 'http://tracker.plangc.ru/index.php';
  URLGamelist    = 'http://tracker.plangc.ru/updates/planvpn/gamelist.txt';
  //URLUpdateExe   = 'http://plangc.googlecode.com/files/pLanVPN.exe';
  URLUpdateExe   = 'http://googledrive.com/host/0B981nG4OIUoDUUlpVFFOMVRuZ2c';

type
  TChatMessage = (cmNormal, cmPrivate, cmSystem, cmMyMessage);

  function SetDebugPriveleges: Boolean;
  function GetSpecialFolder(FolderID: Longint): string;
  function IsIEOffline: Boolean;
  procedure SetIEOffline(Value: Boolean);
  function TextExtent(const Text: string; const Font: TFont): TSize;
  function MakeHash(const S: string): Integer;
  function Parse(var S: string; const Delimiter: Char = ' '): string;

type
  TWindowsVersion = (wv31, wv95, wv98, wvME, wvNT, wvY2K, wvXP, wvServer2003,
    wvVista, wvSeven);
  TWindowsVersions = set of TWindowsVersion;

  function WinVer: TWindowsVersion;

var
  AppPath: string;
  AppVersion: string;       // Отображаемая версия программы, также составляет часть HTTPGet.UserAgent
  AppBuild: string;         // Билд программы, используется при проверке обновлений.
  DataPath: string;
  HTTPAgent: string;
  URLCheckUpdates: string;

implementation

uses
  ShlObj, SHFolder;

function SetDebugPriveleges: Boolean;
var
  hToken: THandle;
  T: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
begin
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then
  begin
    try
      // Получаем LUID привилегии.
      if LookupPrivilegeValue(nil, 'SeDebugPrivilege', T.Privileges[0].Luid) then
      begin
        T.PrivilegeCount := 1;
        T.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        // Добавляем привилегию к нашему процессу.
        AdjustTokenPrivileges(hToken, False, T, SizeOf(T), T, ReturnLength);
      end;
    finally
      CloseHandle(hToken);
    end;
  end;
  Result := (GetLastError = ERROR_SUCCESS);
  {if not Result then
    raise Exception.Create(SysErrorMessage(GetLastError));}
end;

function GetSpecialFolder(FolderID: Longint): string;
var
  Path: PChar;
  idList: PItemIDList;
begin
  GetMem(Path, MAX_PATH);
  SHGetSpecialFolderLocation(0, FolderID, idList);
  SHGetPathFromIDList(idList, Path);
  Result := string(Path);
  FreeMem(Path);
end;

// Проверка автономного режима IE.
function IsIEOffline: Boolean;
var
  State, Sz: DWORD;
begin
  Result := False;
  State := 0;
  Sz := SizeOf(State);
  if InternetQueryOption(nil, INTERNET_OPTION_CONNECTED_STATE, @State, Sz) then
    Result := (State and INTERNET_STATE_DISCONNECTED_BY_USER) <> 0;
end;

// Установка автономного режима IE.
procedure SetIEOffline(Value: Boolean);
var
  CI: TInternetConnectedInfo;
  Sz: DWORD;
begin
  Sz := SizeOf(CI);
  if Value then
  begin
    CI.dwConnectedState := INTERNET_STATE_DISCONNECTED_BY_USER;
    CI.dwFlags := ISO_FORCE_DISCONNECTED;
  end
  else
  begin
    CI.dwConnectedState := INTERNET_STATE_CONNECTED;
    CI.dwFlags := 0;
  end;
  InternetSetOption(nil, INTERNET_OPTION_CONNECTED_STATE, @CI, Sz);
end;

function TextExtent(const Text: string; const Font: TFont): TSize;
var
  DC: HDC;
  //SaveFont: HFONT;
begin
  {DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextExtentPoint32(DC, PChar(Text), Length(Text), Result);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);}
  DC := CreateCompatibleDC(0);
  SelectObject(DC, Font.Handle);
  GetTextExtentPoint32(DC, PChar(Text), Length(Text), Result);
  DeleteDC(DC);
end;

function MakeHash(const S: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(S) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(S[I]);
end;

var
  SaveWinVer: Byte = $FF;

function WinVer: TWindowsVersion;
var
  MajorVersion, MinorVersion: Byte;
  dwVersion: Integer;
begin
  if (SaveWinVer <> $FF) then
    Result := TWindowsVersion(SaveWinVer)
  else
  begin
    dwVersion := GetVersion;
    MajorVersion := LoByte(dwVersion);
    MinorVersion := HiByte(LoWord(dwVersion));
    if (dwVersion >= 0) then
    begin
      Result := wvNT;
      if (MajorVersion >= 6) then
      begin
        if (MinorVersion >= 1) then
          Result := wvSeven
        else
          Result := wvVista;
      end
      else
      begin
        if (MajorVersion >= 5) then
          if (MinorVersion >= 1) then
          begin
            Result := wvXP;
            if (MinorVersion >= 2) then
              Result := wvServer2003;
          end
          else
            Result := wvY2K;
      end;
    end
    else
    begin
      Result := wv95;
      if (MajorVersion > 4) or
         (MajorVersion = 4) and (MinorVersion >= 10)  then
      begin
        Result := wv98;
        if (MajorVersion = 4) and (MinorVersion >= $5A) then
          Result := wvME;
      end
      else
      if MajorVersion <= 3 then
        Result := wv31;
    end;
    SaveWinVer := Ord(Result);
  end;
end;

function GetBuildInfoString(var Major, Minor, Rev, Build: Word): string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  Major := 0;
  Minor := 0;
  Rev := 0;
  Build := 0;
  Result := '';
  VerInfoSize := GetFileVersionInfoSize(PChar(Application.ExeName), Dummy);
  if (VerInfoSize > 0) then
  begin
    GetMem(VerInfo, VerInfoSize);
    try
      if GetFileVersionInfo(PChar(Application.ExeName), 0, VerInfoSize,
        VerInfo) then
      begin
        if VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize) then
        begin
          with VerValue^ do
          begin
            Major := dwFileVersionMS shr 16;
            Minor := dwFileVersionMS and $FFFF;
            Rev   := dwFileVersionLS shr 16;
            Build := dwFileVersionLS and $FFFF;
          end;
          //Result := Format('%d.%d.%d.%d', [Major, Minor, Rev, Build]);
          Result := Format('%d.%d build %d', [Major, Minor, Build]);
        end;
      end;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  end;
end;

function Parse(var S: string; const Delimiter: Char = ' '): string;
var
  P: Integer;
begin
  P := Pos(Delimiter, S);
  if (P <> 0) then
  begin
    Result := Copy(S, 1, P - 1);
    S := Copy(S, P + 1, Length(S));
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

var
  Major, Minor, Rev, Build: Word;

initialization

  AppVersion := GetBuildInfoString(Major, Minor, Rev, Build);

  AppBuild := IntToStr(Build);

  AppPath := IncludeTrailingBackSlash(ExtractFilePath(Application.ExeName));

  DataPath := IncludeTrailingBackSlash(GetSpecialFolder(CSIDL_LOCAL_APPDATA))
    + 'pLan\';
  if not ForceDirectories(DataPath) then
    DataPath := AppPath;

  HTTPAgent := 'pLan ' + AppVersion;

  URLCheckUpdates := URLTracker + '?do=checkupdates&build=' + AppBuild;

end.

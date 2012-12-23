// $Id$
unit UGlobal;

interface

uses
  Windows, SysUtils, Graphics, Forms, WinInet, sRichEdit;

const
  AppTitle       = 'pLan OpenVPN Edition'; // Заголовок программы.
  AppVersion     = '0.6.62';               // Отображаемая версия программы, также составляет часть HTTPGet.UserAgent
  AppBuild       = 62;                     // Билд программы, используется при проверке обновлений.

  // IRC
  IRCHost        = 'irc.ircluxe.ru';
  IRCPort        = 6667;
  IRCMainChannel = '#plan';
  IRCUsername    = 'plangc';

  // URL's
  URLTracker     = 'http://tracker.plangc.ru/index.php';
  URLGamelist    = 'http://tracker.plangc.ru/updates/planvpn/gamelist.txt';
  URLUpdateExe   = 'http://tracker.plangc.ru/updates/planvpn/pLan_openvpn.exe';

type
  TChatMessage = (cmNormal, cmPrivate, cmSystem, cmMyMessage);

  function SetDebugPriveleges: Boolean;
  function GetSpecialFolder(FolderID: Longint): String;
  function IsIEOffline: Boolean;
  procedure SetIEOffline(Value: Boolean);
  function TextExtent(const Text: String; const Font: TFont): TSize;
  function MakeHash(const S: String): Integer;

type
  TWindowsVersion = (wv31, wv95, wv98, wvME, wvNT, wvY2K, wvXP, wvServer2003,
    wvVista, wvSeven);
  TWindowsVersions = set of TWindowsVersion;

  function WinVer: TWindowsVersion;

var
  AppPath: String;
  DataPath: String;
  HTTPAgent: String;
  URLCheckUpdates: String;

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

function GetSpecialFolder(FolderID: Longint): String;
var
  Path: PChar;
  idList: PItemIDList;
begin
  GetMem(Path, MAX_PATH);
  SHGetSpecialFolderLocation(0, FolderID, idList);
  SHGetPathFromIDList(idList, Path);
  Result := String(Path);
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

function TextExtent(const Text: String; const Font: TFont): TSize;
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

function MakeHash(const S: String): Integer;
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

initialization

  AppPath := IncludeTrailingBackSlash(ExtractFilePath(Application.ExeName));

  DataPath := IncludeTrailingBackSlash(GetSpecialFolder(CSIDL_LOCAL_APPDATA))
    + 'pLan\';
  if not ForceDirectories(DataPath) then
    DataPath := AppPath;

  HTTPAgent := 'pLan ' + AppVersion;

  URLCheckUpdates := URLTracker + '?do=checkupdates&build=' +
    IntToStr(AppBuild);

end.

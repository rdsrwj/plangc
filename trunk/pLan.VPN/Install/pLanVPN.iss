#define AppName		"pLan OpenVPN Edition"
#define AppExe		"pLan_openvpn.exe"
#define AppExePath	'..\Release\' + AppExe
#define AppVersion	GetFileVersion(AppExePath);

#define MyGetSuffix() \
	ParseVersion(AppExePath, Local[0], Local[1], Local[2], Local[3]), \
	Str(Local[0]) + "." + Str(Local[1]) + "." + Str(Local[3]);

#define OpenVPNExe	"openvpn-2.2.2-install.exe"

[Setup]
AppId={{9847EA48-5214-49CE-8A54-F027FDA37F05}
AppName="{#AppName}"
AppPublisher="pLan DevTeam"
AppPublisherURL="http://plangc.ru/"
AppVerName="{#AppName}"
DefaultDirName="{pf}\pLan"
DefaultGroupName="{#AppName}"
OutputBaseFilename="pLanVPN-{#MyGetSuffix()}"
OutputDir="."
SetupIconFile="setup-icon.ico"
Uninstallable="yes"
UninstallDisplayIcon="{app}\{#AppExe}"
UninstallFilesDir="{app}"
UsePreviousLanguage="no"
VersionInfoCopyright="pLan DevTeam"
VersionInfoVersion="{#AppVersion}"
WizardImageFile="setup-image.bmp"
WizardSmallImageFile="compiler:WizModernSmallImage-IS.bmp"

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl";
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl";
Name: "ge"; MessagesFile: "compiler:Languages\German.isl";
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl";

[Types]
Name: "full"; Description: "{code:GetFullInstallation}"
Name: "compact"; Description: "{code:GetCompactInstallation}"
Name: "custom"; Description: "{code:GetCustomInstallation}"; Flags: iscustom

[Components]
Name: "program"; Description: "Program Files"; Types: full compact custom; Flags: fixed
Name: "skins"; Description: "Skins"; Types: full

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"
Name: "openvpn"; Description: "Install OpenVPN 2.2.2"
Name: "teamspeak"; Description: "Download TeamSpeak 3 Client"

[Files]
Source: "..\Release\Languages\*"; DestDir: "{app}\Languages"; Components: "program"; Flags: ignoreversion
Source: "..\Release\Skins\*"; DestDir: "{app}\Skins"; Components: "skins"; Flags: ignoreversion
Source: "..\Release\BindIP.dll"; DestDir: "{sys}"; Components: "program"; Flags: onlyifdoesntexist
Source: "..\Release\ForceBindIP.exe"; DestDir: "{app}"; Components: "program"; Flags: ignoreversion
Source: "..\Release\pLan_openvpn.exe"; DestDir: "{app}"; Components: "program"; Flags: ignoreversion
Source: "{#OpenVPNExe}"; DestDir: "{tmp}"; Flags: dontcopy
Source: "openvpn.cer"; DestDir: "{tmp}"; Flags: dontcopy
Source: "isxdl.dll"; DestDir: "{tmp}"; Flags: dontcopy

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{userdesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: "desktopicon"

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: postinstall nowait skipifsilent

[Code]
function isxdl_Download(hWnd: Integer; URL, Filename: PAnsiChar): Integer;
	external 'isxdl_Download@files:isxdl.dll stdcall';

procedure isxdl_AddFile(URL, Filename: PAnsiChar);
	external 'isxdl_AddFile@files:isxdl.dll stdcall';

procedure isxdl_AddFileSize(URL, Filename: PAnsiChar; Size: Cardinal);
	external 'isxdl_AddFileSize@files:isxdl.dll stdcall';

function isxdl_DownloadFiles(hWnd: Integer): Integer;
	external 'isxdl_DownloadFiles@files:isxdl.dll stdcall';

procedure isxdl_ClearFiles;
	external 'isxdl_ClearFiles@files:isxdl.dll stdcall';

function isxdl_IsConnected: Integer;
	external 'isxdl_IsConnected@files:isxdl.dll stdcall';

function isxdl_SetOption(Option, Value: PAnsiChar): Integer;
	external 'isxdl_SetOption@files:isxdl.dll stdcall';

function isxdl_GetFileName(URL: PAnsiChar): PAnsiChar;
	external 'isxdl_GetFileName@files:isxdl.dll stdcall';

procedure CurStepChanged(CurStep: TSetupStep);
var
	Version: TWindowsVersion;
	ResultCode: Integer;
	ts3url, ts3path: string;
begin
	if (CurStep = ssInstall) then
	begin
		if (Pos('openvpn', WizardSelectedTasks(False)) > 0) then
		begin
			GetWindowsVersionEx(Version);
			// Windows 7 version is 6.1 (workstation)
			if (Version.Major = 6)  and (Version.Minor = 1) and (Version.ProductType = VER_NT_WORKSTATION) then
			begin
				// Install certificate.
				ExtractTemporaryFile(ExpandConstant('openvpn.cer'));
				Exec('certutil.exe', '-addstore TrustedPublisher "' + ExpandConstant('{tmp}\openvpn.cer') + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
			end;
			// Install OpenVPN.
			ExtractTemporaryFile(ExpandConstant('{#OpenVPNExe}'));
			Exec(ExpandConstant('{tmp}\{#OpenVPNExe}'), '/S', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
		end;
		// Download and install TeamSpeak 3.
		if (Pos('teamspeak', WizardSelectedTasks(False)) > 0) then
		begin
			if not IsWin64 then
				ts3url := 'http://plangc.googlecode.com/files/TeamSpeak3_x86.exe'
			else
				ts3url := 'http://plangc.googlecode.com/files/TeamSpeak3_x64.exe';
			ts3path := ExpandConstant('{win}\Temp\TeamSpeak3.exe');
			if not FileExists(ts3path) then
			begin
				isxdl_AddFile(ts3url, ts3path);
				isxdl_DownloadFiles(WizardForm.Handle);
			end;
			Exec(ts3path, '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
		end;
	end;
end;

function GetFullInstallation(Param: string): string;
begin
	Result := SetupMessage(msgFullInstallation);
end;

function GetCustomInstallation(Param: string): string;
begin
	Result := SetupMessage(msgCustomInstallation);
end;

function GetCompactInstallation(Param: string): string;
begin
	Result := SetupMessage(msgCompactInstallation);
end;
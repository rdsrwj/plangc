#define AppName			"pLan OpenVPN Edition"
#define AppExeName		"pLan_openvpn.exe"
#define AppVersion		GetFileVersion('..\Release\pLan_openvpn.exe')
#define OpenVPNExeName	"openvpn-2.2.2-install.exe"

[Setup]
AppName="{#AppName}"
AppPublisher="pLan DevTeam"
AppPublisherURL=http://plangc.ru/
AppVerName="{#AppName}"
DefaultDirName="{pf}\pLan"
DefaultGroupName="{#AppName}"
OutputBaseFilename="pLanVPN-{#AppVersion}"
OutputDir="."
;PrivilegesRequired="none"
SetupIconFile="setup-icon.ico"
Uninstallable="yes"
UninstallDisplayIcon="{app}\{#AppExeName}"
UninstallFilesDir="{app}"
UsePreviousLanguage="no"
VersionInfoCopyright="pLan DevTeam"
VersionInfoVersion="{#AppVersion}"
WizardImageFile="setup-image.bmp"
WizardSmallImageFile="compiler:WizModernSmallImage-IS.bmp"

[Tasks]
Name: "desktopicon";	Description: "{cm:CreateDesktopIcon}"
Name: "openvpn";		Description: "Install OpenVPN 2.2.2"

[Files]
Source: "..\Release\Languages\*";		DestDir: "{app}\Languages";	Flags: ignoreversion
Source: "..\Release\Skins\*";			DestDir: "{app}\Skins";		Flags: ignoreversion
Source: "..\Release\BindIP.dll";		DestDir: "{sys}";			Flags: onlyifdoesntexist
Source: "..\Release\ForceBindIP.exe";	DestDir: "{app}";			Flags: ignoreversion
Source: "..\Release\pLan_openvpn.exe";	DestDir: "{app}";			Flags: ignoreversion
Source: "{#OpenVPNExeName}";			DestDir: "{tmp}";			Flags: dontcopy

[Icons]
Name: "{group}\{#AppName}";			Filename: "{app}\{#AppExeName}";	WorkingDir: "{app}"
Name: "{userdesktop}\{#AppName}";	Filename: "{app}\{#AppExeName}";	WorkingDir: "{app}";	Tasks: "desktopicon"

[Languages]
;Name: "en";	MessagesFile: "compiler:Default.isl";			InfoBeforeFile: "info_en.rtf" 
;Name: "ru";	MessagesFile: "compiler:Languages\Russian.isl";	InfoBeforeFile: "info_ru.rtf"
Name: "en";		MessagesFile: "compiler:Default.isl";
Name: "ru";		MessagesFile: "compiler:Languages\Russian.isl";

[Run]
Filename: "{app}\{#AppExeName}";	Description: "{cm:LaunchProgram,{#AppName}}";	Flags: postinstall nowait skipifsilent

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
	ResultCode: Integer;
begin
	if (CurStep = ssPostInstall) then
	begin
		// Install OpenVPN.
		if (Pos('openvpn', WizardSelectedTasks(False)) > 0) then
		begin
			ExtractTemporaryFile(ExpandConstant('{#OpenVPNExeName}'));
			Exec(ExpandConstant('{tmp}\{#OpenVPNExeName}'), '/S', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
		end;
	end;
end;
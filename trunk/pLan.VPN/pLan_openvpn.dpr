// $Id$
program pLan_openvpn;

{$R 'Resources\manifest.res' 'Resources\manifest.rc'}

uses
  Windows,
  Forms,
  PsAPI,
  Registry,
  SysUtils,
  UGlobal in 'UGlobal.pas',
  USettings in 'USettings.pas',
  ULanguage in 'ULanguage.pas',
  ChatServer in 'Components\ChatServer.pas',
  OpenVPNManager in 'Components\OpenVPNManager.pas',
  AdaptItems in 'AdaptItems.pas',
  PrevInst in 'PrevInst.pas',
  frmMain in 'frmMain.pas' {MainForm},
  frmCreateRoom in 'frmCreateRoom.pas' {CreateRoomForm},
  frmConfig in 'frmConfig.pas' {ConfigForm},
  frmUpdateProgram in 'frmUpdateProgram.pas' {UpdateForm},
  frmOVPNInit in 'frmOVPNInit.pas' {OVPNInitForm},
  frmFileOpen in 'frmFileOpen.pas' {FileOpenForm},
  frmDetailedError in 'frmDetailedError.pas' {DetailedErrorForm},
  frmAbout in 'frmAbout.pas' {AboutForm};

{$R *.res}

procedure WaitForTermination;
var
  Procs: array[0..$FFF] of THandle;
  ProcsCount: Cardinal;
  I: Integer;
  PH: THandle;
  S: string;
  Sz: Integer;
begin
  if not EnumProcesses(@Procs, SizeOf(Procs), ProcsCount) then Exit;
  ProcsCount := ProcsCount div SizeOf(THandle);
  for I := 0 to ProcsCount - 1 do
  begin
    PH := OpenProcess(PROCESS_ALL_ACCESS, False, Procs[I]);
    if (PH <> INVALID_HANDLE_VALUE) and (Procs[I] <> GetCurrentProcessId)then
    begin
      SetLength(S, MAX_PATH);
      Sz := GetModuleBaseName(PH, 0, @S[1], MAX_PATH);
      SetLength(S, Sz);
      if (Pos('pLan_openvpn.exe', S) <> 0) then
      begin
        TerminateProcess(PH, 0);
        WaitForSingleObject(PH, INFINITE);
      end;
      CloseHandle(PH);
    end;
  end;
end;

var
  S: string;
begin
  Application.Initialize;
  Application.Title := 'pLan OpenVPN Edition';

  SetCurrentDir(UGlobal.AppPath);

  // Повышаем привелегии.
  SetDebugPriveleges;

   // Выводим IE из автономного режима.
  if IsIEOffline then
    SetIEOffline(False);

  // Загружаем настройки.
  Settings := TSettings.Create;
  Settings.Load;

  // Загружаем язык.
  Language := TLanguage.Create;
  Language.Load(Settings.LanguageName);

  // Проверяем: первая ли копия программы?
  if InitInstance then
  begin
    try
      UpdateForm := TUpdateForm.Create(nil);
      try
        UpdateForm.ShowModal;
      finally
        UpdateForm.Free;
      end;
    except
    end;
  end
  else
  begin
    if (ParamCount >= 1) and (ParamStr(1) = 'FetchUpdate') then
    begin
      // Завершаем предыдущую копию программы.
      WaitForTermination;

      // Удаляем резервную копию.
      S := ChangeFileExt(Application.ExeName, '.bak');
      if FileExists(S) then
      try
        DeleteFile(S);
      except
      end;
    end
    else
    begin
      // В ином случае завершаем работу текущей копии программы.
      Halt(0);
    end;  
  end;

  Randomize;

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

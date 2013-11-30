// $Id$
unit frmUpdateProgram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, HTTPGet, ComCtrls, StdCtrls;

type
  TUpdateForm = class(TForm)
    ProgressBar1: TProgressBar;
    HTTPGet1: THTTPGet;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure HTTPGet1DoneString(Sender: TObject; Result: string);
    procedure HTTPGet1Error(Sender: TObject);
    procedure HTTPGet1Progress(Sender: TObject; TotalSize, Readed: Integer);
    procedure HTTPGet1DoneFile(Sender: TObject; FileName: string;
      FileSize: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    Requesting: Boolean;
    NeedToUpdateExe: Boolean;
    NeedToUpdateGameList: Boolean;
  public
    { Public declarations }
    GameListVersion: Integer;    
  end;

var
  UpdateForm: TUpdateForm;
  GameListVersion: Integer;
  
implementation

uses
  IniFiles, ShellAPI, UGlobal, frmConfig, ULanguage;

{$R *.dfm}

procedure TUpdateForm.FormCreate(Sender: TObject);
var
  R: TRect;
begin
  Language.Apply(Self);

  // Устанавливаем позицию формы - внизу экрана.
  SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0);
  Self.Position := poDesigned;
  Self.Top := R.Bottom - Self.Height;
  Self.Left := R.Right - Self.Width;

  NeedToUpdateExe := False;
  NeedToUpdateGameList := False;

  // Проверяем обновления.
  Requesting := True;
  Label1.Caption := Language.msgRetrievingVersion;
  HTTPGet1.Agent := UGlobal.HTTPAgent;
  HTTPGet1.URL := UGlobal.URLCheckUpdates;
  HTTPGet1.GetString;
end;

procedure TUpdateForm.HTTPGet1DoneString(Sender: TObject; Result: string);
var
  SL: TStringList;
  Ini: TIniFile;
begin
  Requesting := False;
  ProgressBar1.Position := 100;

  if (Pos('checkupdates', HTTPGet1.URL) <> 0) then
  begin
    SL := TStringList.Create;
    try
      SL.Text := Result;

      if (SL.Count < 2) then Exit;

      NeedToUpdateExe := (StrToInt(UGlobal.AppBuild) < StrToIntDef(SL[0], 0));

      Ini := TIniFile.Create(UGlobal.DataPath + 'config.ini');
      try
        GameListVersion := Ini.ReadInteger('General', 'GameListVersion', 0);
      finally
        Ini.Free;
      end;

      if (GameListVersion < StrToIntDef(SL[1], 0)) or
        (not FileExists(UGlobal.DataPath + 'gamelist.txt')) then
      begin
        NeedToUpdateGameList := True;
        GameListVersion := StrToInt(SL[1]);
      end;

    finally
      SL.Free;
    end;

    if (not NeedToUpdateGameList) and (not NeedToUpdateExe) then
    begin
      Sleep(2000);
      Self.Close;
    end
    else
      Timer1.Enabled := True;
  end
  else
  if (Pos('gamelist.txt', HTTPGet1.URL) <> 0) then
  begin
    SL := TStringList.Create;
    try
      SL.Text := Result;
      SL.SaveToFile(UGlobal.DataPath + 'gamelist.txt');
    finally
      SL.Free;
    end;

    Ini := TIniFile.Create(UGlobal.DataPath + 'config.ini');
    try
      Ini.WriteInteger('General', 'GameListVersion', GameListVersion);
    finally
      Ini.Free;
    end;

    if not NeedToUpdateExe then
    begin
      Sleep(2000);
      Self.Close;
    end
    else
      Timer1.Enabled := True;
  end;
end;

procedure TUpdateForm.HTTPGet1Error(Sender: TObject);
begin
  Self.Caption := 'Error';
  Requesting := False;
  Application.MessageBox(PChar('Error occured'), PChar('Error'));
  Self.Close;
end;

procedure TUpdateForm.HTTPGet1Progress(Sender: TObject; TotalSize,
  Readed: Integer);
begin
  if (TotalSize <> 0) then
    ProgressBar1.Position := Smallint(Round(Readed * 100 / TotalSize));
end;

procedure TUpdateForm.HTTPGet1DoneFile(Sender: TObject; FileName: string;
  FileSize: Integer);
begin
  ProgressBar1.Position := 100;

  ShellExecute(Application.Handle, 'open', PChar(FileName), nil, nil,
    SW_NORMAL);

  Requesting := False;
end;

procedure TUpdateForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  if NeedToUpdateGameList then
  begin
    NeedToUpdateGameList := False;

    // Запрашиваем список игр.
    Requesting := True;
    Label1.Caption := Language.msgUpdatingGameList;
    HTTPGet1.URL := UGlobal.URLGamelist;
    HTTPGet1.GetString;
  end
  else
  if NeedToUpdateExe then
  begin
    NeedToUpdateExe := False;

    // Запрашиваем файл.
    Requesting := True;
    Label1.Caption := Language.msgUpdatingProgram;
    HTTPGet1.URL := UGlobal.URLUpdateExe;
    HTTPGet1.BinaryData := True;
    HTTPGet1.FileName := DataPath + 'pLanVPN-setup.exe';
    HTTPGet1.GetFile;
  end
  else
  begin
    Self.Close;
  end;
end;

procedure TUpdateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Requesting then
    Halt;
end;

procedure TUpdateForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

end.

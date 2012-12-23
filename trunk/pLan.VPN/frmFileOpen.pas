// $Id$
unit frmFileOpen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellAPI, sLabel, sEdit, sButton, sCheckBox,
  sDialogs, sGroupBox, sComboBox;

type
  TFileOpenForm = class(TForm)
    LblCaption: TsLabel;
    LblFileName: TsLabel;
    Image: TImage;
    EdFile: TsEdit;
    EdProcessToInject: TsEdit;
    Button1: TsButton;
    Button2: TsButton;
    BtnOK: TsButton;
    BtnCancel: TsButton;
    ChkInjectIntoProcess: TsCheckBox;
    ChkWaitAWhile: TsCheckBox;
    sOpenDialog1: TsOpenDialog;
    ChkCompatibility: TsCheckBox;
    sGroupBox1: TsGroupBox;
    ChkUseForceBindIP: TsCheckBox;
    CbCaption: TsComboBox;
    procedure BtnOKClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChkInjectIntoProcessClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ChkUseForceBindIPClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  Registry, UGlobal, frmConfig, ULanguage;

procedure TFileOpenForm.FormCreate(Sender: TObject);
begin
  Language.Apply(Self);
  CbCaption.Sorted := True;
  CbCaption.Items.LoadFromFile(UGlobal.DataPath + 'gamelist.txt');
end;

procedure TFileOpenForm.FormShow(Sender: TObject);
var
  Reg: TRegistry;
  SL: TStringList;
  Dummy: Integer;
  phIconLarge, phIconSmall: ^HICON;
  IconCount: Integer;
  Ico: TIcon;
begin
  if (EdFile.Text <> '') and (WinVer >= wvVista) then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', False) then
      begin
        SL := TStringList.Create;
        try
          Reg.GetValueNames(SL);
          ChkCompatibility.Checked := SL.Find(EdFile.Text, Dummy);
        finally
          SL.Free;
        end;
      end;
    finally
      Reg.Free;
    end;
  end;

  if (EdFile.Text <> '' ) then
  begin
    IconCount := ExtractIconEx(PChar(EdFile.Text), -1, phIconLarge^,
      phIconLarge^, 0);
    if (IconCount > 0) then
    begin
      GetMem(phIconLarge, SizeOf(HICON));
      GetMem(phIconSmall, SizeOf(HICON));
      ExtractIconEx(PChar(EdFile.Text), 0, phIconLarge^, phIconSmall^, 1);
      Ico := TIcon.Create;
      if (phIconLarge^ <> 0) then
        Ico.Handle := phIconLarge^
      else
         Ico.Handle := phIconSmall^;
      try
        Image.Picture.Icon := Ico;
      finally
        FreeMem(phIconLarge);
        FreeMem(phIconSmall);
      end;
    end;
  end;

  ChkInjectIntoProcessClick(nil);
  ChkUseForceBindIPClick(nil);
end;

procedure TFileOpenForm.BtnOKClick(Sender: TObject);
var
  Reg: TRegistry;
begin
  // Выставляем режим совместимости.
  if (WinVer >= wvVista) then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', True) then
      begin
        if ChkCompatibility.Checked then
        begin
          if not Reg.ValueExists(EdFile.Text) then
            Reg.WriteString(EdFile.Text, 'WINXPSP3');
        end
        else
        begin
          Reg.DeleteValue(EdFile.Text);
        end;
      end;
    finally
      Reg.Free;
    end;
  end;
  ModalResult := mrOK;
end;

procedure TFileOpenForm.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFileOpenForm.Button1Click(Sender: TObject);
var
  phIconLarge, phIconSmall: ^HICON;
  IconCount: Integer;
  Ico: TIcon;
begin
  if sOpenDialog1.Execute then
  begin
    EdFile.Text := sOpenDialog1.FileName;
    IconCount := ExtractIconEx(PChar(EdFile.Text), -1, phIconLarge^,
      phIconLarge^, 0);
    if (IconCount > 0) then
    begin
      GetMem(phIconLarge, SizeOf(HICON));
      GetMem(phIconSmall, SizeOf(HICON));
      ExtractIconEx(PChar(EdFile.Text), 0, phIconLarge^, phIconSmall^, 1);
      Ico := TIcon.Create;
      if (phIconLarge^ <> 0) then
        Ico.Handle := phIconLarge^
      else
         Ico.Handle := phIconSmall^;
      try
        Image.Picture.Icon := Ico;
      finally
        FreeMem(phIconLarge);
        FreeMem(phIconSmall);
      end;
    end;
  end;
end;

procedure TFileOpenForm.Button2Click(Sender: TObject);
begin
  if sOpenDialog1.Execute then
    EdProcessToInject.Text := sOpenDialog1.FileName;
end;

procedure TFileOpenForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFileOpenForm.ChkInjectIntoProcessClick(Sender: TObject);
begin
  EdProcessToInject.Enabled := ChkInjectIntoProcess.Enabled and
    ChkInjectIntoProcess.Checked;
  Button2.Enabled := ChkInjectIntoProcess.Enabled and
    ChkInjectIntoProcess.Checked;
  ChkWaitAWhile.Enabled := ChkInjectIntoProcess.Enabled and
    ChkInjectIntoProcess.Checked;
end;

procedure TFileOpenForm.ChkUseForceBindIPClick(Sender: TObject);
begin
  ChkInjectIntoProcess.Enabled := ChkUseForceBindIP.Checked;
  ChkInjectIntoProcessClick(nil);
end;

end.

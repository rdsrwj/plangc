unit FileLauncher;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls;

type
  TFileLauncher = class(TObject)
  public
    Caption: String;
    LaunchString: String;
    IconName: String;
    UseForceBindIP: Boolean;
    InjectIntoProcess: Boolean;
    InjectName: String;
    WaitAWhile: Boolean;
  end;

  TFileLauncherList = class(TList)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    function GetItem(Index: Integer): TFileLauncher;
    procedure Delete(Index: Integer);
    property Item[Index: Integer]: TFileLauncher read GetItem;
  end;

implementation

uses
  IniFiles, UGlobal;

{ TFileLauncherList }

constructor TFileLauncherList.Create;
begin
  inherited Create;
end;

destructor TFileLauncherList.Destroy;
begin
  while (Count > 0) do Delete(Count - 1);
  inherited;
end;

procedure TFileLauncherList.Load;
var
  Ini: TIniFile;
  I: Integer;
  ItemCount: Integer;
  AItem: TFileLauncher;
  S: String;
begin
  Ini := TIniFile.Create(UGlobal.DataPath + 'config.ini');
  try
    Self.Clear;
    ItemCount := Ini.ReadInteger('General', 'FileManagerCount', 0);
    for I := 0 to ItemCount - 1 do
    begin
      S := 'Launch_' + IntToStr(I);
      AItem := TFileLauncher.Create;
      AItem.Caption := Ini.ReadString(S, 'Caption', '');
      AItem.LaunchString := Ini.ReadString(S, 'LaunchString', '');
      AItem.IconName := Ini.ReadString(S, 'IconName', '');
      AItem.UseForceBindIP := Ini.ReadBool(S, 'UseForceBindIP', False);
      AItem.InjectIntoProcess := Ini.ReadBool(S, 'InjectIntoProcess', True);
      AItem.InjectName := Ini.ReadString(S, 'InjectName', '');
      AItem.WaitAWhile := Ini.ReadBool(S, 'WaitAWhile', False);
      Add(AItem);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TFileLauncherList.Save;
var
  Ini: TIniFile;
  I: Integer;
  S: String;
begin
  Ini := TIniFile.Create(UGlobal.DataPath + 'config.ini');
  try
    Ini.WriteInteger('General', 'FileManagerCount', Count);
    for I := 0 to Count - 1 do
    begin
      S := 'Launch_' + IntToStr(I);
      Ini.WriteString(S, 'Caption', Item[I].Caption);
      Ini.WriteString(S, 'LaunchString', Item[I].LaunchString);
      Ini.WriteString(S, 'IconName', Item[I].IconName);
      Ini.WriteBool(S, 'UseForceBindIP', Item[I].UseForceBindIP);
      Ini.WriteBool(S, 'InjectIntoProcess', Item[I].InjectIntoProcess);
      Ini.WriteString(S, 'InjectName', Item[I].InjectName);
      Ini.WriteBool(S, 'WaitAWhile', Item[I].WaitAWhile);
    end;
  finally
    Ini.Free;
  end;
end;

function TFileLauncherList.GetItem(Index: Integer): TFileLauncher;
begin
  Result := TFileLauncher(Get(Index));
end;

procedure TFileLauncherList.Delete(Index: Integer);
begin
  Item[Index].Free;
  inherited Delete(Index);
end;

end.
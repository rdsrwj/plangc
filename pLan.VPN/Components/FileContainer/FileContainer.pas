// $Id$
unit FileContainer;

interface

uses
  Windows, SysUtils, Classes;

type
  { Для создания редактора используется специализированный тип string. }
  TFileNameString = type String;

  TFileContainer = class(TComponent)
  private
    FData: Pointer;
    FDataSize: Integer;
    FFileName: TFileNameString;
    procedure SetFileName(const Value: TFileNameString);
    procedure WriteData(Stream: TStream);
    procedure ReadData(Stream: TStream);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    destructor Destroy; override;
    function Empty: Boolean;
    function Equal(Container: TFileContainer): Boolean;
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(S: TStream);
    procedure SaveToFile(const FileName: String);
    procedure SaveToStream(S: TStream);
    procedure CheckAndSaveToFile(AFileName: String);
  published
    property FileName: TFileNameString read FFileName write SetFileName;
  end;

implementation

{ TFileContainer }

destructor TFileContainer.Destroy;
begin
  if not Empty then
    FreeMem(FData, FDataSize);
  inherited Destroy;
end;

function StreamsEqual(S1, S2: TMemoryStream): Boolean;
begin
  Result := (S1.Size = S2.Size) and
    CompareMem(S1.Memory, S2.Memory, S1.Size);
end;

procedure TFileContainer.DefineProperties(Filer: TFiler);

  {function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
      Result := not (Filer.Ancestor is TFileContainer) or
        not Equal(TFileContainer(Filer.Ancestor))
    else
      Result := not Empty;
  end;}

begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadData, WriteData, {DoWrite}True);
end;

function TFileContainer.Empty: Boolean;
begin
  Result := FDataSize = 0;
end;

function TFileContainer.Equal(Container: TFileContainer): Boolean;
var
  S1, S2: TMemoryStream;
begin
  Result := (Container <> nil) and (ClassType = Container.ClassType);
  if Empty or Container.Empty then
  begin
    Result := Empty and Container.Empty;
    Exit;
  end;
  if Result then
  begin
    S1 := TMemoryStream.Create;
    try
      SaveToStream(S1);
      S2 := TMemoryStream.Create;
      try
        Container.SaveToStream(S2);
        Result := StreamsEqual(S1, S2);
      finally
        S2.Free;
      end;
    finally
      S1.Free;
    end;
   end;
end;

{ Загружает данные из файла FileName. Обратите внимание: эта
процедура не присваивает значения свойству FileName. }
procedure TFileContainer.LoadFromFile(const FileName: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

{ Загружает данные из потока S. Эта процедура освобождает
память, выделенную перед этим для FData. }
procedure TFileContainer.LoadFromStream(S: TStream);
begin
  if not Empty then
    FreeMem(FData, FDataSize);
  FDataSize := 0;
  FData := AllocMem(S.Size);
  FDataSize := S.Size;
  S.Read(FData^, FDataSize);
end;

{ Считывает данные из потока DFM. }
procedure TFileContainer.ReadData(Stream: TStream);
begin
  LoadFromStream(Stream);
end;

{ Сохраняет данные в файл FileName. }
procedure TFileContainer.SaveToFile(const FileName: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TFileContainer.CheckAndSaveToFile(AFileName: String);
var
  FS: TFileStream;
  Flag: Boolean;
  S: String;
begin
  Flag := True;
  if FileExists(AFileName) then
  begin
    FS := TFileStream.Create(AFileName, fmOpenRead);
    try
      if (FS.Size = FDataSize) then
        Flag := False;
    finally
      FS.Free;
    end;
  end;
  if Flag then
  begin
    try
      SaveToFile(AFileName);
    except
      S := ChangeFileExt(AFileName, '.bak');
      MoveFileEx(PChar(AFileName), PChar(S), MOVEFILE_WRITE_THROUGH +
        MOVEFILE_REPLACE_EXISTING);
      SaveToFile(AFileName);
    end;
  end;
end;

{ Сохраняет данные в поток S. }
procedure TFileContainer.SaveToStream(S: TStream);
begin
  if not Empty then
    S.Write(FData^, FDataSize);
end;

{ Метод записи свойства FileName. Этот метод отвечает за установку
свойства FileName и загрузку данных из файла Value. }
procedure TFileContainer.SetFileName(const Value: TFileNameString);
begin
  if (Value <> '') then
  begin
    FFileName := ExtractFileName(Value);
    { Не загружать из файла при загрузке из потока DFM, так
    как поток DFM уже содержит данные. }
    if (not (csLoading in ComponentState)) and FileExists(Value) then
      LoadFromFile(Value);
  end
  else
  begin
    { Если строка Value пуста, то необходимо освободить память,
    выделенную для данных. }
    FFileName := '';
    if not Empty then
      FreeMem(FData, FDataSize);
    FDataSize := 0;
  end;
end;

{ Записывает данные в поток DFM. }
procedure TFileContainer.WriteData(Stream: TStream);
begin
  SaveToStream(Stream);
end;

end.
// $Id$
unit FileContainerReg;

interface

uses
  DesignIntf, DesignEditors;

type
  TFileNameStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  procedure Register;

implementation

uses
  Classes, Dialogs, FileContainer;

{ TFileNameStringProperty }

function TFileNameStringProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TFileNameStringProperty.Edit;
begin
  with TOpenDialog.Create(nil) do
  try
    Filename := GetStrValue;
    Filter := 'All files (*.*)|*.*';
    Options := Options + [ofPathMustExist, ofFileMustExist];
    if Execute then
      SetStrValue(FileName);
  finally
    Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('Custom', [TFileContainer]);
  RegisterPropertyEditor(TypeInfo(TFileNameString), nil, '',
    TFileNameStringProperty);
end;

end.

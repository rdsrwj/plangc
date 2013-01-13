// $Id$
unit frmCreateRoom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, sButton, sComboBox, sLabel, sEdit;

type
  TCreateRoomForm = class(TForm)
    EdRoomName: TsEdit;
    LblRoomName: TsLabel;
    LblGameName: TsLabel;
    CbGameName: TsComboBox;
    BtnOK: TsButton;
    BtnCancel: TsButton;
    LblRoomChannel: TsLabel;
    EdRoomChannel: TsEdit;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure CbGameNameKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EdRoomChannelKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  UGlobal, frmConfig, ULanguage;

procedure TCreateRoomForm.FormCreate(Sender: TObject);
begin
  Language.Apply(Self);
  CbGameName.Sorted := True;
  CbGameName.Items.LoadFromFile(UGlobal.DataPath + 'gamelist.txt');
end;

procedure TCreateRoomForm.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCreateRoomForm.BtnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TCreateRoomForm.CbGameNameKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9', 'A'..'Z', 'a'..'z', '_', ' ': begin end;
    #13: BtnOK.OnClick(Sender);
  else
    Key := #0;
  end;
end;

procedure TCreateRoomForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TCreateRoomForm.EdRoomChannelKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    '0'..'9', 'a'..'z', '_', '-', #8: begin end;
  else
    Key := #0;
  end;
end;

end.

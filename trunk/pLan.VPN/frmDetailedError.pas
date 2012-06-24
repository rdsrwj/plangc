// $Id$
unit frmDetailedError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sMemo, sButton;

type
  TDetailedErrorForm = class(TForm)
    Memo1: TsMemo;
    BtnExit: TsButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  frmConfig, ULanguage;

procedure TDetailedErrorForm.FormCreate(Sender: TObject);
begin
  Language.Apply(Self);
end;

procedure TDetailedErrorForm.BtnExitClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TDetailedErrorForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

end.

// $Id$
unit frmOVPNInit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, acProgressBar, sLabel;

type
  TOVPNInitForm = class(TForm)
    Timer1: TTimer;
    LblInit: TsLabel;
    sProgressBar1: TsProgressBar;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OVPNInitForm: TOVPNInitForm;

implementation

{$R *.dfm}

uses
  frmConfig, ULanguage;

procedure TOVPNInitForm.Timer1Timer(Sender: TObject);
begin
  sProgressBar1.Position := (sProgressBar1.Position + 1) mod
    (sProgressBar1.Max + 1);
end;

procedure TOVPNInitForm.FormShow(Sender: TObject);
begin
  sProgressBar1.Position := 0;
end;

procedure TOVPNInitForm.FormCreate(Sender: TObject);
begin
  Language.Apply(Self);
  FormStyle := fsStayOnTop;
end;

procedure TOVPNInitForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

end.

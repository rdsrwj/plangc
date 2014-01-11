// $Id$
unit frmAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FileContainer, StdCtrls, sButton, ExtCtrls, sPanel, ComCtrls,
  sRichEdit, sRichEditURL, sLabel;

type
  TAboutForm = class(TForm)
    sRichEditURL1: TsRichEditURL;
    sPanel1: TsPanel;
    sButton1: TsButton;
    FcAbout: TFileContainer;
    sLabel1: TsLabel;
    procedure FormCreate(Sender: TObject);
    procedure sButton1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

uses
  UGlobal, ULanguage;

procedure TAboutForm.FormCreate(Sender: TObject);
var
  MS: TMemoryStream;
begin
  Language.Apply(Self);

  MS := TMemoryStream.Create;
  try
    fcAbout.SaveToStream(MS);
    if (MS.Size > 0) then
    begin
      MS.Seek(0, soFromBeginning);
      sRichEditURL1.Lines.LoadFromStream(MS);
    end;
  finally
    MS.Free;
  end;

  sLabel1.Caption := UGlobal.AppTitle +  ' v' + UGlobal.AppVersion +
    ' Revision ' + UGlobal.Revision;
end;

procedure TAboutForm.sButton1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TAboutForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Self.Perform(WM_SYSCOMMAND, $F012, 0);
end;

end.

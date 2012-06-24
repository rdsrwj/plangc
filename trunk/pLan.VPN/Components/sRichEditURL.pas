// $Id$
unit sRichEditURL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, ComCtrls, ExtCtrls,
  RichEdit, sRichEdit;

type
  TOnURLClickEvent = procedure(Sender: TObject; const URL: String) of object;

  TsRichEditURL = class(TsRichEdit)
  private
    fOnURLClick: TOnURLClickEvent;
    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
  protected
    procedure DoURLClick(const URL: String);
    procedure CreateWnd; override;
  published
    property OnURLClick: TOnURLClickEvent read fOnURLClick write fOnURLClick;
  end;

  procedure Register;

implementation

uses
  ShellAPI;

procedure TsRichEditURL.DoURLClick(const URL: String);
begin
  if Assigned(FOnURLClick) then
    FOnURLClick(Self, URL)
  else
    ShellExecute(Handle, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
end;

procedure TsRichEditURL.CNNotify(var Msg: TWMNotify);
var
  P: TENLink;
begin
  if (Msg.NMHdr^.code = EN_LINK) then
  begin
    P := TENLink(Pointer(Msg.NMHdr)^);
    if (P.msg = WM_LBUTTONDOWN) then
    try
      SendMessage(Handle, EM_EXSETSEL, 0, Longint(@(P.chrg)));
      DoURLClick(SelText);
    except
    end;
  end;
  inherited;
end;

procedure TsRichEditURL.CreateWnd;
var
  Mask: Word;
begin
  inherited CreateWnd;
  SendMessage(Handle, EM_AUTOURLDETECT, 1, 0);
  Mask := SendMessage(Handle, EM_GETEVENTMASK, 0, 0);
  SendMessage(Handle, EM_SETEVENTMASK, 0, Mask or ENM_LINK);
end;

procedure Register;
begin
  RegisterComponents('pLan Components', [TsRichEditURL]);
end;

end.

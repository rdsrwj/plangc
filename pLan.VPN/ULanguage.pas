// $Id$
unit ULanguage;

interface

uses
  Windows, Classes, ExtCtrls, Forms, SysUtils, Graphics, Controls, StdCtrls,
  ComCtrls, Messages, SimpleXML, sLabel, sGroupBox, sCheckBox, sButton,
  sPageControl, sBitBtn, sListView;

type
  TObjBase = class(TObject)
  public
    WindowName: String;
    ComponentName: String;
    Caption: String;
  end;

  TObjWindow = class(TObjBase)
  end;

  TObjLabel = class(TObjBase)
  end;

  TObjButton = class(TObjBase)
  end;

  TColumn = class(TObject)
  public
    Caption: String;
  end;

  TObjListView = class(TObjBase)
  private
    FColumns: TList;
  public
    constructor Create;
    destructor Destroy; override;
  public  
    function GetColumn(Index: Integer): TColumn;
    property Column[Index: Integer]: TColumn read GetColumn;
  end;

  TLanguage = class(TObject)
  private
    FObjects: TList;
  public
    Code: String; // ru, en, de
    msgCantEstablishConnection: String;
    msgRoomHasNoPing: String;
    msgCantCreateServer: String;
    msgYourReportText: String;
    msgYourReportCaption: String;
    msgYouNeedToRestart: String;
    msgYouNeedToSelectIP: String;
    msgError: String;
    msgWarning: String;
    msgAdd: String;
    msgEdit: String;
    msgDelete: String;
    msgConfirmDelete: String;
    msgPing: String;
    msgGame: String;
    msgRoomName: String;
    msgPlayersCount: String;
    msgRoomIP: String;
    msgRoomPort: String;
    msgOpenVPNIP: String;
    msgOpenVPNPort: String;
    msgPlayers: String;
    msgRetrievingNews: String;
    msgRetrievingVersion: String;
    msgUpdatingGameList: String;
    msgUpdatingProgram: String;
    msgYourIP: String;
    msgUptime: String;
    msgChannel: String;
    msgRoomsCount: String;
    msgConfirmQuit: String;
    msgCompatibility: String;
    msgConnect: String;
    msgCreateRoom: String;
    msgRefresh: String;
    msgSettings: String;
    msgMakeReport: String;
    msgHelp: String;
    msgHomePage: String;
    msgForum: String;
    msgAbout: String;
    msgQuit: String;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Load(Name: String);
    function ItemByName(WindowName, ComponentName: String): TObjBase;
    procedure LoadCommonSettings(Obj: TObjBase; Element: IXMLNode);
    procedure Apply(Form: TForm);
    procedure Delete(Index: Integer);
    procedure Clear;
  end;

var
  Language: TLanguage;

implementation

uses
  UGlobal;

{ TObjListView }

constructor TObjListView.Create;
begin
  inherited;
  FColumns := TList.Create;
end;

destructor TObjListView.Destroy;
var
  I: Integer;
begin
  for I := FColumns.Count - 1 downto 0 do
  begin
    Column[I].Free;
    FColumns.Delete(I);
  end;
  FColumns.Free;
  inherited;
end;

function TObjListView.GetColumn(Index: Integer): TColumn;
begin
  if (Index < FColumns.Count) then
    Result := TColumn(FColumns.Items[Index])
  else
    Result := nil;
end;

{ TLanguage }

constructor TLanguage.Create;
begin
  inherited;
  FObjects := TList.Create;
  Code := 'en';
  msgCantEstablishConnection := 'Can''t establish connection';
  msgRoomHasNoPing := 'The room has no ping. Are you sure want to continue?';
  msgCantCreateServer := 'Can''t create server';
  msgYourReportText := 'If you encounter any problems with pLan, please send report to plan@plangc.ru. Log can be found at ';
  msgYourReportCaption := 'Report generated successfully';
  msgWarning := 'Warning';
  msgYouNeedToRestart := 'You need to restart application to change language';
  msgYouNeedToSelectIP := 'Please select your public IP';
  msgError := 'Error';
  msgRetrievingNews := 'Retrieving news';
  msgRetrievingVersion := 'Retrieving version';
  msgUpdatingGameList := 'Retrieving gamelist';
  msgUpdatingProgram := 'Retriving updated program';
  msgAdd := 'Add';
  msgEdit := 'Edit';
  msgDelete := 'Delete';
  msgConfirmDelete := 'Confirm deletion';
  msgPing := 'Ping';
  msgGame := 'Game name';
  msgRoomName := 'Room name';
  msgPlayersCount := 'Players';
  msgRoomIP := 'Room IP';
  msgRoomPort := 'Room port';
  msgOpenVPNIP := 'OpenVPN IP';
  msgOpenVPNPort := 'OpenVPN port';
  msgPlayers := 'Players';
  msgYourIP := 'Your IP';
  msgUptime := 'Uptime';
  msgChannel := 'Channel';
  msgRoomsCount := 'Rooms count';
  msgConfirmQuit := 'Are you sure want to exit?';
  msgCompatibility := 'Run program with compatibility mode';
  msgConnect := 'Connect to room';
  msgCreateRoom := 'Create room';
  msgRefresh := 'Refresh room list';
  msgSettings := 'Settings';
  msgMakeReport := 'System report';
  msgHelp := 'Help';
  msgHomePage := 'Home Page';
  msgForum := 'Forum';
  msgAbout := 'About';
  msgQuit := 'Quit';
end;

destructor TLanguage.Destroy;
begin
  Clear;
  FObjects.Free;
  inherited;
end;

function TLanguage.ItemByName(WindowName, ComponentName: String): TObjBase;
var
  I: Integer;
  Obj: TObjBase;
begin
  Result := nil;
  for I := 0 to FObjects.Count - 1 do
  begin
    Obj := TObjBase(FObjects.Items[I]);
    if (LowerCase(Obj.WindowName) = LowerCase(WindowName)) and
      (LowerCase(Obj.ComponentName) = LowerCase(ComponentName)) then
    begin
      Result := Obj;
      Break;
    end;
  end;
end;

procedure TLanguage.LoadCommonSettings(Obj: TObjBase; Element: IXMLNode);
begin
  Obj.WindowName := Element.ParentNode.GetAttr('Name');
  Obj.ComponentName := Element.GetAttr('ComponentName');
end;

procedure TLanguage.Load(Name: String);
var
  FileName: String;
  XML: IXmlDocument;
  MessagesNL, WindowNL, ButtonNL, LabelNL, ListViewNL,
  ColumnNL: IXmlNodeList;
  Node: IXMLNode;
  I, J, K: Integer;
  ObjWindow: TObjWindow;
  ObjButton: TObjButton;
  ObjLabel: TObjLabel;
  ObjListView: TObjListView;
  Column: TColumn;
begin
  Clear;

  FileName := UGlobal.AppPath + 'Languages\' + Name + '.xml';

  if FileExists(FileName) then
  begin
    XML := CreateXmlDocument();
    XML.Load(FileName);

    Code := XML.DocumentElement.GetAttr('name', 'en');

    MessagesNL := XML.DocumentElement.SelectNodes('messages');
    for I := 0 to MessagesNL.Count - 1 do
    begin
      Node := MessagesNL.Item[I];

      msgCantEstablishConnection := Node.GetAttr('msgCantEstablishConnection',
        msgCantEstablishConnection);

      msgRoomHasNoPing := Node.GetAttr('msgRoomHasNoPing', msgRoomHasNoPing);

      msgCantCreateServer := Node.GetAttr('msgCantCreateServer',
        msgCantCreateServer);

      msgYourReportText := Node.GetAttr('msgYourReportText', msgYourReportText);

      msgYourReportCaption := Node.GetAttr('msgYourReportCaption',
        msgYourReportCaption);

      msgWarning := Node.GetAttr('msgWarning', msgWarning);

      msgYouNeedToRestart := Node.GetAttr('msgYouNeedToRestart',
        msgYouNeedToRestart);

      msgYouNeedToSelectIP := Node.GetAttr('msgYouNeedToSelectIP',
        msgYouNeedToSelectIP);

      msgError := Node.GetAttr('msgError', msgError);

      msgRetrievingNews := Node.GetAttr('msgRetrievingNews', msgRetrievingNews);

      msgRetrievingVersion := Node.GetAttr('msgRetrievingVersion',
        msgRetrievingVersion);

      msgUpdatingGameList := Node.GetAttr('msgUpdatingGameList',
        msgUpdatingGameList);

      msgUpdatingProgram := Node.GetAttr('msgUpdatingProgram',
        msgUpdatingProgram);

      msgAdd := Node.GetAttr('msgAdd', msgAdd);

      msgEdit := Node.GetAttr('msgEdit', msgEdit);

      msgDelete := Node.GetAttr('msgDelete', msgDelete);

      msgConfirmDelete := Node.GetAttr('msgConfirmDelete', msgConfirmDelete);

      msgPing := Node.GetAttr('msgPing', msgPing);

      msgGame := Node.GetAttr('msgGame', msgGame);

      msgRoomName := Node.GetAttr('msgRoomName', msgRoomName);

      msgPlayersCount := Node.GetAttr('msgPlayersCount', msgPlayersCount);

      msgRoomIP := Node.GetAttr('msgRoomIP', msgRoomIP);

      msgRoomPort := Node.GetAttr('msgRoomPort', msgRoomPort);

      msgOpenVPNIP := Node.GetAttr('msgOpenVPNIP', msgOpenVPNIP);

      msgOpenVPNPort := Node.GetAttr('msgOpenVPNPort', msgOpenVPNPort);

      msgPlayers := Node.GetAttr('msgPlayers', msgPlayers);

      msgYourIP := Node.GetAttr('msgYourIP', msgYourIP);

      msgUptime := Node.GetAttr('msgUptime', msgUptime);

      msgChannel := Node.GetAttr('msgChannel', msgChannel);

      msgRoomsCount := Node.GetAttr('msgRoomsCount', msgRoomsCount);

      msgConfirmQuit := Node.GetAttr('msgConfirmQuit', msgConfirmQuit);

      msgCompatibility := Node.GetAttr('msgCompatibility', msgCompatibility);

      msgConnect := Node.GetAttr('msgConnect', msgConnect);
      msgCreateRoom := Node.GetAttr('msgCreateRoom', msgCreateRoom);
      msgRefresh := Node.GetAttr('msgRefresh', msgRefresh);
      msgSettings := Node.GetAttr('msgSettings', msgSettings);
      msgMakeReport := Node.GetAttr('msgMakeReport', msgMakeReport);
      msgHelp := Node.GetAttr('msgHelp', msgHelp);
      msgHomePage := Node.GetAttr('msgHomePage', msgHomePage);
      msgForum := Node.GetAttr('msgForum', msgForum);
      msgAbout := Node.GetAttr('msgAbout', msgAbout);
      msgQuit := Node.GetAttr('msgQuit', msgQuit);
    end;

    WindowNL := XML.DocumentElement.SelectNodes('window');
    for I := 0 to WindowNL.Count - 1 do
    begin
      Node := WindowNL.Item[I];

      ObjWindow := TObjWindow.Create;
      ObjWindow.WindowName := Node.GetAttr('Name');
      ObjWindow.ComponentName := Node.GetAttr('Name');
      ObjWindow.Caption := Node.GetAttr('Caption');
      FObjects.Add(ObjWindow);

      ButtonNL := Node.SelectNodes('button');
      for J := 0 to ButtonNL.Count - 1 do
      begin
        ObjButton := TObjButton.Create;
        //LoadCommonSettings(ObjButton, ButtonNL.Item[J]);
        ObjButton.WindowName := ObjWindow.WindowName;
        ObjButton.ComponentName := ButtonNL.Item[J].GetAttr('ComponentName');
        ObjButton.Caption := ButtonNL.Item[J].GetAttr('Caption');
        FObjects.Add(ObjButton);
      end;

      LabelNL := Node.SelectNodes('label');
      for J := 0 to LabelNL.Count - 1 do
      begin
        ObjLabel := TObjLabel.Create;
        //LoadCommonSettings(ObjLabel, LabelNL.Item[J]);
        ObjLabel.WindowName := ObjWindow.WindowName;
        ObjLabel.ComponentName := LabelNL.Item[J].GetAttr('ComponentName');
        ObjLabel.Caption := LabelNL.Item[J].GetAttr('Caption');
        FObjects.Add(ObjLabel);
      end;

      ListViewNL := Node.SelectNodes('listview');
      for J := 0 to ListViewNL.Count - 1 do
      begin
        ObjListView := TObjListView.Create;
        //LoadCommonSettings(ObjListView, ListViewNL.Item[J]);
        ObjListView.WindowName := ObjWindow.WindowName;
        ObjListView.ComponentName := ListViewNL.Item[J].GetAttr('ComponentName');

        ColumnNL := ListViewNL.Item[J].SelectNodes('column');
        for K := 0 to ColumnNL.Count - 1 do
        begin
          Column := TColumn.Create;
          Column.Caption := ColumnNL.Item[K].GetAttr('Caption');
          ObjListView.FColumns.Add(Column);
        end;

        FObjects.Add(ObjListView);
      end;
    end;

  end;
end;

procedure TLanguage.Apply(Form: TForm);
var
  Obj: TObjBase;
  I, J, K: Integer;
  Component: TComponent;
begin
  Obj := ItemByName(Form.Name, Form.Name);
  if (Obj <> nil) then
  begin
    if (Obj.Caption <> '') then
      Form.Caption := Obj.Caption;
  end;
  for I := 0 to Form.ComponentCount - 1 do
  begin
    Component := Form.Components[I];
    Obj := ItemByName(Form.Name, Component.Name);
    if (Obj <> nil) then
    begin
      if (Component is TsLabel) then
        TsLabel(Component).Caption := Obj.Caption
      else
      if (Component is TsGroupBox) then
        TsGroupBox(Component).Caption := Obj.Caption
      else
      if (Component is TsCheckBox) then
        TsCheckBox(Component).Caption := Obj.Caption
      else
      if (Component is TsButton) then
        TsButton(Component).Caption := Obj.Caption
      else
      if (Component is TsTabSheet) then
        TsTabSheet(Component).Caption := Obj.Caption
      else
      if (Component is TsBitBtn) then
        TsBitBtn(Component).Hint := Obj.Caption
      else
      if (Component is TsListView) then
      begin
        K := TListView(Component).Columns.Count;
        if (TObjListView(Obj).FColumns.Count < K) then
          K := TObjListView(Obj).FColumns.Count;
        for J := 0 to K - 1 do
        begin
          TListView(Component).Columns.Items[J].Caption :=
            TObjListView(Obj).Column[J].Caption;
        end;    
      end;
    end;
  end;
end;

procedure TLanguage.Clear;
var
  I: Integer;
begin
  for I := FObjects.Count - 1 downto 0 do
    Delete(I);
end;

procedure TLanguage.Delete(Index: Integer);
var
  Obj: TObjBase;
begin
  Obj := FObjects.Items[Index];
  {if (Obj is TObjListView) then
    TObjListView(Obj).Free;}
  Obj.Free;
  FObjects.Delete(Index);
end;

end.

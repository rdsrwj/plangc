// $Id$
unit PrevInst;

interface

uses
  Forms, Windows, Dialogs, SysUtils;

function InitInstance: Boolean;

implementation

var
  MessageId: Integer;
  OldWProc: TFNWndProc = nil;
  MutHandle: THandle = 0;
  SecondExecution: Boolean = False;
  UniqueAppStr: PAnsiChar = #0; // Различное для каждого приложения,
                                // но одинаковое для каждой копии программы.

function NewWndProc(Handle: HWND; Msg: Integer;
  wParam, lParam: Longint): Longint; stdcall;
begin
  if (Msg = MessageID) then // Если сообщение о регистрации...
  begin
    if IsIconic(Application.Handle) then // Если основная форма минимизирована.
    begin
      Application.Restore; // Восстанавливаем ее.
    end
    else
    begin
      // Вытаскиваем на передний план.
      ShowWindow(Application.Handle, SW_SHOW);
      SetForegroundWindow(Application.Handle);
      Application.BringToFront;
    end;
    Result := 0;
  end
  else
    // В противном случае посылаем сообщение предыдущему окну.
    Result := CallWindowProc(OldWProc, Handle, Msg, wParam, lParam);
end;

function InitInstance : Boolean;
{var
  BSMRecipients: DWORD;}
begin
  Result := False;
  // Пробуем открыть MUTEX созданный предыдущей копией программы.
  MutHandle := CreateMutex(nil, True, UniqueAppStr);
  // Мутекс уже был создан ?
  SecondExecution := (GetLastError = ERROR_ALREADY_EXISTS);
  if (MutHandle = 0) then Exit;

  if (not SecondExecution) then
  begin
    // Назначаем новый обработчик сообщений приложения, а старый сохраняем.
    OldWProc := TFNWndProc(SetWindowLong(Application.Handle, GWL_WNDPROC,
      Longint(@NewWndProc)));
    if (OldWProc = nil) then Exit;

    // Устанавливаем "нормальный" статус основного окна приложения.
    //ShowWindow(Application.Handle, SW_SHOWNORMAL);
    // Показываем основную форму приложения.
    //Application.ShowMainForm := True;
    Result := True;
  end
  else
  begin
    // Устанавливаем статус окна приложения "невидимый".
    ShowWindow(Application.Handle, SW_HIDE);
    // Скрываем основную форму приложения.
    //Application.ShowMainForm := False;
    // Посылаем другому приложению сообщение и информируем о необходимости
    // перевести фокус на себя.
    //BSMRecipients := BSM_APPLICATIONS;
    //BroadcastSystemMessage(BSF_IGNORECURRENTTASK or BSF_POSTMESSAGE,
    //  @BSMRecipients, MessageID, 0, 0);
  end;
end;

initialization

  // Создаем уникальную строку для опознания приложения.
  UniqueAppStr := PAnsiChar('PLANUniqString');
  // Регистрируем в системе уникальное сообщение.
  MessageID := RegisterWindowMessage(UniqueAppStr);

finalization

  // Приводим приложение в исходное состояние.
  if (OldWProc <> nil) then
    SetWindowLong(Application.Handle, GWL_WNDPROC, Longint(OldWProc));

end.

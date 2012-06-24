// $Id$
unit AdaptItems;

interface

uses
  Windows, Classes, SysUtils, StdCtrls;

type
  TAdapterItem = class(TObject)
  public
    Index: Cardinal;
    Name: String;
    Description: String;
    Gateway: String;
    IPAddress: String;
    NullGatewayAddress: String;
    Mask: String;
  end;

  TAdapterList = class(TList)
  protected
    function GetItem(Index: Integer): TAdapterItem;
    procedure Resolve;      
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Name: String; Description: String; IPAddress: String;
      Mask: String; Gateway: String; Index: Cardinal); overload;
    procedure Delete(Index: Integer);
    function GetByName(Name: String): TAdapterItem;
    function GetByDescription(Description: String): TAdapterItem;
    function GetByIP(IP: String): TAdapterItem;
    property Items[Index: Integer]: TAdapterItem read GetItem;
  end;

  function MaskbitToMask(MaskBit: Byte): String;
  function IpAddrToString(Addr: DWORD): String;
  function GetInterfaceCount: DWORD;

implementation

uses
  IpHlpApi, IpTypes, WinSock;

type
  EIpHlpError = class(Exception);

const
  sNotSupported = 'Function %s is not supported by the operating system.';
  sNotImplemented = 'Function %s is not implemented.';
  sCanNotComplete = 'Can''t complete function %s';
  sRouteNotFound = 'The route specified was not found.';
  sInvalidParameter = 'Function %s. Invalid parameter';
  sNoData = 'Function %s. No adapter information exists for the local computer.';

function MaskbitToMask(MaskBit: Byte): String;
const
  Ranges: array[0..7] of Byte = (0, 128, 192, 224, 240, 248, 252, 254);
begin
  case (MaskBit div 8) of
    0: Result := IntToStr(Ranges[MaskBit mod 8]) + '.0.0.0';
    1: Result := '255.' + IntToStr(Ranges[MaskBit mod 8]) + '.0.0';
    2: Result := '255.255.' + IntToStr(Ranges[MaskBit mod 8]) + '.0';
    3: Result := '255.255.255.' + IntToStr(Ranges[MaskBit mod 8]);
    4: Result := '255.255.255.255';
  end;
end;

function IpAddrToString(Addr: DWORD): String;
var
  inad: in_addr;
begin
  inad.s_addr := Addr;
  Result := inet_ntoa(inad);
end;

constructor TAdapterList.Create;
begin
  inherited;
  Resolve;
end;

destructor TAdapterList.Destroy;
begin
  while (Count <> 0) do Self.Delete(0);
  inherited;
end;

procedure TAdapterList.Delete(Index: Integer);
begin
  Items[Index].Free;
  inherited Delete(Index);
end;

function TAdapterList.GetItem(Index: Integer): TAdapterItem;
begin
  Result := TAdapterItem(Self.Get(Index));
end;

procedure TAdapterList.Add(Name: String; Description: String;
  IPAddress: String; Mask: String; Gateway: String; Index: Cardinal);
var
  AdItem: TAdapterItem;
  T: Cardinal;
begin
  AdItem := TAdapterItem.Create;
  AdItem.Name := Name;
  AdItem.Description := Description;
  AdItem.Gateway := Gateway;
  AdItem.IPAddress := IPAddress;
  AdItem.Mask := Mask;
  AdItem.Index := Index;
  T := inet_addr(PChar(IPAddress));
  T := (T mod $1000000) + $FE000000;
  AdItem.NullGatewayAddress := IpAddrToString(T);
  inherited Add(AdItem);
end;

function TAdapterList.GetByName(Name: String): TAdapterItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if (Items[I].Name = Name) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TAdapterList.GetByDescription(Description: String): TAdapterItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if (Items[I].Description = Description) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TAdapterList.GetByIP(IP: String): TAdapterItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if (Items[I].IPAddress = IP) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

procedure IpHlpError(const FunctionName: String; ErrorCode: DWORD);
begin
  case ErrorCode of
    ERROR_INVALID_PARAMETER:
      raise EIpHlpError.CreateFmt(sInvalidParameter, [FunctionName]);
    ERROR_NO_DATA:
      raise EIpHlpError.CreateFmt(sNoData, [FunctionName]);
    ERROR_NOT_SUPPORTED:
      raise EIpHlpError.CreateFmt(sNotSupported, [FunctionName]);
  else
    //RaiseLastWin32Error;
  end;
end;

procedure GetAllAdaptersInfo(var P: PIpAdapterInfo; var OutBufLen: Cardinal);
var
  Res: DWORD;
begin
  P := nil;
  OutBufLen := 0;
  if (@GetAdaptersInfo = nil) then
    raise EIpHlpError.CreateFmt(sNotImplemented, ['GetAdaptersInfo']);
  Res := GetAdaptersInfo(P, OutBufLen);
  if (Res = ERROR_BUFFER_OVERFLOW) then
  begin
    GetMem(P, OutBufLen);
    // Caller must free this buffer when it is no longer used
    FillChar(P^, OutBufLen, #0);
    Res := GetAdaptersInfo(P, OutBufLen);
  end;
  if (Res <> 0) then
    IpHlpError('GetAdaptersInfo', Res);
end;

procedure TAdapterList.Resolve;
var
  P, Temp: PIPAdapterInfo;
  BufLen: Cardinal;
begin
  Clear;
  if (GetInterfaceCount > 1) then
  begin
    GetAllAdaptersInfo(P, BufLen);
    try
      Temp := P;
      while (Temp <> nil) do
      begin
        Add(Temp.AdapterName, Temp.Description, Temp.IpAddressList.IpAddress.S,
         Temp.IpAddressList.IpMask.S, Temp.GatewayList.IpAddress.S, Temp.Index);
        Temp := Temp.Next;
      end;
    finally
      FreeMem(P, BufLen);
    end;
  end;
end;

function GetInterfaceCount: DWORD;
var
  Res: DWORD;
  NumIf: DWORD;
begin
  if (@GetNumberOfInterfaces = nil) then
    raise EIpHlpError.CreateFmt(sNotImplemented, ['GetNumberOfInterfaces']);
  Res := GetNumberOfInterfaces(NumIf);
  if (Res <> 0) then
    IpHlpError('GetNumberOfInterfaces', Res);
  Result := NumIf;
end;

end.

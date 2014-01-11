CD /D %~dp0
CD ..\pLan.VPN\

ECHO const Revision = '$WCREV$'; > Revision.tmpl
SubWCRev.exe "%CD%" Revision.tmpl Revision.inc

DEL Revision.tmpl
@ECHO OFF
IF EXIST "DLL\Release" (
	FOR /R %%I IN ("DLL\Release\*.*") DO (
		IF "%%~xI" NEQ ".dll" (
			DEL %%~I
		)
	)
)
DEL "DLL\*.ncb"
DEL "DLL\*.user"
DEL "Temp\*.dcu"
DEL "*.ddp"
PAUSE
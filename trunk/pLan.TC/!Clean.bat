@ECHO OFF
IF EXIST "DLL\Release" (
	FOR /R %%I IN ("DLL\Release\*.*") DO (
		IF "%%~xI" NEQ ".dll" (
			DEL %%~I
		)
	)
)
DEL "DLL\*.user"

IF EXIST "Loader\Release" (
	FOR /R %%I IN ("Loader\Release\*.*") DO (
		IF "%%~xI" NEQ ".exe" (
			DEL %%~I
		)
	)
)
DEL "Loader\*.user"

DEL "*.ncb"
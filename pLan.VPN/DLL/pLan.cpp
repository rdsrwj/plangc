#include <stdafx.h>
#include <WinInet.h>

#define		PLANVERSION	18

#pragma data_seg(".sdata")
HHOOK hHook      = NULL;
#pragma data_seg()

HMODULE	hMyHook = NULL;

BOOL WINAPI DllMain(HANDLE hModule, DWORD dwReason, LPVOID lpReserved)
{
	switch(dwReason)
	{
		case DLL_PROCESS_ATTACH:
		{
			DisableThreadLibraryCalls((HINSTANCE)hModule);

			hMyHook = (HMODULE)hModule;

			// Initialize configuration
			theConfig.Initialize((HMODULE)hModule);

			// Patch game
			if (theGame.Initialize())
			{
				hk::GetLogManager().Write("Game was recognized.\n");
			} else
			{
//				hk::GetLogManager().SetEnable(false);
			}

			break;
		}
		case DLL_PROCESS_DETACH:
			{
				hk::GetLogManager().Printf("Detaching from process '%s'.\n", theConfig.GetGameName());

				pSocketHook::Deinitialize();

				hk::GetPatchManager().RemoveAllPatches();

				hk::GetLogManager().Deinitialize();

				theGame.Deinitialize();

				break;
			}
	}
	return TRUE;
}

LRESULT CALLBACK HookProc(int code, WPARAM wParam, LPARAM lParam)
{
	return CallNextHookEx(hHook,code,wParam,lParam);
} 

void	WINAPI Unhooker()
{
	if (hHook == 0)
		return;
	
//	hk::GetLogManager().Write("Unhook...\n");

	hHook = (UnhookWindowsHookEx(hHook)) ? (0):(hHook);
}

void	WINAPI Hooker()
{
	if (hHook != 0)
		Unhooker();

//	hk::GetLogManager().Write("Hook...\n");

	hHook = SetWindowsHookEx(WH_GETMESSAGE,(HOOKPROC)HookProc, hMyHook, 0);	
}

DWORD	WINAPI	Version()
{
	return PLANVERSION;
}

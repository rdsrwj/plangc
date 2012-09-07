#pragma once

class	hkDetour
{
public:
		hkDetour();
		~hkDetour();

		LPVOID	MaskFind(LPVOID lpStart, DWORD searchLimit, const char * szMask, const BYTE * szData);

		bool	RemovePatch(LPVOID lpStart);

		// Detour piece of code
		LPVOID	CreateJump(LPVOID address, LPVOID handler);
		LPVOID	CreateCall(LPVOID address, LPVOID handler);

		// Hook PE import
		bool	HookImport(LPVOID modBase, const char * szLibrary, const char * szName, const char * szFuncName, LPVOID newHandler, LPVOID * lpOriginal = NULL);
private:
		BYTE *	m_Buf;
		BYTE *	m_BufPnt;
		BYTE	m_Buffer[HKMSL];

		typedef	struct 
		{
			LPVOID	patchAddress;
			int		patchID;
		} patchInfo_t;

		typedef	hkDynBuffer<patchInfo_t>	intBuffer_t;
		intBuffer_t		m_DetourPatches;

		BOOL	CheckMemory();
};
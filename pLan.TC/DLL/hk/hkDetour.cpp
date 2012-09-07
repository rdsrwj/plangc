#include "hkSDK.h"

namespace	hk
{

#define	MAKEADDR(a, b, c)	(a)(((BYTE *)b) + (DWORD)c)
#define	DETOUR_MAX	(0x4000)

#define	MAKE_PAGE(a)		(((DWORD)a) & ~0x0FFF)
#define	SAME_PAGE(a, p)		((((DWORD)a) >= p) && (((DWORD)a) < (p + 0x1000)))

hkDetour::hkDetour()
{
	m_Buf = NULL;

	CheckMemory();
}

hkDetour::~hkDetour()
{
	for (DWORD i = 0; i < m_DetourPatches.GetSize(); i++)
	{
		patchInfo_t & detour = m_DetourPatches[i];

		hk::GetPatchManager().DelPatch(detour.patchID);
	}

	VirtualFree(m_Buf, DETOUR_MAX, MEM_RELEASE);
}

BOOL	hkDetour::CheckMemory()
{
	if (!m_Buf)
	{
		m_Buf  = (BYTE *)VirtualAlloc(NULL, DETOUR_MAX, MEM_COMMIT, PAGE_EXECUTE_READWRITE);

		if (!m_Buf) return FALSE;

		m_BufPnt = m_Buf;
	}

	return TRUE;
}

LPVOID	hkDetour::MaskFind(LPVOID lpStart, DWORD searchLimit, const char * szMask, const BYTE * szData)
{
	size_t l = strlen(szMask);

	BYTE * pos = (BYTE *)lpStart;
	BYTE * limit = pos + searchLimit;

	DWORD	curPage = 0;

	while (pos != limit)
	{
		if (!SAME_PAGE(pos, curPage))
		{
			curPage = MAKE_PAGE(pos);

			if (IsBadReadPtr((LPVOID)curPage, 0x1000))
			{
				if (searchLimit <= 0x1000)
				{
					return NULL;
				} else
				{
					searchLimit -= 0x1000;
					pos += 0x1000;
				}
			}
		} else
		{
			DWORD j;
			for (j = 0; j < l && pos != limit; j++)
			{
				if (szMask[j] != '?' && szData[j] != *pos) break;

				++pos;

				if (!SAME_PAGE(pos, curPage))
				{
					if (IsBadReadPtr(pos, 0x1000))
					{
						break;
					} else
					{
						curPage = MAKE_PAGE(pos);
					}
				}
			}

			if (j == l)
			{
				return (LPVOID)(pos - l);
			}

			++pos;
		}
	}

	return NULL;
}

//////////////////////////////////////////////////////////////////////////
// Remove patch from given address
bool	hkDetour::RemovePatch(LPVOID lpStart)
{
	for (DWORD i = 0; i < m_DetourPatches.GetSize(); i++)
	{
		if (m_DetourPatches[i].patchAddress == lpStart)
		{
			patchInfo_t & info = m_DetourPatches[i];
			hk::GetPatchManager().DelPatch(info.patchID);
			m_DetourPatches.Remove(i);
			return true;
		}
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////
// Creates JMP to our handler and returns wrapped code
// Assumes that memory is readable
LPVOID	hkDetour::CreateJump(LPVOID address, LPVOID original)
{
	if (m_Buf == NULL)
	{
		return NULL;
	}

	DWORD relativeJump = 0;

	DWORD disLen = 0;
	while (disLen < 5)
	{
		hkADE32::disasm_struct s = {4, 4};

		DWORD opcodeLen = hkADE32::ade32_disasm((BYTE *)address + disLen, &s);

		// Failed to disassemble
		if (!opcodeLen)
			return FALSE;

		if (disLen == 0 && s.disasm_opcode == 0xE9)
		{
			disLen += 5;

			DWORD relAddress = *(DWORD *)(((DWORD)address) + 1);
			relativeJump = ((DWORD)address) + relAddress;
			break;
		}

		// No relative jumps allowed
		if (s.disasm_flag & C_REL)
		{
			return FALSE;
		}

		disLen += opcodeLen;
	}

	BYTE * detourStart = m_BufPnt;

	DWORD ofs;
	if (relativeJump == 0)
	{
		// Copy original data
		memcpy(m_BufPnt, address, disLen);
		m_BufPnt += disLen;

		// JMP <original data>
		*(m_BufPnt++) = 0xE9;
		ofs = (DWORD)address + disLen - (DWORD)m_BufPnt - 4;
		*(DWORD *)(m_BufPnt) = ofs;
		m_BufPnt += 4;
	} else
	{
		*(m_BufPnt++) = 0xE9;
		DWORD ofs = relativeJump - (DWORD)m_BufPnt + 1;
		*(DWORD *)(m_BufPnt) = ofs;
		m_BufPnt += 4;
	}

	// 16 byte boundary
	m_BufPnt += (16 - ((DWORD)m_BufPnt & 15));

	// Generate jump in patched memory area
	BYTE * temp = (BYTE *)m_Buffer;

	*(temp++) = 0xE9;
	ofs = (DWORD)original - (DWORD)address - 5;
	*(DWORD *)(temp) = ofs;
	temp += 4;

	int patchID = hk::GetPatchManager().AddPatch(address, m_Buffer, (temp - m_Buffer));
	if (patchID == -1)
		return NULL;

	patchInfo_t patch;
	patch.patchAddress = address;
	patch.patchID = patchID;
	m_DetourPatches.Add(patch);

	return detourStart;
}
//////////////////////////////////////////////////////////////////////////
// Creates CALL to our handler and returns wrapped code
// Assumes that memory is readable
LPVOID	hkDetour::CreateCall(LPVOID address, LPVOID original)
{
	if (m_Buf == NULL)
	{
		return NULL;
	}

	DWORD relativeJump = 0;

	DWORD disLen = 0;
	while (disLen < 5)
	{
		hkADE32::disasm_struct s = {4, 4};

		DWORD opcodeLen = hkADE32::ade32_disasm((BYTE *)address + disLen, &s);

		// Failed to disassemble
		if (!opcodeLen)
			return FALSE;

		if (disLen == 0 && s.disasm_opcode == 0xE9)
		{
			disLen += 5;

			DWORD relAddress = *(DWORD *)(((DWORD)address) + 1);
			relativeJump = ((DWORD)address) + relAddress;
			break;
		}

		// No relative jumps allowed
		if (s.disasm_flag & C_REL)
		{
			return FALSE;
		}

		disLen += opcodeLen;
	}

	BYTE * detourStart = m_BufPnt;

	DWORD ofs;
	if (relativeJump == 0)
	{
		// Copy original data
		memcpy(m_BufPnt, address, disLen);
		m_BufPnt += disLen;

		// JMP <original data>
		*(m_BufPnt++) = 0xE9;
		ofs = (DWORD)address + disLen - (DWORD)m_BufPnt - 4;
		*(DWORD *)(m_BufPnt) = ofs;
		m_BufPnt += 4;
	} else
	{
		*(m_BufPnt++) = 0xE9;
		DWORD ofs = relativeJump - (DWORD)m_BufPnt + 1;
		*(DWORD *)(m_BufPnt) = ofs;
		m_BufPnt += 4;
	}

	// 16 byte boundary
	m_BufPnt += (16 - ((DWORD)m_BufPnt & 15));

	// Generate jump in patched memory area
	BYTE * temp = (BYTE *)m_Buffer;

	*(temp++) = 0xE8;
	ofs = (DWORD)original - (DWORD)address - 5;
	*(DWORD *)(temp) = ofs;
	temp += 4;

	int patchID = hk::GetPatchManager().AddPatch(address, m_Buffer, (temp - m_Buffer));
	if (patchID == -1)
		return NULL;

	patchInfo_t patch;
	patch.patchAddress = address;
	patch.patchID = patchID;
	m_DetourPatches.Add(patch);

	return detourStart;
}

bool	hkDetour::HookImport(LPVOID modBase, const char * szLibrary, const char * szName, const char * szFuncName, LPVOID newHandler, LPVOID * lpOriginal /* = NULL */)
{
	HMODULE hMod = GetModuleHandle(szName);
	if (hMod == NULL)
		return false;

	LPVOID func = GetProcAddress(hMod, szFuncName);

	PIMAGE_DOS_HEADER pDos = (PIMAGE_DOS_HEADER)modBase;
	if (pDos->e_magic != IMAGE_DOS_SIGNATURE)
	{
//		printf("Not a valid DOS executable.\n");
		return false;
	}

	if (pDos->e_lfanew == 0)
	{
//		printf("Not a PE executable.\n");
		return false;
	}

	PIMAGE_NT_HEADERS pNT = MAKEADDR(PIMAGE_NT_HEADERS, pDos, pDos->e_lfanew);
	if (pNT->Signature != IMAGE_NT_SIGNATURE)
	{
//		printf("Not a PE executable.\n");
		return false;
	}

	if (pNT->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress == 0)
	{
//		printf("Executable does not have any exports available.\n");
		return false;
	}

	PIMAGE_IMPORT_DESCRIPTOR pImport = MAKEADDR(PIMAGE_IMPORT_DESCRIPTOR, pDos, pNT->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
	while (pImport->Characteristics != 0)
	{
		PIMAGE_THUNK_DATA	pThunk = MAKEADDR(PIMAGE_THUNK_DATA, pDos, pImport->FirstThunk);
		while (pThunk->u1.Function)
		{
			if (pThunk->u1.Function == (DWORD)func)
			{
				LPVOID rfunc = MAKEADDR(LPVOID, pDos, pThunk->u1.Function);

				if (lpOriginal != NULL)
				{
					if (!hk::GetPatchManager().SafeRead(rfunc, lpOriginal, sizeof(LPVOID)))
					{
						*lpOriginal = NULL;
						return false;
					}
				}

				int patchID = hk::GetPatchManager().AddPatch(rfunc, newHandler, sizeof(LPVOID));
				if (patchID == -1)
				{
					return false;
				}

				patchInfo_t patch;
				patch.patchAddress = newHandler;
				patch.patchID = patchID;
				m_DetourPatches.Add(patch);
				
				return true;
			}

			pThunk++;
		}

		pImport++;
	}

	return false;
}

}

#include "hkSDK.h"

namespace	hk
{

hkPatchManager::hkPatchManager()
{
}

hkPatchManager::~hkPatchManager()
{
	RemoveAllPatches();
	
	m_Patches.Reset();
}

int		hkPatchManager::AddPatch(LPVOID lpAddress, LPVOID lpData, DWORD dwLength)
{
	if (dwLength > MAX_PATCH)
		return -1;

	hkPatch_t	patch;
	patch.m_Free = FALSE;
	patch.m_ID   = 0;
	patch.m_DataLength = dwLength;
	patch.m_Address = lpAddress;

	DWORD oldProtect;
	if (VirtualProtect(lpAddress, dwLength, PAGE_EXECUTE_READWRITE, &oldProtect))
	{
		memcpy(patch.m_Data, lpAddress, dwLength);

		memcpy(lpAddress, lpData, dwLength);

		VirtualProtect(lpAddress, dwLength, oldProtect, &oldProtect);

		hkPatch_t * fPatch;
		if (m_FreePatches.Pop(fPatch))
		{
			patch.m_ID = fPatch->m_ID;
			*fPatch = patch;

		} else
		{
			patch.m_ID = m_Patches.GetSize();

			m_Patches.Add(patch);
		}

		hk::GetLogManager().Printf("[Server] Patched %x\n", lpAddress);

		return patch.m_ID;
	}

	hk::GetLogManager().Printf("[Server] Failed to patch %x\n", lpAddress);

	return -1;
}

BOOL	hkPatchManager::DelPatch(int patchID, bool unpatch /* = true */)
{
	if (patchID < 0 || patchID >= static_cast<int>(m_Patches.GetSize()))
		return FALSE;

	if (m_Patches[patchID].m_Free)
		return FALSE;

	hkPatch_t & patch = m_Patches[patchID];

	DWORD oldProtect;

	if (unpatch)
	{
		if (VirtualProtect(patch.m_Address, patch.m_DataLength, PAGE_EXECUTE_READWRITE, &oldProtect))
		{
			memcpy(patch.m_Address, patch.m_Data, patch.m_DataLength);

			VirtualProtect(patch.m_Address, patch.m_DataLength, oldProtect, &oldProtect);
		} else
		{
			hk::GetLogManager().Printf("[Patch] Failed to remove patch from %x\n", patch.m_Address);

			return FALSE;
		}
	}

	patch.m_Free = TRUE;

	m_FreePatches.Add(&patch);

	hk::GetLogManager().Printf("[Patch] Removed patch from %x\n", patch.m_Address);

	return TRUE;
}

void	hkPatchManager::RemoveAllPatches()
{
	int removed = 0;

	for (DWORD i = 0; i < m_Patches.GetSize(); i++)
	{
		if (DelPatch(i))
			removed++;
	}

	hk::GetLogManager().Printf("Removed %d patches\n", removed);
}

int		hkPatchManager::GetPatchCount()
{
	return static_cast<int>(m_Patches.GetSize());
}

bool	hkPatchManager::SafeRead(LPVOID lpAddress, LPVOID lpDestination, DWORD count)
{
	DWORD oldProtect;
	if (VirtualProtect(lpAddress, count, PAGE_EXECUTE_READ, &oldProtect))
	{
		memcpy(lpDestination, lpAddress, count);

		VirtualProtect(lpAddress, count, oldProtect, &oldProtect);

		return true;
	}

	return false;
}

}

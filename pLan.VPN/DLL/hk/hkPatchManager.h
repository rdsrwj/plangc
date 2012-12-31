#pragma once

#define	MAX_PATCH	128

class	hkPatchManager
{
public:
		hkPatchManager();
		~hkPatchManager();

		int		AddPatch(LPVOID lpAddress, LPVOID lpData, DWORD dwData);
		BOOL	DelPatch(int patchID, bool unpatch = true);

		int		GetPatchCount();
		void	RemoveAllPatches();

		bool	SafeRead(LPVOID lpAddress, LPVOID lpDestination, DWORD count);
protected:
		typedef	struct 
		{
			bool	m_Free;
			DWORD	m_ID;
			LPVOID	m_Address;
			BYTE	m_Data[MAX_PATCH];
			DWORD	m_DataLength;
		} hkPatch_t;

		typedef	hkDynBuffer<hkPatch_t>	hkPatches_t;
		hkPatches_t	m_Patches;

		typedef	hkDynBuffer<hkPatch_t *>	hkPatchesPointers_t;
		hkPatchesPointers_t	m_FreePatches;
};

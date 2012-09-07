#include "hkSDK.h"

namespace	hk
{
	hkPatchManager	&	GetPatchManager()
	{
		static	hkPatchManager	sPatchManager;

		return sPatchManager;
	}

	hkDetour		&	GetDetourManager()
	{
		static	hkDetour	sDetour;

		return sDetour;
	}

	hkLog			&	GetLogManager()
	{
		static	hkLog	sLog;

		return sLog;
	}
}

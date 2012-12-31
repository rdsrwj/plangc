#pragma once

#include	"pGameHookBase.h"
#include	"pGameHookSWBF2.h"

inline	pGameHookBase	*	pCreateGameHook(const char * szName)
{
	if (!_strcmpi(szName, "SWBF2"))
	{
		return new pGameHookSWBF2;
	} else
	{
		return NULL;
	}
}

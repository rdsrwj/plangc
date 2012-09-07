// HookLib (c) Joes

// VS 2005 Fix
#if (_MSC_VER > 1300)
#include "vs2005fix.h"
#endif

#include	<Windows.h>
#include	<stdio.h>

#define	HKMSL	512

// Define LOG file before header inclusion
#ifndef HKLOGFILE
#define	HKLOGFILE	"c:\\hklog.txt"
#endif

namespace	hk
{
#include	"hkDynBuffer.h"
#include	"hkDataBuffer.h"
#include	"hkADE32.h"
#include	"hkLog.h"
#include	"hkPatchManager.h"
#include	"hkDetour.h"
#include	"hkUtils.h"

// API
	hkPatchManager	&	GetPatchManager();
	hkDetour		&	GetDetourManager();
	hkLog			&	GetLogManager();
};

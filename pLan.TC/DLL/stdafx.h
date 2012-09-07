#pragma once

//////////////////////////////////////////////////////////////////////////
// Visual Studio 2005 fixes
#if (_MSC_VER > 1300)
#include "hk/vs2005fix.h"
#endif

//////////////////////////////////////////////////////////////////////////
// Headers includes
#include	<WinSock2.h>

#define	HKLOGFILE	"c:\\pLan.txt"

// Include hk SDK
#include	"hk/hkSDK.h"

// Include TinyXML
#include	"TiXML/tinyxml.h"

#include	<map>

// Include project files
#include	"pMutex.h"
#include	"pConfig.h"
#include	"pGameSearch.h"
#include	"pGamePatch.h"
#include	"pGameHooks.h"
#include	"pGameInfo.h"
#include	"pGame.h"
#include	"pSocketHook.h"
#include	"pAsyncUpdater.h"
#include	"pSockServer.h"
#include	"pAddressFake.h"

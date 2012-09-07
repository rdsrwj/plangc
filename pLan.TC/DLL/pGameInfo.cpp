#include	"stdafx.h"

pGameInfo::pGameInfo(TiXmlElement * xml) : 
m_Valid(false),
m_hThread(0),
m_HaveReplyPack(false),
m_HaveBroadcastPack(false)
{
	m_ServerActivated = false;
	m_GameHook = NULL;
	
	const	char * temp;

	// Name
	temp = xml->Attribute("name");
	if (temp == NULL)
	{
		hk::GetLogManager().Printf("No name tag for game.\n");
		return;
	} else
	{
		m_GameName = temp;
	}

	// Description
	temp = xml->Attribute("desc");
	if (temp == NULL)
	{
		hk::GetLogManager().Printf("No description tag for game.\n");
		return;
	} else
	{
		m_GameDesc = temp;
	}

	// Identification
	TiXmlElement * identElement = xml->FirstChildElement("identification");
	if (identElement == NULL)
	{
		hk::GetLogManager().Printf("No identification data for game.\n");
		return;
	} else
	{
		// Try to get application name
		TiXmlElement * appName = identElement->FirstChildElement("appname");
		while (appName != NULL)
		{
			temp = appName->Attribute("name");
			if (temp != NULL)
			{
				m_AppNames.Add(temp);
			}

			appName = appName->NextSiblingElement("appname");
		}

		// Try to get application masks
		TiXmlElement * datamask = identElement->FirstChildElement("datamask");
		while (datamask != NULL)
		{
			pGameSearch * pSearch = new pGameSearch();
			if (!pSearch->Initialize(datamask))
			{
				delete pSearch;
				hk::GetLogManager().Printf("Invalid identification mask for game '%s'.\n", m_GameName.c_str());
			}
			m_AppSignatures.Add(pSearch);

			datamask = datamask->NextSiblingElement("datamask");
		}

		if (m_AppSignatures.GetSize() == 0 && m_AppNames.GetSize() == 0)
		{
			hk::GetLogManager().Printf("No valid identification signatures for game '%s'.\n", m_GameName.c_str());
		}
	}

	// Load patches
	TiXmlElement * patchElement = xml->FirstChildElement("patches");
	if (patchElement != NULL)
	{
		// Try to get application patches
		TiXmlElement * datapatch = patchElement->FirstChildElement("patch");
		while (datapatch != NULL)
		{
			pGamePatch * pPatch = new pGamePatch();
			if (!pPatch->Initialize(datapatch))
			{
				delete pPatch;
				hk::GetLogManager().Printf("Invalid patch for game '%s'.\n", m_GameName.c_str());
			}
			m_GamePatches.Add(pPatch);

			datapatch = datapatch->NextSiblingElement("patch");
		}
	}

	// Detect server settings
	m_BindServerPort = 0;
	m_BroadcastEmu = false;
	m_BroadcastSendEmu = false;
	m_BroadcastTunnel = false;
	m_BroadcastTunnelFakeAddress = true;
	m_BroadcastNotify = false;
	m_BroadcastClientForcePort = false;
	m_BroadcastLan = false;

	m_BroadcastForcePort = FALSE;

	m_BindServerLoPort = 0x0000;
	m_BindServerHiPort = 0xFFFF;

	m_AddressEmulation = FALSE;
	m_AddFakeAddress   = FALSE;

	m_BindForceAllInterfaces = FALSE;

	m_GuessForwardAddress = FALSE;

	TiXmlElement * serverDetect = xml->FirstChildElement("server");
	if (serverDetect != NULL)
	{
		TiXmlElement * bindserver = serverDetect->FirstChildElement("bind");
		if (bindserver != NULL)
		{
			int v;
			const char * t;
			
			t = bindserver->Attribute("port", &v);
			if (t != NULL)
			{
				m_BindServerPort = v;
			}

			t = bindserver->Attribute("loport", &v);
			if (t != NULL)
			{
				m_BindServerLoPort = v;
			}

			t = bindserver->Attribute("hiport", &v);
			if (t != NULL)
			{
				m_BindServerHiPort = v;
			}
		}

		TiXmlElement * packServer = serverDetect->FirstChildElement("packet");
		while (packServer != NULL)
		{
			pPacket_t	* pack = new pPacket_t;

			const char * t;

			t = packServer->Attribute("request");
			if (t != NULL)
			{
				int newLength = hk::hkUtils::FromBase16(t, m_RequestPacket.GetBuffer());
				m_RequestPacket.SetBufferLen(newLength);
			}

			t = packServer->Attribute("reply");
			if (t != NULL)
			{
				int newLength = hk::hkUtils::FromBase16(t, pack->m_ReplyPacket.GetBuffer());
				pack->m_ReplyPacket.SetBufferLen(newLength);
				m_HaveReplyPack = true;
			}
			t = packServer->Attribute("replymask");
			if (t != NULL)
			{
				pack->m_ReplyPacketMask = t;
			}

			t = packServer->Attribute("broadcast");
			if (t != NULL)
			{
				int newLength = hk::hkUtils::FromBase16(t, pack->m_BroadcastPacket.GetBuffer());
				pack->m_BroadcastPacket.SetBufferLen(newLength);
				m_HaveBroadcastPack = true;
			}
			t = packServer->Attribute("broadcastmask");
			if (t != NULL)
			{
				pack->m_BroadcastPacketMask = t;
			}
			
			t = packServer->Attribute("mod");
			if (t != NULL)
			{
				pack->m_ModName = t;
			}

			m_GamePackets.Add(pack);

			packServer = packServer->NextSiblingElement("packet");
		}

		TiXmlElement * packBroadcast = serverDetect->FirstChildElement("broadcast");
		if (packBroadcast != NULL)
		{
			const char * t;
			int v;

			t = packBroadcast->Attribute("emulation", &v);
			if (t != NULL)
				m_BroadcastEmu = (v != 0);

			t = packBroadcast->Attribute("disable", &v);
			if (t != NULL)
				m_BroadcastDisable = (v != 0);

			t = packBroadcast->Attribute("send", &v);
			if (t != NULL)
				m_BroadcastSendEmu = (v != 0);

			t = packBroadcast->Attribute("forceport", &v);
			if (t != NULL)
				m_BroadcastForcePort = (v != 0);

			t = packBroadcast->Attribute("clientforceport", &v);
			if (t != NULL)
				m_BroadcastClientForcePort = (v != 0);

			t = packBroadcast->Attribute("tunnel", &v);
			if (t != NULL)
				m_BroadcastTunnel = (v != 0);

			t = packBroadcast->Attribute("tunnelfakeaddress", &v);
			if (t != NULL)
				m_BroadcastTunnelFakeAddress = (v != 0);

			t = packBroadcast->Attribute("notify", &v);
			if (t != NULL)
				m_BroadcastNotify = (v != 0);

			t = packBroadcast->Attribute("lanbroadcast", &v);
			if (t != NULL)
				m_BroadcastLan = (v != 0);

			t = packBroadcast->Attribute("guessfwdaddr", &v);
			if (t != NULL)
				m_GuessForwardAddress = (v != 0);

			t = packBroadcast->Attribute("addressemu", &v);
			if (t != NULL)
				m_AddressEmulation = (v != 0);

			t = packBroadcast->Attribute("addfakeaddr", &v);
			if (t != NULL)
				m_AddFakeAddress = (v != 0);

			t = packBroadcast->Attribute("bindforce", &v);
			if (t != NULL)
				m_BindForceAllInterfaces = (v != 0);

			t = packBroadcast->Attribute("enableglobaltunnel", &v);
			if (t != NULL)
				m_EnableGlobalTunnel = (v != 0);

			TiXmlElement * packPort = packBroadcast->FirstChildElement("port");
			while (packPort != NULL)
			{
				t = packPort->Attribute("value", &v);
				if (t != NULL)
					m_BroadcastPorts.Add((WORD)v);

				packPort = packPort->NextSiblingElement("port");
			}
		}
	}

	// Game hooks
	TiXmlElement * packHook = xml->FirstChildElement("hook");
	if (packHook != NULL)
	{
		const char * n = packHook->Attribute("name");

		m_GameHook = pCreateGameHook(n);
		if (m_GameHook == NULL)
		{
			hk::GetLogManager().Printf("Failed to create game hook with type '%s'\n", n);
			return;
		}

		if (!m_GameHook->Initialize(packHook))
		{
			delete m_GameHook;
			m_GameHook = NULL;

			hk::GetLogManager().Printf("Failed to initialize game hook.\n");
			return;
		}
	}

	// Blocks
	TiXmlElement * packBlocks = xml->FirstChildElement("blocks");
	if (packBlocks != NULL)
	{
		// Load DNS blocks
		TiXmlElement * packDnsBlock = packBlocks->FirstChildElement("dns");
		while (packDnsBlock != NULL)
		{
			const char * t = packDnsBlock->Attribute("name");
			if (t != NULL)
			{
				m_BlockedAddresses.Add(t);

				if (theConfig.IsDebugLoggingEnabled())
					hk::GetLogManager().Printf("Added DNS block '%s'\n", t);
			}

			packDnsBlock = packDnsBlock->NextSiblingElement("dns");
		}
	}

	m_Valid = true;
}

pGameInfo::~pGameInfo()
{
	if (ServerIsActivated())
	{
		ServerDeactivate();
	}

	if (m_GameHook != NULL)
	{
		delete m_GameHook;
		m_GameHook = NULL;
	}

	for (DWORD i = 0; i < m_AppSignatures.GetSize(); i++)
	{
		delete m_AppSignatures[i];
	}

	for (DWORD i = 0; i < m_GamePatches.GetSize(); i++)
	{
		delete m_GamePatches[i];
	}

	for (DWORD i = 0; i < m_GamePackets.GetSize(); i++)
	{
		delete m_GamePackets[i];
	}
}

bool	pGameInfo::CheckForGame()
{
	bool	hadName = false;

	// Check name first
	for (int i = 0; i < m_AppNames.GetSize(); i++)
	{
		if (!_strcmpi(theConfig.GetGameName(), m_AppNames[i].c_str()))
		{
			hadName = true;
			break;
		}
	}

	if (m_AppNames.GetSize() > 0 && !hadName)
	{
		return false;
	}

	// Check signatures
	if (m_AppSignatures.GetSize() > 0)
	{
		for (DWORD i = 0; i < m_AppSignatures.GetSize(); i++)
		{
			if (m_AppSignatures[i]->DoSearch() != NULL)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}

	return true;
}

bool	pGameInfo::Activate()
{
	if (DoActivate())
	{
		bool needDelay = false;
		for (DWORD i = 0; i < m_GamePatches.GetSize(); i++)
		{
			if (m_GamePatches[i]->IsDelayed())
			{
				needDelay = true;
				break;
			}
		}

		if (needDelay)
		{
			DWORD tid;
			m_hThread = CreateThread(NULL, 0x10000, &threadProc, this, 0, &tid);
		}

		return true;
	} 

	return false;
}

bool	pGameInfo::Deactivate()
{
	if (m_hThread != 0)
		TerminateThread(m_hThread, 0);

	if (m_GameHook != NULL)
	{
		m_GameHook->Deactivate();
	}

	for (DWORD i = 0; i < m_GamePatches.GetSize(); i++)
	{
		if (m_GamePatches[i]->IsActive())
		{
			m_GamePatches[i]->Unpatch();
		}
	}

	return true;
}

void	pGameInfo::ServerActivate(in_addr addr, WORD port, DWORD modID)
{
	m_ServerActivated = true;

	m_ServerAddr = addr;
	m_ServerPort = port;

	m_ServerModName = theGame.GetActiveGame()->GetModName(modID);
	hk::GetLogManager().Printf("ServerActivate() '%d', '%s'\n", modID, m_ServerModName.c_str());

	hk::GetLogManager().Write("Server activated.\n");
}

void	pGameInfo::ServerDeactivate()
{
	m_ServerActivated = false;

	hk::GetLogManager().Write("Server deactivated.\n");
}

bool	pGameInfo::DoActivate()
{
	if (m_GameHook != NULL)
	{
		if (!m_GameHook->Activate())
		{
			hk::GetLogManager().Printf("Failed to activate game hook.\n");
			return false;
		}
	}

	for (DWORD i = 0; i < m_GamePatches.GetSize(); i++)
	{
		if (!m_GamePatches[i]->Patch())
		{
			if (!m_GamePatches[i]->IsDelayed())
			{
				hk::GetLogManager().Printf("Failed to apply patch %d for game '%s'\n", i, m_GameName.c_str());
				return false;
			}
		}
	}

	// Start worker thread
	pAsyncUpdater::Initialize();

	// Hook imports
	pSocketHook::Initialize();

	return true;
}
//////////////////////////////////////////////////////////////////////////
bool	pGameInfo::CheckPacket(hk::hkDataBuffer & packBuf, TiXmlString & packMask, LPVOID pBuf, int dwBuf)
{
	if (dwBuf < packBuf.GetBufferLen())
		return false;

	if (packMask.length() == 0)
	{
		return memcmp(packBuf.GetBuffer(), pBuf, packBuf.GetBufferLen()) == 0;
	} else
	{
		const BYTE * tBuf = (const BYTE *)packBuf.GetBuffer();
		const BYTE * sBuf = (const BYTE *)pBuf;

		for (int i = 0; i < packMask.length(); i++)
		{
			if (packMask[i] != '?')
			{
				if (i >= packBuf.GetBufferLen())
					break;

				if (sBuf[i] != tBuf[i])
				{
					return false;
				}
			}
		}

		return true;
	}
}

bool	pGameInfo::IsServerReplyPack(LPVOID pBuf, int dwBuf, DWORD & modID)
{
	for (DWORD i = 0; i < m_GamePackets.GetSize(); i++)
	{
		pPacket_t * pack = m_GamePackets[i];

		if (pack->m_ReplyPacket.GetBufferLen() > 0 &&
			CheckPacket(pack->m_ReplyPacket, pack->m_ReplyPacketMask, pBuf, dwBuf))
		{
			modID = i;
			return true;
		}
	}

	return false;
}

bool	pGameInfo::IsServerBroadcastPack(LPVOID pBuf, int dwBuf, DWORD & modID)
{
	for (DWORD i = 0; i < m_GamePackets.GetSize(); i++)
	{
		pPacket_t * pack = m_GamePackets[i];

		if (pack->m_BroadcastPacket.GetBufferLen() > 0 &&
			CheckPacket(pack->m_BroadcastPacket, pack->m_BroadcastPacketMask, pBuf, dwBuf))
		{
			modID = i;
			return true;
		}
	}

	return false;	
}

const	TiXmlString &	pGameInfo::GetModName(DWORD modID)
{
	static	TiXmlString	empty;

	if (modID >= m_GamePackets.GetSize())
		return empty;

	return m_GamePackets[modID]->m_ModName;
}
//////////////////////////////////////////////////////////////////////////
DWORD	WINAPI	pGameInfo::threadProc(LPVOID param)
{
	pGameInfo * game = (pGameInfo *)param;

	game->ThreadWorker();

	return 0;
}

void	pGameInfo::ThreadWorker()
{
	while (true)
	{
		for (DWORD i = 0; i < m_GamePatches.GetSize(); i++)
		{
			if (m_GamePatches[i]->IsDelayed() &&
				!m_GamePatches[i]->IsActive())
			{
				if (m_GamePatches[i]->Patch())
				{
					hk::GetLogManager().Printf("Applied delayed patch %d\n", i);
				}
			}
		}

		Sleep(3000);
	}
}
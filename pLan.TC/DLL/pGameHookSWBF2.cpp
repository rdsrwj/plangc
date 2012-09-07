#include	"stdafx.h"

#define	KEEP_SOCKET	30000

pGameHookSWBF2::pGameHookSWBF2()
{
	m_hBroadcastCache = INVALID_SOCKET;
	m_hReceiveCache = INVALID_SOCKET;
}

pGameHookSWBF2::~pGameHookSWBF2()
{
}

bool	pGameHookSWBF2::Initialize(TiXmlElement * xmlElement)
{
	// Load broadcast socket info
	TiXmlElement * xmlBroadcast = xmlElement->FirstChildElement("sockbroadcast");
	if (xmlBroadcast == NULL)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to load broadcast info.\n");
		return false;
	}
	if (!m_BroadcastPatch.Initialize(xmlBroadcast))
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to parse broadcast info.\n");
		return false;
	}

	// Load receive socket info
	TiXmlElement * xmlReceive = xmlElement->FirstChildElement("sockreceive");
	if (xmlReceive == NULL)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to load receive info.\n");
		return false;
	}
	if (!m_ReceivePatch.Initialize(xmlReceive))
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to parse receive info.\n");
		return false;
	}

	// Load receive socket close info
	TiXmlElement * xmlClose = xmlElement->FirstChildElement("sockclose");
	if (xmlClose == NULL)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to load receive info.\n");
		return false;
	}
	if (!m_ClosePatch.Initialize(xmlClose))
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to parse receive info.\n");
		return false;
	}

	return true;
}

bool	pGameHookSWBF2::Activate()
{
	// Broadcast socket
	BYTE * pBroadcast = (BYTE *)m_BroadcastPatch.DoSearch();
	if (pBroadcast == NULL)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to apply broadcast socket fix.\n");
		return false;
	}
	m_BroadcastSock = *(SOCKET **)(pBroadcast + 1);
	
	if (theConfig.IsDebugLoggingEnabled())
		hk::GetLogManager().Printf("Broadcast Sock: (%x) %x\n", pBroadcast, m_BroadcastSock);
	
	// Receive socket
	BYTE * pReceive = (BYTE *)m_ReceivePatch.DoSearch();
	if (pReceive == NULL)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to apply receive socket fix.\n");
		return false;
	}
	m_ReceiveSock = *(SOCKET **)(pReceive + 2);

	if (theConfig.IsDebugLoggingEnabled())
		hk::GetLogManager().Printf("Receives Sock: (%x) %x\n", pReceive ,m_ReceiveSock);

	// Function hook
	m_pCloseSock = (BYTE *)m_ClosePatch.DoSearch();
	if (m_pCloseSock == NULL)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to get close socket fix location.\n");
		return false;
	}

	if (theConfig.IsDebugLoggingEnabled())
		hk::GetLogManager().Printf("CloseSock: (%x)\n", m_pCloseSock);

	LPVOID result = hk::GetDetourManager().CreateCall(m_pCloseSock, &Callback);
	m_retPatch = hk::GetPatchManager().AddPatch(m_pCloseSock + 5, "\xC3", 1);
	if (result == NULL || m_retPatch == -1)
	{
		hk::GetLogManager().Write("[SW:BF2] Failed to apply close socket fix.\n");
		return false;
	}

	hk::GetLogManager().Write("[SW:BF2] Module activated.\n");

	m_hBroadcastCache = INVALID_SOCKET;
	m_hReceiveCache = INVALID_SOCKET;

	return true;
}

void	pGameHookSWBF2::Deactivate()
{
	hk::GetDetourManager().RemovePatch(m_pCloseSock);
	hk::GetPatchManager().DelPatch(m_retPatch);
}

hkCallbackResult	pGameHookSWBF2::do_send(SOCKET s, const char* buf, int len, int flags)
{
	DWORD	now = GetTickCount();

	// Check for broadcast timeout
	if (m_hBroadcastCache != INVALID_SOCKET)
	{
		if (now - m_CloseTime > KEEP_SOCKET)
		{
			if (*m_BroadcastSock == m_hBroadcastCache)
				*m_BroadcastSock = 0;
			if (*m_ReceiveSock == m_hReceiveCache)
				*m_ReceiveSock = 0;

			pSocketHook::theSockServer.RemoveSocket(m_hBroadcastCache);
			pSocketHook::real_closesocket(m_hBroadcastCache);
			
			pSocketHook::theSockServer.RemoveSocket(m_hReceiveCache);
			pSocketHook::real_closesocket(m_hReceiveCache);

			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("[SW:BF2] Closed sockets.\n");

			m_hBroadcastCache = INVALID_SOCKET;
			m_hReceiveCache = INVALID_SOCKET;
		}
	}

	return hkCallback_Ignore;
}

hkCallbackResult	pGameHookSWBF2::do_closesocket(SOCKET s)
{
	if (s == m_hBroadcastCache)
	{
		hk::GetLogManager().Write("[SW:BF2] Closing broadcast socket...\n");

		m_hBroadcastCache = INVALID_SOCKET;
	}

	if (s == m_hReceiveCache)
	{
		hk::GetLogManager().Write("[SW:BF2] Closing receive socket...\n");

		m_hReceiveCache = INVALID_SOCKET;
	}

	return hkCallback_Ignore;
}

void	pGameHookSWBF2::CloseSockets()
{
	hk::GetLogManager().Write("[SW:BF2] Closing sockets...\n");

	m_hBroadcastCache = *m_BroadcastSock;
	m_hReceiveCache = *m_ReceiveSock;

	m_CloseTime = GetTickCount();
}

void	WINAPI	pGameHookSWBF2::Callback()
{
	pGameHookSWBF2	*	pGame = (pGameHookSWBF2 *)theGame.GetActiveGame()->GetHook();
	pGame->CloseSockets();
}
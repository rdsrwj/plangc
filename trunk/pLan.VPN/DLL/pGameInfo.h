#pragma once

class	pGameInfo
{
public:
		pGameInfo(TiXmlElement * xml);
		~pGameInfo();

		bool	IsValid()
		{
			return m_Valid;
		}

		inline	const	char	* GetName()
		{
			return m_GameName.c_str();
		}

		inline	const	char	* GetDescription()
		{
			return m_GameDesc.c_str();
		}

		bool	CheckForGame();

		bool	Activate();
		bool	Deactivate();

		//////////////////////////////////////////////////////////////////////////
		WORD	ServerBindPort() const
		{
			return m_BindServerPort;
		}

		WORD	ServerBindLoPort() const
		{
			return m_BindServerLoPort;
		}

		WORD	ServerBindHiPort() const
		{
			return m_BindServerHiPort;
		}

		bool	ServerNetPacketEnabled() const
		{
			return ((m_RequestPacket.GetBufferLen() > 0) && m_HaveReplyPack);
		}

		hk::hkDataBuffer	&	ServerGetRequestPack()
		{
			return m_RequestPacket;
		}

		bool	HaveServerReplyPack()
		{
			return m_HaveReplyPack;
		}
		bool	IsServerReplyPack(LPVOID pBuf, int dwBuf, DWORD & modID);

		bool	HaveServerBroadcastPack()
		{
			return m_HaveBroadcastPack;
		}
		bool	IsServerBroadcastPack(LPVOID pBuf, int dwBuf, DWORD & modID);

		const	TiXmlString &	GetModName(DWORD modID);
		//////////////////////////////////////////////////////////////////////////
		// Server detection
		void	ServerActivate(in_addr addr, WORD port, DWORD modID);
		void	ServerDeactivate();

		const TiXmlString &	GetServerModName() const
		{
			return m_ServerModName;
		}

		bool	ServerIsActivated() const
		{
			return m_ServerActivated;
		}
		//////////////////////////////////////////////////////////////////////////
		// Broadcast related
		bool	BroadcastIsEmulated() const
		{
			return m_BroadcastEmu;
		}

		bool	BroadcastDisableInEmulation() const
		{
			return m_BroadcastDisable;
		}

		bool	BroadcastNeedSendCheck() const
		{
			return m_BroadcastSendEmu;
		}

		bool	BroadcastForcePort() const
		{
			return m_BroadcastForcePort;
		}

		bool	BroadcastClientForcePort() const
		{
			return m_BroadcastClientForcePort;
		}

		bool	BroadcastTunnel() const
		{
			return m_BroadcastTunnel;
		}

		bool	BroadcastTunnelFakeAddress() const
		{
			return m_BroadcastTunnelFakeAddress;
		}

		bool	BroadcastNotify() const
		{
			return m_BroadcastNotify;
		}

		bool	BroadcastLan() const
		{
			return m_BroadcastLan;
		}

		bool	BroadcastIsPeerPort(WORD port) const
		{
			if (m_BroadcastPorts.GetSize() == 0)
				return true;

			for (DWORD i = 0; i < m_BroadcastPorts.GetSize(); i++)
			{
				if (m_BroadcastPorts[i] == port)
					return true;
			}

			return false;
		}

		in_addr	ServerGetAddress() const
		{
			return m_ServerAddr;
		}

		WORD	ServerGetPort() const
		{
			return m_ServerPort;
		}

		bool	IsAddressBlocked(const char * szAddr)
		{
			for (DWORD i = 0; i < m_BlockedAddresses.GetSize(); i++)
			{
				if (strstr(szAddr, m_BlockedAddresses[i].c_str()))
					return true;
			}

			return false;
		}

		bool	AddressEmulationEnabled()
		{
			return m_AddressEmulation;
		}

		bool	AddFakeAddress()
		{
			return m_AddFakeAddress;
		}

		bool	BindForceAllInterfaces()
		{
			return m_BindForceAllInterfaces;
		}

		bool	IsGuessForwardAddressEnabled()
		{
			return m_GuessForwardAddress;
		}

		bool	EnableGlobalTunnel()
		{
			return m_EnableGlobalTunnel;
		}
		//////////////////////////////////////////////////////////////////////////
		pGameHookBase	*	GetHook()
		{
			return m_GameHook;
		}
private:
		typedef hk::hkDynBuffer<TiXmlString>	pStrings_t;

		TiXmlString	m_GameName;
		TiXmlString	m_GameDesc;

		// Identification
		pStrings_t	m_AppNames;

		typedef	hk::hkDynBuffer<pGameSearch *>	pGameSearches_t;
		pGameSearches_t	m_AppSignatures;

		// Patches
		typedef	hk::hkDynBuffer<pGamePatch *>	pGamePatches_t;
		pGamePatches_t	m_GamePatches;

		// Blocked hosts
		pStrings_t	m_BlockedAddresses;

		// Server detection
		WORD	m_BindServerPort;

		WORD	m_BindServerLoPort;
		WORD	m_BindServerHiPort;

		hk::hkDataBuffer	m_RequestPacket;

		// Packets
		typedef	struct 
		{
			hk::hkDataBuffer	m_ReplyPacket;
			TiXmlString			m_ReplyPacketMask;

			hk::hkDataBuffer	m_BroadcastPacket;
			TiXmlString			m_BroadcastPacketMask;

			TiXmlString			m_ModName;
		} pPacket_t;
		typedef	hk::hkDynBuffer<pPacket_t *>	pGamePackets_t;
		pGamePackets_t			m_GamePackets;

		bool	m_HaveReplyPack;
		bool	m_HaveBroadcastPack;

		// Server activity flag
		bool	m_ServerActivated;
		in_addr	m_ServerAddr;
		WORD	m_ServerPort;
		TiXmlString	m_ServerModName;

		bool	m_BroadcastEmu;
		bool	m_BroadcastSendEmu;
		bool	m_BroadcastForcePort;
		bool	m_BroadcastClientForcePort;
		bool	m_BroadcastTunnel;
		bool	m_BroadcastTunnelFakeAddress;
		bool	m_BroadcastDisable;
		bool	m_BroadcastNotify;
		bool	m_BroadcastLan;

		bool	m_AddressEmulation;
		bool	m_AddFakeAddress;

		bool	m_BindForceAllInterfaces;

		bool	m_GuessForwardAddress;
		bool	m_EnableGlobalTunnel;

		typedef	hk::hkDynBuffer<WORD>	pGamePorts_t;
		pGamePorts_t	m_BroadcastPorts;

		pGameHookBase	*	m_GameHook;

		// Validity flag
		bool	m_Valid;

		//////////////////////////////////////////////////////////////////////////
		bool	DoActivate();

		bool	CheckPacket(hk::hkDataBuffer & packBuf, TiXmlString & packMask, LPVOID pBuf, int dwBuf);

		//////////////////////////////////////////////////////////////////////////
		HANDLE	m_hThread;

		static	DWORD	WINAPI	threadProc(LPVOID param);
		void	ThreadWorker();
};
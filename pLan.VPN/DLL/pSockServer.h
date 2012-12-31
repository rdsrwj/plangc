#pragma once

// Server verification check
#define		CHECK_INTERVAL		30000
// Server reply timeout
#define		REPLY_TIMEOUT		5000
// If no servers found, recheck timeout
#define		CHECK_RECHECK		10000

// pLan packet
#define	PLAN_MAGIC	'pLan'

#pragma pack(push, 1)
#pragma pack(1)

#define	PLAN_PACK_BROADCAST	0x00
#define	PLAN_PACK_NOTIFY	0x01

typedef	struct 
{
	DWORD	m_ID;
	BYTE	m_PacketType;
	WORD	m_Port;
	WORD	m_RemotePort;
} pLanTunnelPack_t;

#define	PLAN_FAKE_MAGIC	'pLfp'

// pLan fake packet
typedef	struct 
{
	DWORD	m_ID;
	WORD	m_Unique;
} pLanFakePack_t;

#pragma	pack(pop, 1)


class	pSockServer
{
public:
		pSockServer();
		~pSockServer();

		bool	Initialize();
		bool	Deinitialize();

		// Socket functions
		void	VerifySocket(SOCKET hSock);
		void	RemoveSocket(SOCKET hSock);

		// Broadcasting
		void	Broadcast(SOCKET hSock, const char *buf, int len, int flags, sockaddr_in * targetaddr, bool connectionOriented);
		int		SendTo(SOCKET hSock, const char * szBuffer, int len, int flags, const sockaddr_in * remoteaddr);

		// Broadcast emulation
		void	BroadcastNotifyIP(in_addr raddr, WORD rport);

		// Local port
		WORD	GetLocalPort() const
		{
			return m_localPort;
		}
private:
		SOCKET	m_hSocket;
		WORD	m_localPort;

		SOCKET	m_ServerSock;

		bool	m_NeedWork;
		bool	m_Working;
		HANDLE	m_ThreadHandle;

		pMutex		m_Mutex;

//		DWORD	m_LastServerBroadcast;
		DWORD	m_LastServerBroadcastNotify;
		DWORD	m_LastAddressEmuRecheck;

//		hkAddrBuffer_t	m_LocalAddresses;

		typedef	hk::hkDynBuffer<SOCKET>	socketList_t;
		socketList_t	m_KnownSockets;
		socketList_t	m_NewSockets;
		
//		hkAddrBuffer_t	m_ServerAddresses;

		// Broadcast emulation
		typedef	struct 
		{
			in_addr	m_addr;
			WORD	m_port;
			DWORD	m_time;
		} ipInfo_t;
		typedef hk::hkDynBuffer<ipInfo_t>	ipInfos_t;

		ipInfos_t	m_BroadcastAddresses;

		//////////////////////////////////////////////////////////////////////////
		static	DWORD	WINAPI	threadWrapper(LPVOID param);

		void	threadProc();
		//////////////////////////////////////////////////////////////////////////
		bool	GetLocalAddresses();
		bool	IsLocalAddress(in_addr addr);
		//////////////////////////////////////////////////////////////////////////
		bool	SendServerRequest(SOCKET tSock, sockaddr_in & raddr);
		//////////////////////////////////////////////////////////////////////////
		int		BroadcastEmuSend(SOCKET hSock, const char * szBuffer, int len, int flags, sockaddr_in * remoteaddr, bool connectionOriented);
};

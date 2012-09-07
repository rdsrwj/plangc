#include "stdafx.h"

#define		BROADCAST_TIMEOUT	15000
#define		BROADCAST_NOTIFY	(BROADCAST_TIMEOUT - 5000)
#define		ADDREMU_RECHECK		10000

pSockServer::pSockServer()
{
	m_ServerSock = INVALID_SOCKET;
	m_hSocket = INVALID_SOCKET;
}

pSockServer::~pSockServer()
{
}

bool	pSockServer::Initialize()
{
	DWORD	tid;

	m_NeedWork = true;
	m_Working  = false;

	m_ThreadHandle = CreateThread(NULL, 0x10000, &threadWrapper, this, 0, &tid);
	if (m_ThreadHandle != NULL)
	{
/*		while (!m_Working)
		{
			Sleep(50);
			hk::GetLogManager().Write("Waiting...\n");
		} */
	} else
	{
		hk::GetLogManager().Write("Failed to create thread.\n");
	}

	return true;
}

bool	pSockServer::Deinitialize()
{
	m_NeedWork = false;

	TerminateThread(m_ThreadHandle, 0);

	return true;
}
//////////////////////////////////////////////////////////////////////////
void	pSockServer::VerifySocket(SOCKET hSock)
{
	if (hSock == m_hSocket)
		return;

	m_Mutex.Lock();

	// Check if socket was previously detected
	for (DWORD i = 0; i < m_KnownSockets.GetSize(); i++)
		if (m_KnownSockets[i] == hSock)
		{
			// It is, quitting
			m_Mutex.Unlock();
			return;
		}

	// Add socket to detected list
	m_KnownSockets.Add(hSock);

	// Get socket type
	int value = 0;
	int size = (int)sizeof(value);
	getsockopt(hSock, SOL_SOCKET, SO_TYPE, (char *)&value, &size);

	// If server is not activated and socket is UDP
	if (!theGame.GetActiveGame()->ServerIsActivated() && value == SOCK_DGRAM)
	{
		sockaddr_in name;
		int namelen = sizeof(name);

		// Get local name
		if (getsockname(hSock, (sockaddr *)&name, &namelen) == 0)
		{
			// Get bind port (in specified)
			WORD gamePort = theGame.GetActiveGame()->ServerBindPort();
			WORD sockPort = ntohs(name.sin_port);

			// Should we send any packets to verify server ?
			if (theGame.GetActiveGame()->ServerNetPacketEnabled())
			{
				if (gamePort == 0 || gamePort == sockPort)
				{
					if (sockPort > theGame.GetActiveGame()->ServerBindLoPort() &&
						sockPort < theGame.GetActiveGame()->ServerBindHiPort())
					{
						m_NewSockets.Add(hSock);
					}
				}
			} else
			{
				if (gamePort == sockPort)
				{
					if (theGame.GetActiveGame()->BroadcastTunnel())
					{
						theGame.GetActiveGame()->ServerActivate(name.sin_addr, ntohs(m_localPort), 0);
					} else
					{
						theGame.GetActiveGame()->ServerActivate(name.sin_addr, gamePort, 0);
					}
				}
			}
		}
	}

	m_Mutex.Unlock();
}
//////////////////////////////////////////////////////////////////////////
void	pSockServer::RemoveSocket(SOCKET hSock)
{
	m_Mutex.Lock();

	if (m_ServerSock == hSock)
	{
		theGame.GetActiveGame()->ServerDeactivate();

		m_ServerSock = INVALID_SOCKET;
	}

	// Remove from known queue
	for (DWORD i = 0; i < m_KnownSockets.GetSize(); i++)
		if (m_KnownSockets[i] == hSock)
		{
			m_KnownSockets.Remove(i);
			break;
		}

	// Remove from to-be-processed queue
	for (DWORD i = 0; i < m_NewSockets.GetSize(); i++)
		if (m_NewSockets[i] == hSock)
		{
			m_NewSockets.Remove(i);
			break;
		}

	m_Mutex.Unlock();
}
//////////////////////////////////////////////////////////////////////////
void	pSockServer::Broadcast(SOCKET hSock, const char *buf, int len, int flags, sockaddr_in * remoteaddr, bool connectionOriented)
{
	// Fetch addresses (update list)
	pAsyncUpdater::GetAddresses(m_ServerAddresses);

	// If we have broadcast packet, check it
	if (theGame.GetActiveGame()->HaveServerBroadcastPack())
	{
		hk::GetLogManager().Write("Verifying broadcast...\n");

		DWORD	modID;
		if (theGame.GetActiveGame()->IsServerBroadcastPack((LPVOID)buf, len, modID))
		{
			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("[Broadcast] Catched broadcast packet, server activated\n");

			// TODO: mod handling

			m_LastServerBroadcastNotify = GetTickCount();

			in_addr addr;
			addr.S_un.S_addr = INADDR_ANY;
			theGame.GetActiveGame()->ServerActivate(addr, ntohs(m_localPort), modID);
		}
	}

	// If tunneled game, prepare packet
	hk::hkDataBuffer	pbuf;
	if (theGame.GetActiveGame()->BroadcastTunnel() && remoteaddr->sin_port != 0)
	{
		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Write("Broadcasting tunneled packet.\n");

		pbuf.Clear();

		pLanTunnelPack_t	pack;
		pack.m_ID = PLAN_MAGIC;
		pack.m_PacketType = PLAN_PACK_BROADCAST;
		pack.m_Port = remoteaddr->sin_port;

		sockaddr_in taddr;
		int taddrlen = sizeof(taddr);
		if (getsockname(hSock, (sockaddr *)&taddr, &taddrlen) == 0)
		{
			pack.m_RemotePort = taddr.sin_port;
		} else
		{
			pack.m_RemotePort = remoteaddr->sin_port;
		}

		pbuf.AddBuffer(&pack, sizeof(pack));
		pbuf.AddBuffer((const LPVOID)buf, len);

		// Swap pointers
		buf = (const char *)pbuf.GetBuffer();
		len = pbuf.GetBufferLen();
	}

	// Forward to local port (for server detection)
	{
		sockaddr_in saddr = {0};
		int saddrlen = sizeof(saddr);
		saddr.sin_family = AF_INET;
		saddr.sin_addr.S_un.S_addr = htonl(INADDR_LOOPBACK);
		saddr.sin_port = m_localPort;

		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Printf("Send to local %s:%d\n", inet_ntoa(saddr.sin_addr), ntohs(saddr.sin_port));

		if (connectionOriented)
		{
			connect(hSock, (const sockaddr *)&saddr, sizeof(saddr));

			if (pSocketHook::real_send(hSock, buf, len, flags) <= 0)
			{
				hk::GetLogManager().Write("Failed to forward to local\n");
			}
		} else
		{
			pSocketHook::real_sendto(hSock, buf, len, flags, (const sockaddr *)&saddr, sizeof(saddr));
		}
	}

	if (theGame.GetActiveGame()->BroadcastIsEmulated())
	{
		// Emulate it
		if (theGame.GetActiveGame()->ServerIsActivated())
		{
			BroadcastEmuSend(hSock, buf, len, flags, remoteaddr, connectionOriented);

			if (connectionOriented)
				connect(hSock, (const sockaddr *)remoteaddr, sizeof(sockaddr_in));

			return;
		}
	} 

	// Check if game with emulated broadcast functionality
	if (!theGame.GetActiveGame()->ServerIsActivated())
	{
		// Just broadcast request to available servers
		for (DWORD i = 0; i < m_ServerAddresses.GetSize(); i++)
		{
			hkAddr_t & taddr = m_ServerAddresses[i];

			sockaddr_in saddr = {0};
			saddr.sin_family = AF_INET;
			saddr.sin_addr	 = taddr.m_addr;

			if (theGame.GetActiveGame()->BroadcastClientForcePort())
			{
				saddr.sin_port	 = remoteaddr->sin_port;
			} else
			{
				saddr.sin_port   = taddr.m_port;
			}

			int pLen = 0;

			if (theGame.GetActiveGame()->BroadcastTunnel())
			{
				pLen = pSocketHook::real_sendto(m_hSocket, buf, len, flags, (const sockaddr *)&saddr, sizeof(saddr));
			} else
			{
				if (connectionOriented)
				{
					connect(hSock, (const sockaddr *)&saddr, sizeof(saddr));

					pLen = pSocketHook::real_send(hSock, buf, len, flags);
				} else
				{
					pLen = pSocketHook::real_sendto(hSock, buf, len, flags, (const sockaddr *)&saddr, sizeof(saddr));
				}
			}

			if (theConfig.IsDebugLoggingEnabled())
			{
				if (pLen > 0)
				{
					hk::GetLogManager().Printf("Forwarded packet to %s:%d\n", inet_ntoa(taddr.m_addr), ntohs(taddr.m_port));
				} else
				{
					hk::GetLogManager().Printf("Failed to forward packet to %s:%d\n", inet_ntoa(taddr.m_addr), ntohs(taddr.m_port));
				}
			}
		}
	}

	// Restore connection
	if (connectionOriented)
		connect(hSock, (const sockaddr *)remoteaddr, sizeof(sockaddr_in));
}
//////////////////////////////////////////////////////////////////////////
DWORD	WINAPI	pSockServer::threadWrapper(LPVOID param)
{
	pSockServer * pServer = (pSockServer *)param;

	pServer->threadProc();

	return 0;
}
//////////////////////////////////////////////////////////////////////////
void	pSockServer::threadProc()
{
	hk::hkDataBuffer	buf;

	DWORD	tickStart;
	bool	inProcess = false;

	sockaddr_in raddr;

	SOCKET	checkSock;

	DWORD	tickLastCheck = 0;
	DWORD	tickRecheck = GetTickCount();
	DWORD	tickNotify = GetTickCount();

	m_Working = true;

	while (m_NeedWork)
	{
		DWORD	curTime = GetTickCount();

		// Check if socket was created
		if (m_hSocket == INVALID_SOCKET)
		{
			m_hSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
			if (m_hSocket == INVALID_SOCKET)
			{
				if (theConfig.IsDebugLoggingEnabled())
				{
					HRESULT hr = WSAGetLastError();
					hk::GetLogManager().Printf("[ServerDetect] Failed to create socket (%x)\n", hr);
				}

				m_ThreadHandle = 0;
				break;
			}

			sockaddr	addr = {0};
			addr.sa_family = AF_INET;

			if (bind(m_hSocket, &addr, sizeof(addr)))
			{
				HRESULT hr = WSAGetLastError();
				hk::GetLogManager().Printf("[ServerDetect] Failed to bind socket (%x)\n", hr);
				break;
			}

			sockaddr_in	inaddr = {0};
			int inaddrlen = sizeof(inaddr);
			if (getsockname(m_hSocket, (sockaddr *)&inaddr, &inaddrlen))
			{
				HRESULT hr = WSAGetLastError();
				hk::GetLogManager().Printf("[ServerDetect] Failed to get local socket port (%x)\n", hr);
				break;
			}
			m_localPort = inaddr.sin_port;

			char v = 1;
			setsockopt(m_hSocket, SOL_SOCKET, SO_BROADCAST, &v, sizeof(v));

			hk::GetLogManager().Printf("Local pLan port is %d\n", ntohs(m_localPort));

			GetLocalAddresses();
		}

		// Check for server
		if (theGame.GetActiveGame()->ServerNetPacketEnabled())
		{
			if (!inProcess)
			{
				// Check if there any sockets require to be processed
				m_Mutex.Lock();
				if (m_NewSockets.GetSize() > 0 && !theGame.GetActiveGame()->ServerIsActivated())
				{
					m_NewSockets.Pop(checkSock);

					inProcess = SendServerRequest(checkSock, raddr);
					if (inProcess)
						tickStart = curTime;

					if (theConfig.IsDebugLoggingEnabled())
						hk::GetLogManager().Printf("[Server] Checking server address %s:%d\n", inet_ntoa(raddr.sin_addr), ntohs(raddr.sin_port));
				}
				m_Mutex.Unlock();
			} else
			{
				// Reply verification
				if (curTime - tickStart > REPLY_TIMEOUT)
				{
					inProcess = false;

					if (theConfig.IsDebugLoggingEnabled())
						hk::GetLogManager().Write("[ServerDetect] Server reply timed out.\n");

					if (m_ServerSock == checkSock)
					{
						m_ServerSock = INVALID_SOCKET;

						theGame.GetActiveGame()->ServerDeactivate();
					}
				} 
			}
		}

		// Receive packets
		fd_set fd;
		FD_ZERO(&fd);
		FD_SET(m_hSocket, &fd);

		timeval timeout = {0};
		timeout.tv_usec = 100000;

		while (pSocketHook::real_select(FD_SETSIZE, &fd, NULL, NULL, &timeout) > 0)
		{
			sockaddr_in saddr;
			int addrlen = sizeof(saddr);

			int len = pSocketHook::real_recvfrom(m_hSocket, (char *)buf.GetBuffer(), HKMAX_BUFFER_LEN, 0, (sockaddr *)&saddr, &addrlen);
			if (len > 0)
			{
				buf.SetBufferLen(len);

				if (theConfig.IsDebugLoggingEnabled())
				{
					hk::GetLogManager().Printf("[Server] Received pack from %s:%d\n", inet_ntoa(saddr.sin_addr), ntohs(saddr.sin_port));

					if (theConfig.IsTrafficDumpEnabled())
						hk::GetLogManager().Dump(buf.GetBuffer(), len);
				}

				// If we are waiting for the packet, process it
				if (IsLocalAddress(saddr.sin_addr))
				{
					DWORD	modID;

					if (inProcess)
					{
						bool result = false;
						if (theGame.GetActiveGame()->BroadcastTunnel())
						{
							BYTE * pBuf = buf.GetBuffer();
							pLanTunnelPack_t * pPack = (pLanTunnelPack_t *)buf.GetBuffer();

							if (pPack->m_ID == PLAN_MAGIC)
							{
								if (buf.GetBufferLen() > sizeof(pLanTunnelPack_t))
								{
									result = theGame.GetActiveGame()->IsServerReplyPack(pBuf + sizeof(pLanTunnelPack_t), buf.GetBufferLen() - sizeof(pLanTunnelPack_t), modID);
								}
							} else
							{
								result = theGame.GetActiveGame()->IsServerReplyPack(buf.GetBuffer(), buf.GetBufferLen(), modID);
							}
						} else
						{
							result = theGame.GetActiveGame()->IsServerReplyPack(buf.GetBuffer(), buf.GetBufferLen(), modID);
						}

						if (result)
						{	
							if (raddr.sin_addr.S_un.S_addr == htonl(INADDR_LOOPBACK))
								raddr.sin_addr.S_un.S_addr = INADDR_ANY;

							if (theGame.GetActiveGame()->BroadcastTunnel())
							{
								theGame.GetActiveGame()->ServerActivate(raddr.sin_addr, ntohs(m_localPort), modID);
							} else
							{
								theGame.GetActiveGame()->ServerActivate(raddr.sin_addr, ntohs(raddr.sin_port), modID);
							}

							m_ServerSock = checkSock;

							inProcess = false;

							tickLastCheck = curTime;
						}
					}
				}
				
				// Tunnel support
				if (len >= sizeof(pLanTunnelPack_t))
				{
					BYTE * pData = buf.GetBuffer();

					pLanTunnelPack_t * pPack = (pLanTunnelPack_t *)buf.GetBuffer();

					if (pPack->m_ID == PLAN_MAGIC)
					{
						// Notify IP
						if (theGame.GetActiveGame()->BroadcastIsEmulated())
							BroadcastNotifyIP(saddr.sin_addr, saddr.sin_port);
						
						if (pPack->m_PacketType == PLAN_PACK_BROADCAST)
						{
							// Forward it to specified port
							sockaddr_in laddr = {0};
							laddr.sin_family = AF_INET;
							laddr.sin_addr.S_un.S_addr = htonl(INADDR_LOOPBACK);
							laddr.sin_port = pPack->m_Port;

							// If we have to guess forward address, do it
							if (theGame.GetActiveGame()->IsGuessForwardAddressEnabled())
							{
								m_Mutex.Lock();

								for (DWORD i = 0; i < m_KnownSockets.GetSize(); i++)
								{
									SOCKET pSock = m_KnownSockets[i];

									int value = 0;
									int size = sizeof(value);
									getsockopt(pSock, SOL_SOCKET, SO_TYPE, (char *)&value, &size);

									if (value == SOCK_DGRAM)
									{
										sockaddr_in name;
										int namelen = sizeof(name);

										if (getsockname(pSock, (sockaddr *)&name, &namelen) == 0)
										{
											if (name.sin_port == name.sin_port)
											{
												laddr.sin_addr = name.sin_addr;

												break;
											}
										}
									}
								}

								m_Mutex.Unlock();

								if (laddr.sin_addr.S_un.S_addr == INADDR_ANY ||
									laddr.sin_addr.S_un.S_addr == INADDR_BROADCAST)
								{
									laddr.sin_addr.S_un.S_addr = htonl(INADDR_LOOPBACK);
								}

								hk::GetLogManager().Printf("Guessed local address as '%s'\n", laddr.sin_addr);
							}

							if (pPack->m_Port != m_localPort)
							{
								if (theConfig.IsDebugLoggingEnabled())
									hk::GetLogManager().Printf("[Tunnel] Local forward to %s:%d\n", inet_ntoa(laddr.sin_addr), ntohs(laddr.sin_port));

								int len = buf.GetBufferLen();
								char *data= (char *)pData;

								if (!theGame.GetActiveGame()->BroadcastTunnelFakeAddress())
								{
									if (pSocketHook::real_sendto(m_hSocket, data + sizeof(pLanTunnelPack_t), buf.GetBufferLen() - sizeof(pLanTunnelPack_t), 0, (const sockaddr *)&laddr, sizeof(laddr)) <= 0)
									{
										if (theConfig.IsDebugLoggingEnabled())
											hk::GetLogManager().Write("Failed to forward tunneled packet.\n");
									}

									if (theGame.GetActiveGame()->BroadcastLan())
									{
										laddr.sin_addr.S_un.S_addr = htonl(INADDR_BROADCAST);
										if (pSocketHook::real_sendto(m_hSocket, data + sizeof(pLanTunnelPack_t), buf.GetBufferLen() - sizeof(pLanTunnelPack_t), 0, (const sockaddr *)&laddr, sizeof(laddr)) <= 0)
										{
											if (theConfig.IsDebugLoggingEnabled())
												hk::GetLogManager().Write("Failed to forward tunneled packet to broadcast address.\n");
										}
									}
								} else
								{
									hk::hkDataBuffer	dataBuf;

									pLanFakePack_t fakePack;
									fakePack.m_ID = PLAN_FAKE_MAGIC;
									fakePack.m_Unique = pAddressFake::AddFakeBuffer(data + sizeof(pLanTunnelPack_t), len - sizeof(pLanTunnelPack_t), saddr.sin_addr, pPack->m_RemotePort);

									dataBuf.AddBuffer(&fakePack, sizeof(pLanFakePack_t));
									if (len - (int)sizeof(pLanTunnelPack_t) - (int)sizeof(pLanFakePack_t) > 0)
									{
										dataBuf.AddBuffer(data + sizeof(pLanTunnelPack_t) + sizeof(pLanFakePack_t), len - sizeof(pLanTunnelPack_t) - sizeof(pLanFakePack_t));
									}

									if (pSocketHook::real_sendto(m_hSocket, (const char *)dataBuf.GetBuffer(), dataBuf.GetBufferLen(), 0, (const sockaddr *)&laddr, sizeof(laddr)) <= 0)
									{
										if (theConfig.IsDebugLoggingEnabled())
											hk::GetLogManager().Write("Failed to forward tunneled packet.\n");
									}

									if (theGame.GetActiveGame()->BroadcastLan())
									{
										laddr.sin_addr.S_un.S_addr = htonl(INADDR_BROADCAST);
										if (pSocketHook::real_sendto(m_hSocket, (const char *)dataBuf.GetBuffer(), dataBuf.GetBufferLen(), 0, (const sockaddr *)&laddr, sizeof(laddr)) <= 0)
										{
											if (theConfig.IsDebugLoggingEnabled())
												hk::GetLogManager().Write("Failed to forward tunneled packet to broadcast address.\n");
										}
									}
								}
							} else
							{
								if (theConfig.IsDebugLoggingEnabled())
									hk::GetLogManager().Write("Ignored broadcast forward to local socket.\n");
							}
						}
					}
				}

				// Add forward code here
			} else
			{
				inProcess = false;

				if (theConfig.IsDebugLoggingEnabled())
					hk::GetLogManager().Printf("[ServerDetect] Error receiving server check reply (%x).\n", WSAGetLastError());
			}
		}

		// Check if server is running (not hung or anything else)
		if (!inProcess && m_ServerSock != INVALID_SOCKET && curTime - tickLastCheck > CHECK_INTERVAL)
		{
			inProcess = SendServerRequest(m_ServerSock, raddr);

			inProcess = true;
			tickStart = curTime;
			tickLastCheck = curTime;
		}

		// If game has broadcast packet hook, check if it is timed out
		if (theGame.GetActiveGame()->HaveServerBroadcastPack())
		{
			int delta = static_cast<int>(curTime - m_LastServerBroadcastNotify);

			if (delta > CHECK_INTERVAL && theGame.GetActiveGame()->ServerIsActivated())
			{
				if (theConfig.IsDebugLoggingEnabled())
					hk::GetLogManager().Write("[ServerDetect] Server timed out.\n");

				theGame.GetActiveGame()->ServerDeactivate();
			}
		}

		// Sockets recheck (if no server was activated)
		if (!inProcess && !theGame.GetActiveGame()->ServerIsActivated() && curTime - tickRecheck > CHECK_RECHECK)
		{
			m_Mutex.Lock();

			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("Rechecking sockets...\n");

			for (DWORD i = 0; i < m_KnownSockets.GetSize(); i++)
			{
				SOCKET pSock = m_KnownSockets[i];

				int value = 0;
				int size = sizeof(value);
				getsockopt(pSock, SOL_SOCKET, SO_TYPE, (char *)&value, &size);

				if (value == SOCK_DGRAM)
				{
					bool gotIt = false;
					for (DWORD j = 0; j < m_NewSockets.GetSize(); j++)
					{
						if (m_NewSockets[j] == pSock)
						{
							gotIt = true;
							break;
						}
					}

					if (!gotIt)
					{
						sockaddr_in name;
						int namelen = sizeof(name);

						if (getsockname(pSock, (sockaddr *)&name, &namelen) == 0)
						{
							// Check if there is port limitation
							WORD pPort = theGame.GetActiveGame()->ServerBindPort();
							if (pPort == 0)
							{
								if (theGame.GetActiveGame()->ServerBindLoPort() < ntohs(name.sin_port) &&
									theGame.GetActiveGame()->ServerBindHiPort() > ntohs(name.sin_port))
								{
									m_NewSockets.Add(pSock);
								}
							} else
							{
								if (name.sin_port == htons(pPort))
								{
									m_NewSockets.Add(pSock);
								}
							}
						} else
						{
							m_NewSockets.Add(pSock);
						}
					}
				}
			}

			tickRecheck = curTime;

			m_Mutex.Unlock();
		}

		// Check if we have to send any notifications to server
		if (!theGame.GetActiveGame()->ServerIsActivated() && 
			theGame.GetActiveGame()->BroadcastNotify() &&
			curTime - tickNotify > BROADCAST_NOTIFY)
		{
			sockaddr_in addr = {0};

			pLanTunnelPack_t	pack = {0};;
			pack.m_ID = PLAN_MAGIC;
			pack.m_PacketType = PLAN_PACK_NOTIFY;

			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("Transmitting NOTIFY packet.\n");

			Broadcast(m_hSocket, (const char *)&pack, sizeof(pack), 0, &addr, false);
            
			tickNotify = curTime;
		}

		// Check if we have to check emu sockets
		if (theGame.GetActiveGame()->AddressEmulationEnabled() &&
			curTime - m_LastAddressEmuRecheck)
		{
			pAddressFake::Update();

			m_LastAddressEmuRecheck = curTime;
		}

		Sleep(0);
	}

	m_Working = false;
}
//////////////////////////////////////////////////////////////////////////
bool	pSockServer::SendServerRequest(SOCKET tSock, sockaddr_in & raddr)
{
	int namelen = sizeof(raddr);

	if (getsockname(tSock, (sockaddr *)&raddr, &namelen) == 0)
	{
		if (raddr.sin_addr.S_un.S_addr == INADDR_ANY)
			raddr.sin_addr.S_un.S_addr = htonl(INADDR_LOOPBACK);

		hk::hkDataBuffer & tBuf = theGame.GetActiveGame()->ServerGetRequestPack();

		int tLen = pSocketHook::real_sendto(m_hSocket, (const char *)tBuf.GetBuffer(), tBuf.GetBufferLen(), 0, (sockaddr *)&raddr, sizeof(raddr));
		if (tLen == tBuf.GetBufferLen())
		{
			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Printf("[ServerDetect] Sent server request packet to %s:%d.\n", inet_ntoa(raddr.sin_addr), ntohs(raddr.sin_port));

			return true;
		} else
		{
			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("[ServerDetect] Failed to send identification packet.\n");
		}
	} else
	{
		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Write("[ServerDetect] Failed to get name for socket.\n");
	}

	return false;
}
//////////////////////////////////////////////////////////////////////////
bool	pSockServer::GetLocalAddresses()
{
	char	buf[HKMSL];

	if (gethostname(buf, HKMSL))
	{
		hk::GetLogManager().Write("Failed to detect local ip addresses.\n");
		return false;
	}

	hostent * hEnt = pSocketHook::real_gethostbyname(buf);
	if (WSAGetLastError() != 0)
	{
		hk::GetLogManager().Write("Failed to detect local ip addresses.\n");
		return false;
	}

	for (int i = 0; hEnt->h_addr_list[i] != NULL; i++)
	{
		in_addr addr = *((in_addr *)hEnt->h_addr_list[i]);

		hkAddr_t	hkAddr;
		hkAddr.m_addr = addr;

		m_LocalAddresses.Add(hkAddr);

		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Printf("Added local address %s\n", inet_ntoa(addr));
	}

	hkAddr_t	hkAddr;
	hkAddr.m_addr.S_un.S_addr = htonl(INADDR_LOOPBACK);
	m_LocalAddresses.Add(hkAddr);

	return false;
}

bool	pSockServer::IsLocalAddress(in_addr addr)
{
	for (DWORD i = 0; i < m_LocalAddresses.GetSize(); i++)
	{
		hkAddr_t & pAddr = m_LocalAddresses[i];

		if (pAddr.m_addr.S_un.S_addr == addr.S_un.S_addr)
		{
			return true;
		}
	}

	return false;
}
//////////////////////////////////////////////////////////////////////////
// Broadcast emulation
void	pSockServer::BroadcastNotifyIP(in_addr raddr, WORD rport)
{
	// Check if target in list already
	for (DWORD i = 0; i < m_BroadcastAddresses.GetSize(); i++)
	{
		ipInfo_t & ipInfo = m_BroadcastAddresses[i];

		if (ipInfo.m_addr.S_un.S_addr == raddr.S_un.S_addr)
		{
			ipInfo.m_port = rport;
			ipInfo.m_time = GetTickCount();
			return;
		}
	}

	// Check if it is non local target
	if (IsLocalAddress(raddr))
		return;

	// Add to broadcast list
	ipInfo_t info;
	info.m_addr = raddr;
	info.m_port = rport;
	info.m_time = GetTickCount();
	m_BroadcastAddresses.Add(info);

	if (theConfig.IsDebugLoggingEnabled())
		hk::GetLogManager().Printf("Added peer: %s:%d\n", inet_ntoa(raddr), ntohs(rport));
}

int		pSockServer::BroadcastEmuSend(SOCKET hSock, const char * szBuffer, int len, int flags, sockaddr_in * remoteaddr, bool connectionOriented)
{
	// Verify if it is connected socket
	DWORD now = GetTickCount();

	DWORD i = 0;
	while (i < m_BroadcastAddresses.GetSize())
	{
		ipInfo_t & ipInfo = m_BroadcastAddresses[i];

		if (now - ipInfo.m_time > BROADCAST_TIMEOUT)
		{
			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Printf("Peer timed out %s:%d\n", inet_ntoa(ipInfo.m_addr), ntohs(ipInfo.m_port));

			m_BroadcastAddresses.Remove(i);
		} else
		{
			sockaddr_in paddr = {0};
			paddr.sin_family = AF_INET;
			paddr.sin_addr   = ipInfo.m_addr;
			if (theGame.GetActiveGame()->BroadcastForcePort())
			{
				paddr.sin_port = remoteaddr->sin_port;
			} else
			{
				paddr.sin_port = ipInfo.m_port;
			}

			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Printf("Forwarding broadcast packet to %s:%d\n", inet_ntoa(paddr.sin_addr), ntohs(paddr.sin_port));

			int sent = 0;

			if (theGame.GetActiveGame()->BroadcastTunnel())
			{
				sent = pSocketHook::real_sendto(m_hSocket, szBuffer, len, flags, (const sockaddr *)&paddr, sizeof(paddr));
			} else
			{
				if (connectionOriented)
				{
					connect(hSock, (const sockaddr *)&paddr, sizeof(paddr));

					sent = pSocketHook::real_send(hSock, szBuffer, len, flags);
				} else
				{
					sent = pSocketHook::real_sendto(hSock, szBuffer, len, flags, (const sockaddr *)&paddr, sizeof(paddr));
				}

			}

			if (sent != len)
			{
				hk::GetLogManager().Printf("Failed to send broadcast packet to %s:%d\n", inet_ntoa(paddr.sin_addr), ntohs(paddr.sin_port));
			}

			i++;
		}
	}

	if (connectionOriented)
	{
		connect(hSock, (const sockaddr *)remoteaddr, sizeof(sockaddr));
	}

	return len;
}

int		pSockServer::SendTo(SOCKET hSock, const char * buf, int len, int flags, const sockaddr_in * remoteaddr)
{
//	hk::GetLogManager().Write("[SendItTo]\n");

	hk::hkDataBuffer	pbuf;
	if (theGame.GetActiveGame()->BroadcastTunnel() && remoteaddr->sin_port != 0)
	{
		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Write("Sending tunneled packet.\n");

		pbuf.Clear();

		pLanTunnelPack_t	pack;
		pack.m_ID = PLAN_MAGIC;
		pack.m_PacketType = PLAN_PACK_BROADCAST;
		pack.m_Port = remoteaddr->sin_port;

		sockaddr_in taddr;
		int taddrlen = sizeof(taddr);
		if (getsockname(hSock, (sockaddr *)&taddr, &taddrlen) == 0)
		{
			pack.m_RemotePort = taddr.sin_port;
		} else
		{
			pack.m_RemotePort = remoteaddr->sin_port;
		}

		pbuf.AddBuffer(&pack, sizeof(pack));
		pbuf.AddBuffer((const LPVOID)buf, len);

		// Swap pointers
		buf = (const char *)pbuf.GetBuffer();
		len = pbuf.GetBufferLen();
	}

	if (theGame.GetActiveGame()->BroadcastIsEmulated())
	{
		for (DWORD i = 0; i < m_BroadcastAddresses.GetSize(); i++)
		{
			ipInfo_t & ipInfo = m_BroadcastAddresses[i];

//			hk::GetLogManager().Printf("[SendTo] Checking '%s' with '%s'\n", inet_ntoa(remoteaddr->sin_addr), inet_ntoa(ipInfo.m_addr));

			if (ipInfo.m_addr.S_un.S_addr == remoteaddr->sin_addr.S_un.S_addr)
			{
				sockaddr_in paddr = {0};
				paddr.sin_family = AF_INET;
				paddr.sin_addr   = ipInfo.m_addr;
				if (theGame.GetActiveGame()->BroadcastForcePort())
				{
//					hk::GetLogManager().Write("[SendTo] Using forced port\n");
					paddr.sin_port = remoteaddr->sin_port;
				} else
				{
//					hk::GetLogManager().Write("[SendTo] Using tunneled\n");
					paddr.sin_port = ipInfo.m_port;
				}

				if (theConfig.IsDebugLoggingEnabled())
					hk::GetLogManager().Printf("[SendTo] Forwarding packet to %s:%d\n", inet_ntoa(paddr.sin_addr), ntohs(paddr.sin_port));

				int sent = 0;
				if (theGame.GetActiveGame()->BroadcastTunnel())
				{
					sent = pSocketHook::real_sendto(m_hSocket, buf, len, flags, (const sockaddr *)&paddr, sizeof(paddr));
				} else
				{
					sent = pSocketHook::real_sendto(hSock, buf, len, flags, (const sockaddr *)&paddr, sizeof(paddr));
				}

				if (sent != len)
				{
					hk::GetLogManager().Printf("Failed to send packet to %s:%d\n", inet_ntoa(paddr.sin_addr), ntohs(paddr.sin_port));
				}

				return sent;
			}
		}
	}

	if (theConfig.IsDebugLoggingEnabled())
		hk::GetLogManager().Printf("[SendTo] No neighbour found, forwarding packet directly to %s:%d\n", inet_ntoa(remoteaddr->sin_addr), ntohs(remoteaddr->sin_port));
	
	return pSocketHook::real_sendto(hSock, buf, len, flags, (const sockaddr *)remoteaddr, sizeof(sockaddr));
}

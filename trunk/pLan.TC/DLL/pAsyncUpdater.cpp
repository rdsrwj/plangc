#include	"stdafx.h"
#include	<WinInet.h>
#include	"pLocation.h"

#define	UPDATE_INTERVAL	/*30000*/20000

namespace	pAsyncUpdater
{
	//////////////////////////////////////////////////////////////////////////
	HANDLE	theHandle;
	DWORD	theThreadID;

	pMutex	theMutex;

	DWORD	theLastUpdate = 0;
	bool	theInUpdate = false;

	u_long	theSuitableIP = INADDR_ANY;
	int		theSuitableIPZone = -1;

	int		theLastCachedZone = PLAN_LOCATION_UAIX;
	DWORD	theLastZoneUpdate = 0;
	//////////////////////////////////////////////////////////////////////////
	hkAddrBuffer_t	theServerAddresses;
	//////////////////////////////////////////////////////////////////////////
	int		GetLocation()
	{
		if (GetTickCount() - theLastZoneUpdate > UPDATE_INTERVAL)
		{
			HKEY	hKey;
			if (RegCreateKey(HKEY_CURRENT_USER, PLANROOTKEY, &hKey) != ERROR_SUCCESS)
			{
				return false;
			}

			DWORD loc;
			DWORD pType;
			DWORD pLength = sizeof(loc);

			if (RegQueryValueEx(hKey, "Location", NULL, &pType, (LPBYTE)&loc, &pLength) == ERROR_SUCCESS)
			{
				RegCloseKey(hKey);
				theLastCachedZone = loc;
			} else
			{
				RegCloseKey(hKey);
				theLastCachedZone = PLAN_LOCATION_UAIX;
			}

			theLastZoneUpdate = GetTickCount();
		}

		return theLastCachedZone;
	}
	//////////////////////////////////////////////////////////////////////////
	void	DoRequest(HINTERNET Initialize, const char * buf)
	{
		HINTERNET hConnection, hFile;

		char	pbuf[HKMSL];
		sprintf(pbuf, "%s%s", theConfig.GetTrackerPath(), buf);

		hk::GetLogManager().Printf("Doing request '%s%s'\n", theConfig.GetTrackerHost(), pbuf);

		hConnection = InternetConnect(Initialize, 
			theConfig.GetTrackerHost(), 
			/*theConfig.GetTrackerPort()*/INTERNET_DEFAULT_HTTPS_PORT,
			NULL,
			NULL,
			INTERNET_SERVICE_HTTP,
			0,
			0);

		if (hConnection == NULL)
		{
			hk::GetLogManager().Write("Failed to create request\n");
		}

		// Open up an HTTP request
		hFile = HttpOpenRequest(hConnection,
			NULL,
			pbuf,
			NULL,
			NULL,
			NULL,
			INTERNET_FLAG_RELOAD | INTERNET_FLAG_SECURE | INTERNET_FLAG_IGNORE_CERT_CN_INVALID | INTERNET_FLAG_IGNORE_CERT_DATE_INVALID,
			0);

		if (hFile == NULL)
		{
			hk::GetLogManager().Write("Failed to create file\n");
		}

		DWORD dwFlags;
		DWORD dwBuffLen = sizeof(dwFlags);
		InternetQueryOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, (LPVOID)&dwFlags, &dwBuffLen);
		dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
		InternetSetOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, &dwFlags, sizeof(dwFlags));

		if (!HttpSendRequest(hFile, NULL, 0, NULL, 0))
		{
			hk::GetLogManager().Write("HTTP request failed\n");
		}

		InternetCloseHandle(hFile);
		InternetCloseHandle(hConnection);
	}
	//////////////////////////////////////////////////////////////////////////
	bool	IsLanAddress(in_addr addr)
	{
		char top = (char)(addr.S_un.S_addr & 0xFF);

		if (top == 10 || top == /*197*/192 || top == /*178*/172 || top == 127)
			return true;
		else
			return false;
	}
	//////////////////////////////////////////////////////////////////////////
	in_addr	FindSuitableIP()
	{
		int zone = GetLocation();

		if (theSuitableIPZone != zone)
		{
			char buf[HKMSL];
			gethostname(buf, HKMSL);

			struct hostent * hosts = pSocketHook::real_gethostbyname(buf);

			char * c;
			int i = 0;

			in_addr addr;
			addr.S_un.S_addr = INADDR_ANY;

			if (zone != LOCATION_LAN)
			{
				// Find first public IP
				while ((c = hosts->h_addr_list[i++]) != NULL)
				{
					in_addr taddr = *(in_addr *)c;
					if (!IsLanAddress(taddr))
					{
						addr = taddr;
						break;
					}
				}
			} else
			{
				// Find first local IP
				while ((c = hosts->h_addr_list[i++]) != NULL)
				{
					in_addr taddr = *(in_addr *)c;
					if (IsLanAddress(taddr))
					{
						addr = taddr;
						break;
					}
				}
			}

			// Use any address if no address found
			if (addr.S_un.S_addr == INADDR_ANY)
				addr = *(in_addr *)hosts->h_addr_list[0];

			theSuitableIP = addr.S_un.S_addr;
			theSuitableIPZone = zone;
		}

		in_addr result;
		result.S_un.S_addr = theSuitableIP;
		return result;
	}
	//////////////////////////////////////////////////////////////////////////
	void	VerifyIP(in_addr & addr, WORD & port)
	{
		if (addr.S_un.S_addr == INADDR_ANY ||
			(theGame.GetActiveGame()->AddFakeAddress() && addr.S_un.S_addr == pAddressFake::LocalAddress().S_un.S_addr))
		{
			addr = FindSuitableIP();
		}
	}
	//////////////////////////////////////////////////////////////////////////
	HINTERNET hInitialize;

	DWORD	WINAPI	threadProc(LPVOID lpParam)
	{
		// TODO: Fix possible deadlock
		while (true)
		{
			if (GetTickCount() > theLastUpdate)
			{
					theMutex.Lock();
					theInUpdate = true;
					theMutex.Unlock();

					// Update server (if any)
					if (theGame.GetActiveGame()->ServerIsActivated())
					{
						in_addr		svrAddr = theGame.GetActiveGame()->ServerGetAddress();
						WORD		svrPort = theGame.GetActiveGame()->ServerGetPort();
						const TiXmlString	& svrName = theGame.GetActiveGame()->GetServerModName();
						
						VerifyIP(svrAddr, svrPort);

						char	buf[HKMSL];
						sprintf(buf, "index.php?do=svr_add&game=%s&addr=%s&port=%d&location=%d&mod=%s", 
								theGame.GetActiveGame()->GetName(), 
								inet_ntoa(svrAddr),
								svrPort,
								GetLocation(),
								svrName.c_str()
								);

						DoRequest(hInitialize, buf);
					} else
					{
						theServerAddresses.Reset();

						// Download IP list
						HINTERNET hConnection, hFile;

						char	buf[HKMSL];
						sprintf(buf, "%sindex.php?do=svr_get&game=%s&location=%d", 
							theConfig.GetTrackerPath(),
							theGame.GetActiveGame()->GetName(),
							GetLocation()
							);

						hk::GetLogManager().Printf("Receiving list from '%s%s'\n", theConfig.GetTrackerHost(), buf);

						hConnection = InternetConnect(hInitialize, 
							theConfig.GetTrackerHost(), 
							/*theConfig.GetTrackerPort()*/INTERNET_DEFAULT_HTTPS_PORT,
							NULL,
							NULL,
							INTERNET_SERVICE_HTTP,
							0,
							0);

						if (hConnection == NULL)
						{
							hk::GetLogManager().Write("Failed to create request\n");
						} else
						{
							// Open up an HTTP request
							hFile = HttpOpenRequest(hConnection,
								NULL,
								buf,
								NULL,
								NULL,
								NULL,
								INTERNET_FLAG_RELOAD | INTERNET_FLAG_SECURE | INTERNET_FLAG_IGNORE_CERT_CN_INVALID | INTERNET_FLAG_IGNORE_CERT_DATE_INVALID,
								0);
							if (hFile == NULL)
							{
								hk::GetLogManager().Write("Failed to create file\n");
							} else
							{
								DWORD dwFlags;
								DWORD dwBuffLen = sizeof(dwFlags);
								InternetQueryOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, (LPVOID)&dwFlags, &dwBuffLen);
								dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
								InternetSetOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, &dwFlags, sizeof(dwFlags));

								if(!HttpSendRequest(hFile, NULL, 0, NULL, 0))
								{
									hk::GetLogManager().Write("HTTP request failed\n");
								} else
								{
									hk::hkDataBuffer	dataBuf;

									DWORD actuallyRead;
									while (true)
									{
										if (dataBuf.GetBufferLen() < HKMAX_BUFFER_LEN)
										{
											if (!InternetReadFile(hFile, 
												((BYTE *)dataBuf.GetBuffer()) + dataBuf.GetBufferLen(), 
												HKMAX_BUFFER_LEN - dataBuf.GetBufferLen(),
												&actuallyRead))
											{
												hk::GetLogManager().Write("Failed to receive file.\n");
												break;
											}

											if (actuallyRead == 0)
											{
												hk::GetLogManager().Write("IP update list received successfully.\n");
												break;
											} else
											{
												dataBuf.SetBufferLen(dataBuf.GetBufferLen() + actuallyRead);
											}
										}

										char * c = (char *)dataBuf.GetBuffer();
										char * limit = c + dataBuf.GetBufferLen();
										char * data = c;

										while (c < limit)
										{
											if (*c == '\n')
											{
												char * end = c;

												// Skip spaces
												while (c < limit && *c == '\n' || *c == '\r')
													c++;

												*end = '\0';

												char *d = data;
												while (*d != ':' && *d != '\0') d++;

												if (*d == ':')
												{
													*d = '\0';
													d++;

													in_addr addr;
													addr.S_un.S_addr = inet_addr(data);
													WORD port = atoi(d);

													if (addr.S_un.S_addr != 0)
													{
														theMutex.Lock();
														hkAddr_t taddr;
														taddr.m_addr = addr;
														taddr.m_port = htons(port);
														theServerAddresses.Add(taddr);
														theMutex.Unlock();

														if (theConfig.IsDebugLoggingEnabled())
															hk::GetLogManager().Printf("Added IP: %s:%d.\n", inet_ntoa(addr), port);
													}
												} else
												{
													hk::GetLogManager().Printf("Received invalid IP %s\n", data);
												}

												DWORD len = (DWORD)(c - data);
												dataBuf.Shift(len);
												c = data;
												limit = c + dataBuf.GetBufferLen();
											}
											c++;
										}
									}
								}

								InternetCloseHandle(hFile);
							}

							InternetCloseHandle(hConnection);
						}
					}

					theLastUpdate = GetTickCount() + UPDATE_INTERVAL;

					theMutex.Lock();
					theInUpdate = false;
					theMutex.Unlock();
			}

			Sleep(1000);
		}
	}
	//////////////////////////////////////////////////////////////////////////
	bool	Initialize()
	{
		// initialize the wininet library
		hInitialize = InternetOpen("PLAN",
			/*INTERNET_OPEN_TYPE_DIRECT*/INTERNET_OPEN_TYPE_PRECONFIG,
			NULL,
			NULL,
			0);

		if (hInitialize == NULL)
		{
			hk::GetLogManager().Printf("Failed to initialize wininet %x\n", GetLastError());
		}

		theHandle = CreateThread(NULL, 0x10000, &threadProc, NULL, 0, &theThreadID);

		return true;
	}

	bool	Deinitialize()
	{
		InternetCloseHandle(Initialize);

		TerminateThread(theHandle, 0);

		return true;
	}

	bool	GetAddresses(hkAddrBuffer_t & addrBuffer)
	{
		if (theInUpdate)
			return false;

		addrBuffer.Reset();

		theMutex.Lock();
		addrBuffer.FeedFrom(theServerAddresses);
		theMutex.Unlock();

		return true;
	}
}

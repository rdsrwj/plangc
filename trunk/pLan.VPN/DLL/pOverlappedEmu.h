//////////////////////////////////////////////////////////////////////////

typedef	struct 
{
	SOCKET			hSock;
	char *			lpBuf;
	DWORD			dwBuf;
	LPWSAOVERLAPPED lpOverlapped;
	struct sockaddr* lpFrom;
	LPINT			lpFromlen;
} pOverlappedEmu_t;
typedef	hk::hkDynBuffer<pOverlappedEmu_t>	pOverlappedInfo_t;
pOverlappedInfo_t	theOverlappedSockets;


void	SetOverlappedSocket(SOCKET hSock, char * pBuf, DWORD dwBuf, LPWSAOVERLAPPED lpOverlapped, struct sockaddr* lpFrom, LPINT lpFromlen)
{
	for (DWORD i = 0; i < theOverlappedSockets.GetSize(); i++)
	{
		if (theOverlappedSockets[i].hSock == hSock &&
			theOverlappedSockets[i].lpOverlapped == lpOverlapped)
		{
			theOverlappedSockets[i].lpBuf = pBuf;
			theOverlappedSockets[i].dwBuf = dwBuf;
			theOverlappedSockets[i].lpOverlapped = lpOverlapped;
			theOverlappedSockets[i].lpFrom = lpFrom;
			theOverlappedSockets[i].lpFromlen = lpFromlen;

			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Printf("Updated socket %x\n", hSock);

			return;
		}
	}

	pOverlappedEmu_t	emu;
	emu.hSock = hSock;
	emu.lpBuf = pBuf;
	emu.dwBuf = dwBuf;
	emu.lpOverlapped = lpOverlapped;
	emu.lpFrom = lpFrom;
	emu.lpFromlen = lpFromlen;
	theOverlappedSockets.Add(emu);

	if (theConfig.IsDebugLoggingEnabled())
		hk::GetLogManager().Printf("Added socket %x\n", hSock);
}

pOverlappedEmu_t	*	FindOverlappedSocket(SOCKET hSock, LPWSAOVERLAPPED lpOverlapped)
{
	for (DWORD i = 0; i < theOverlappedSockets.GetSize(); i++)
	{
		if (theOverlappedSockets[i].hSock == hSock &&
			theOverlappedSockets[i].lpOverlapped == lpOverlapped)
		{
			return &theOverlappedSockets[i];
		}
	}

	return NULL;
}

void	CloseOverlappedSocket(SOCKET hSock)
{
	DWORD i = 0;
	while (i < theOverlappedSockets.GetSize())
	{
		if (theOverlappedSockets[i].hSock == hSock)
		{
			theOverlappedSockets.Remove(i);
		} else
		{
			i++;
		}
	}
}
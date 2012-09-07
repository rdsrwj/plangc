#include "stdafx.h"

#define	TIMEOUT		60000

namespace	pAddressFake
{
	typedef	hk::hkDynBuffer<pAddrFake_t>	pFakeBuffers_t;
	typedef hk::hkDynBuffer<WORD>			pFreeFakeBuffers_t;

	typedef	struct
	{
		bool	m_Active;
		in_addr	m_Address;
		DWORD	m_LastUpdate;
	} pFakeIp_t;

	// Faked hostent
	struct my_hostent : public hostent
	{
		my_hostent(const hostent * hent)
		{
			h_addrtype = hent->h_addrtype;
			h_length   = hent->h_length;

			// Hostname
			h_name = strcopy(hent->h_name);

			// Host aliases
			h_aliases = NULL;
			if (hent->h_aliases != NULL)
			{
				int	aliasCount = 0;
				for (char ** c = hent->h_aliases; *c != NULL; c++)
					aliasCount++;
				aliasCount++;

				h_aliases = new char*[aliasCount];
				memset(h_aliases, 0, sizeof(char *) * aliasCount);
				
				int i = 0;
				for (char ** c = hent->h_aliases; *c != NULL; i++, c++)
				{
					h_aliases[i] = strcopy(*c);
				}
			}

			// Address list
			h_addr_list = NULL;
			if (hent->h_addr_list != NULL)
			{
				int	addrCount = 0;
				for (char ** c = hent->h_addr_list; *c != NULL; c++)
					addrCount++;

				addrCount += 2;

				h_addr_list = new char*[addrCount];
				memset(h_addr_list, 0, sizeof(char *) * addrCount);

				// Insert our fake address
				h_addr_list[addrCount-2] = new char[h_length];
				u_long * pAddr = (u_long *)h_addr_list[addrCount-2];
				*pAddr = LocalAddress().S_un.S_addr;

				int i = 0;
				for (char ** c = hent->h_addr_list; *c != NULL; i++,c++)
				{
					h_addr_list[i] = new char[h_length];
					memcpy(h_addr_list[i], *c, h_length);
				}
			}
		}

		~my_hostent()
		{
			strfree(h_name);

			if (h_aliases != NULL)
			{
				for (char ** c = h_aliases; *c != NULL; c++)
					strfree(*c);

				delete [] h_aliases;
			}

			if (h_addr_list != NULL)
			{
				for (char ** c = h_addr_list; *c != NULL; c++)
					delete [] *c;

				delete [] h_addr_list;
			}
		}
	private:
		inline	char *	strcopy(const char * source)
		{
			if (source == NULL)
				return NULL;

			char * result = new char[strlen(source) + 1];
			strcpy(result, source);

			return result;
		}

		inline	void	strfree(char * source)
		{
			if (source != NULL)
				delete source;
		}
	};

	//////////////////////////////////////////////////////////////////////////
	pFakeBuffers_t		theFakeBuffers;
	pFreeFakeBuffers_t	theFreeFakeBuffers;

	pFakeIp_t			theFakeAddresses[FAKEIPCOUNT];

	pMutex				theMutex;

	my_hostent	*		theFakedHostent = NULL;
	char				theMyHostname[HKMSL] = {0};

	byte				theLocalAddrByte = FAKEIPNUM;
	//////////////////////////////////////////////////////////////////////////
	void	Initialize()
	{
		// Clean fake address buffer
		for (DWORD i = 0; i < FAKEIPCOUNT; i++)
			theFakeAddresses[i].m_Active = false;

		if (theGame.GetActiveGame()->AddFakeAddress())
		{
			theLocalAddrByte = theConfig.GetLocalAddressByte();

			hk::GetLogManager().Printf("[FakeAddr] Using local address '%s'\n", inet_ntoa(LocalAddress()));

			theFakeAddresses[theLocalAddrByte].m_Active = TRUE;
			theFakeAddresses[theLocalAddrByte].m_Address.S_un.S_addr = INADDR_ANY;
			theFakeAddresses[theLocalAddrByte].m_LastUpdate = GetTickCount();
		}
	}

	in_addr			LocalAddress()
	{
		in_addr addr;
		addr.S_un.S_addr = htonl(FAKEIP | theLocalAddrByte);
		return addr;
	}

	void	Update()
	{
		pAutoMutex	mutex(theMutex);

		DWORD	curTick = GetTickCount();

		if (theGame.GetActiveGame()->AddFakeAddress())
		{
			theFakeAddresses[theLocalAddrByte].m_LastUpdate = curTick;

			if (theFakeAddresses[theLocalAddrByte].m_Address.S_un.S_addr == INADDR_ANY)
				theFakeAddresses[theLocalAddrByte].m_Address = pAsyncUpdater::FindSuitableIP();
		}

		for (DWORD i = 1; i < FAKEIPCOUNT; i++)
		{
			if (theFakeAddresses[i].m_Active && curTick - theFakeAddresses[i].m_LastUpdate > TIMEOUT)
			{
				hk::GetLogManager().Printf("[AddEmu] Peer timed out %s\n", inet_ntoa(theFakeAddresses[i].m_Address));

				theFakeAddresses[i].m_Active = false;
			}
		}
	}
	//////////////////////////////////////////////////////////////////////////
	WORD	AddFakeBuffer(const char * pBuf, int len, in_addr addr, WORD port)
	{
		pAutoMutex	mutex(theMutex);

		int outLen = len < sizeof(pLanFakePack_t) ? len : sizeof(pLanFakePack_t);

		WORD id;
		if (theFreeFakeBuffers.Pop(id))
		{
			memcpy(theFakeBuffers[id].m_Buf, pBuf, outLen);

			theFakeBuffers[id].m_Len = len;
			theFakeBuffers[id].m_Addr = addr;
			theFakeBuffers[id].m_Port = port;
			return id;
		} else
		{
			pAddrFake_t fake;
			memcpy(fake.m_Buf, pBuf, outLen);
			fake.m_Len = len;
			fake.m_Addr = addr;
			fake.m_Port = port;
			theFakeBuffers.Add(fake);

			return (WORD)(theFakeBuffers.GetSize() - 1);
		}
	}

	pAddrFake_t *	GetFakeBuffer(WORD bufID)
	{
		pAutoMutex	mutex(theMutex);

		if (bufID >= theFakeBuffers.GetSize())
			return NULL;

		return &theFakeBuffers[bufID];
	}

	bool	DelFakeBuffer(WORD bufID)
	{
		pAutoMutex	mutex(theMutex);

		if (bufID >= theFakeBuffers.GetSize())
			return false;

		theFreeFakeBuffers.Add(bufID);

		return true;
	}

	// Address emulation
	in_addr			AddAddress(in_addr original)
	{
		hk::GetLogManager().Printf("[AddrEmu] Checking address %s\n", inet_ntoa(original));

		if (pAsyncUpdater::IsLanAddress(original))
			return original;

		pAutoMutex	mutex(theMutex);

		if (theGame.GetActiveGame()->AddFakeAddress())
		{
			if (theFakeAddresses[theLocalAddrByte].m_Address.S_un.S_addr == INADDR_ANY)
			{
				theFakeAddresses[theLocalAddrByte].m_Address = pAsyncUpdater::FindSuitableIP();
			}
		}

		// Find it
		for (DWORD i = 1; i < FAKEIPCOUNT; i++)
			if (theFakeAddresses[i].m_Active &&
				theFakeAddresses[i].m_Address.S_un.S_addr == original.S_un.S_addr)
			{
				theFakeAddresses[i].m_LastUpdate = GetTickCount();

				in_addr result;
				result.S_un.S_addr = htonl(FAKEIP | i);

				hk::GetLogManager().Printf("[AddrEmu] In list, returning as %s\n", inet_ntoa(result));

				return result;
			}

		for (DWORD i = 1; i < FAKEIPCOUNT; i++)
			if (!theFakeAddresses[i].m_Active)
			{
				theFakeAddresses[i].m_Active = true;
				theFakeAddresses[i].m_Address= original;
				theFakeAddresses[i].m_LastUpdate = GetTickCount();

				in_addr result;
				result.S_un.S_addr = htonl(FAKEIP | i);

				hk::GetLogManager().Printf("[AddrEmu] Not in list, added as %s\n", inet_ntoa(result));

				return result;
			}

		hk::GetLogManager().Write("Failed to find free slot for IP!\n");

		return original;
	}

	in_addr			GetRealAddress(in_addr addr)
	{
		pAutoMutex	mutex(theMutex);

		u_long haddr = ntohl(addr.S_un.S_addr);

		if ((haddr & FAKEIPMASK) == FAKEIP)
		{
			u_long j = haddr & ~FAKEIPMASK;
			if (theFakeAddresses[j].m_Active)
			{
				theFakeAddresses[j].m_LastUpdate = GetTickCount();
				return theFakeAddresses[j].m_Address;
			} else
			{
				return addr;
			}
		} else
		{
			return addr;
		}
	}

	hostent *	GetFakedHostent(const char * hostname)
	{
		if (theFakedHostent == NULL)
		{
			if (gethostname(theMyHostname, HKMSL) == 0)
			{
				const hostent * hent = pSocketHook::real_gethostbyname(theMyHostname);

				if (hent != NULL)
				{
					theFakedHostent = new my_hostent(hent);
				}
			}
		}

		if (theFakedHostent != NULL)
		{
			if (!_strcmpi(hostname, theMyHostname))
			{
				return theFakedHostent; 
			}
		}
		
		return pSocketHook::real_gethostbyname(hostname);
	}
}
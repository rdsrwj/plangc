#pragma once

#define	FAKEIP		0x0AFFFF00
#define	FAKEIPMASK	0xFFFFFF80
#define	FAKEIPCOUNT	(0x7F - 1)
#define FAKEIPNUM	1

typedef	struct 
{
	char *	m_Buf[sizeof(pLanFakePack_t)];
	int		m_Len;
	in_addr	m_Addr;
	WORD	m_Port;
} pAddrFake_t;

namespace	pAddressFake
{
	void			Initialize();
	void			Update();

	// Local address
	in_addr			LocalAddress();

	// Address faking
	WORD			AddFakeBuffer(const char * pBuf, int len, in_addr addr, WORD port);
	pAddrFake_t *	GetFakeBuffer(WORD bufID);
	bool			DelFakeBuffer(WORD bufID);

	// Address emulation
	in_addr			AddAddress(in_addr original);
	void			NotifyAddress(in_addr addr);
	in_addr			GetRealAddress(in_addr addr);

	hostent *	GetFakedHostent(const char * hostname);
};

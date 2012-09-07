#pragma	once

#define	LOCATION_INTERNET	0
#define	LOCATION_UAIX		1
#define	LOCATION_VOLIAIX	2
#define	LOCATION_LAN		3

typedef	struct 
{
	in_addr	m_addr;
	WORD	m_port;
} hkAddr_t;
typedef	hk::hkDynBuffer<hkAddr_t>		hkAddrBuffer_t;

namespace	pAsyncUpdater
{
	bool	Initialize();
	bool	Deinitialize();

	bool	IsLanAddress(in_addr addr);
	
	bool	GetAddresses(hkAddrBuffer_t & addrBuffer);

	in_addr	FindSuitableIP();
}


#pragma once

#include	"pHookDefs.h"

class pSockServer;

namespace	pSocketHook
{
	bool	Initialize();
	void	Deinitialize();

	//////////////////////////////////////////////////////////////////////////
	extern	pSockServer		theSockServer;	

	//////////////////////////////////////////////////////////////////////////
	extern	sendto_t		real_sendto;
	extern	recvfrom_t		real_recvfrom;
	extern	bind_t			real_bind;
	extern	closesocket_t	real_closesocket;
	extern	select_t		real_select;
	extern	send_t			real_send;
	extern	gethostbyname_t	real_gethostbyname;
	extern GetAdaptersAddresses_t real_GetAdaptersAddresses;
}

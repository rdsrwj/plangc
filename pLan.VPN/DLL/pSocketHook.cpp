#include	"stdafx.h"

#pragma		message("TODO: Fix possible deadlock on thread termination")

namespace	pSocketHook
{
	//////////////////////////////////////////////////////////////////////////
	// Variables
	pSockServer		theSockServer;

	//////////////////////////////////////////////////////////////////////////
	// Overlapped emu
#include "pOverlappedEmu.h"
//#include	"pHookDefs.h"
	//////////////////////////////////////////////////////////////////////////
	// Original functions

	GetAdaptersAddresses_t real_GetAdaptersAddresses = NULL;
	sendto_t		real_sendto = NULL;
	recvfrom_t		real_recvfrom = NULL;
	bind_t			real_bind = NULL;
	closesocket_t	real_closesocket = NULL;
	select_t		real_select = NULL;
	send_t			real_send = NULL;
	recv_t			real_recv = NULL;
	WSARecvFrom_t   real_WSARecvFrom = NULL;
	WSARecv_t		real_WSARecv = NULL;
	WSAGetOverlappedResult_t	real_WSAGetOverlappedResult = NULL;
	gethostbyname_t	real_gethostbyname = NULL;
	connect_t		real_connect = NULL;
	getpeername_t	real_getpeername = NULL;
	accept_t		real_accept = NULL;
	GetAdaptersInfo_t real_GetAdaptersInfo;


long swapbytes(const long source)
{
  byte *b;
  b = (byte *) &source;
  return ((((b[0]*256)+b[1])*256+b[2])*256)+b[3];
};


char * DoFIFA11(char * buf, int len, long lip)
{
   char name[15];
   char ip[8];
   char port[15];
   char *mybyte;	
//   char *data;
   mybyte = (char *)&buf[0];
   char pattern [7];
   pattern[0] = char(0x0);
   pattern[1] = char(0x0);
   pattern[2] = char(0x1);
   pattern[3] = char(0x0);
   pattern[4] = char(0x0);
   pattern[5] = char(0xff);
   pattern[6] = char(0xff);




   bool PatternFound = true;

   hk::GetLogManager().Printf("checking pattern\n");

   for (int j=0;j<=6; j++)
   {
     if (buf[j] != pattern[j]) 
	 {
		 PatternFound = false;
		 break;
	 };
   };
	   
   if (!PatternFound)
   {
     PatternFound = true;
	 

     pattern[0] = char(0x10);
     pattern[1] = char(0x0);
     pattern[2] = char(0x1);
     pattern[3] = char(0x1);
     pattern[4] = char(0x0);
     pattern[5] = char(0xff);
     pattern[6] = char(0xff);
	 for (int j=0;j<=6; j++)
    {
      if (buf[j] != pattern[j]) 
	  {
		  PatternFound = false;
		  break;
	  };
    };
   }

   ///20   0   1   2   0   0   1

   if (!PatternFound)
   {
     PatternFound = true;
	 

     pattern[0] = char(0x20);
     pattern[1] = char(0x0);
     pattern[2] = char(0x1);
     pattern[3] = char(0x2);
     pattern[4] = char(0x0);
     pattern[5] = char(0x0);
     pattern[6] = char(0x1);
	 for (int j=0;j<=6; j++)
    {
      if (buf[j] != pattern[j]) 
	  {
		  PatternFound = false;
		  break;
	  };
    };
   }
      

   if (!PatternFound)
   {
     PatternFound = true;
	 
     pattern[0] = char(0x20);
     pattern[1] = char(0x0);
     pattern[2] = char(0x1);
     pattern[3] = char(0x2);
     pattern[4] = char(0x0);
     pattern[5] = char(0x0);
     pattern[6] = char(0x1);
	 for (int j=0;j<=6; j++)
    {
      if (buf[j] != pattern[j]) 
	  {
		  PatternFound = false;
		  break;
	  };
    };
   }


   if (PatternFound)
		{
			hk::GetLogManager().Printf("Pattern passsed\n");
			if (theConfig.IsTrafficDumpEnabled())
			{
						hk::GetLogManager().Printf("Original packet\n");
						hk::GetLogManager().Dump((const LPVOID)buf, len);
			}
					memset(name,'\0',sizeof(name));
					memset(ip,'\0',sizeof(ip));
					memset(port,'\0',sizeof(port));						
					char *sendbuf = (char *) malloc (len);
					memcpy(sendbuf, buf, len);
					for(int i=0; i<len; i++)
					{
						if (buf[i]!='$') 
						{
						  sendbuf[i] = buf[i];	
						}
						else
						{
						  sendbuf[i] = buf[i];	
						  if (lip  < 0x10000000)
						  {
							sendbuf[i+1] = '0';
						    _ltoa(lip,(char *) &sendbuf[i+2],16);
						  } 
						  else 
						    _ltoa(lip,(char *) &sendbuf[i+1],16);


						  i=i+8;	
						}


					}
//					memcpy(buf, sendbuf, len);
					if (theConfig.IsTrafficDumpEnabled())
						hk::GetLogManager().Dump((const LPVOID)sendbuf, len);

					return sendbuf;
   };
   return (char *) buf;
};

DWORD _stdcall my_GetAdaptersInfo(
  __out    PIP_ADAPTER_INFO pAdapterInfo,
  __inout  PULONG pOutBufLen
)

{
	DWORD Result = real_GetAdaptersInfo(pAdapterInfo,pOutBufLen);
	hk::GetLogManager().Write("In GetAdaptersInfo.\n");
	if(*pOutBufLen==0)  
	  return Result;
	else
		if (Result == NO_ERROR)
	{  
      
	  PIP_ADAPTER_INFO temp;
	  temp = pAdapterInfo;
	  hk::GetLogManager().Write("Fixing adapters info.\n");
	  while (temp != NULL)
	  {
		  char *adapterip =  temp->IpAddressList.IpAddress.String;
		  if (strstr(adapterip,(char *)theConfig.GetOpenVPNIP()) != NULL)
		  {
			memcpy(pAdapterInfo, temp, sizeof(*pAdapterInfo));			
			pAdapterInfo->Next = NULL;
			hk::GetLogManager().Write("Fixed adapters info.\n");
			temp->Next = NULL;
			break;
		  }
		  else 
			  temp = temp->Next;
	  };	  
	}
  return Result;
}




	//////////////////////////////////////////////////////////////////////////
	// sendto
	int __stdcall my_sendto(SOCKET sock, char *buf, int len, int flags, const struct sockaddr *to, int tolen)
	{
		theSockServer.VerifySocket(sock);
		if (strstr(theGame.GetActiveGame()->GetName(),"FIFA11") != NULL)
		{
	      // Parsing send_to_fifa11			
			if((theConfig.m_OpenVPNIP.length()!=0) && (strstr(theConfig.m_OpenVPNIP.c_str(),"0.0.0.0")==NULL))
			{			    
				long Adress = inet_addr(theConfig.m_OpenVPNIP.c_str());			
				hk::GetLogManager().Printf("Fixing FIFA_sendto for inet_ntoa Adress");
				char *fifabuf = DoFIFA11(buf,len, Adress);
				if (fifabuf != buf)
				{
				  if (buf != fifabuf) 
				  {
					  for (int j=0; j<len; j++)
					  {   
						  buf[j] = fifabuf[j];
					  };

					  free(fifabuf);

				  }				  

				};				

			};
		}

		if (to != NULL)
		{
			sockaddr_in * saddr = (sockaddr_in *)to;
			if (((saddr->sin_addr.S_un.S_addr & 0xFF000000) == 0xFF000000) ||
				((saddr->sin_addr.S_un.S_addr & 0x000000FF) == 0x000000EA))
			{
				theSockServer.Broadcast(sock, buf, len, flags, saddr, false);

				// Check if we have to skip broadcast packets
				/*if (theGame.GetActiveGame()->BroadcastDisableInEmulation())
				{
					return len;
				}*/
			}
		}

		if (theConfig.IsDebugLoggingEnabled())
		{
			if (to != NULL)
			{
				sockaddr_in * taddr = (sockaddr_in *)to;

				hk::GetLogManager().Printf("Got sendto %s:%d\n", inet_ntoa(taddr->sin_addr), ntohs(taddr->sin_port));
			} else
			{
				hk::GetLogManager().Printf("Got sendto without address\n");
			}

			if (theConfig.IsTrafficDumpEnabled())
				hk::GetLogManager().Dump((const LPVOID)buf, len);
		}

		// Game hook
		pGameHookBase * pHook = theGame.GetActiveGame()->GetHook();
		if (pHook != NULL)
		{
			hkCallbackResult result = pHook->do_sendto(sock, buf, len, flags, to, tolen);
			switch (result)
			{
			case hkCallback_Accept:
				return len;
			case hkCallback_Fail:
				return -1;
			}
		}
// SendTo Fix
		{
			sockaddr_in * saddr = (sockaddr_in *)to;
			if (! (((saddr->sin_addr.S_un.S_addr & 0xFF000000) == 0xFF000000) ||
				((saddr->sin_addr.S_un.S_addr & 0x000000FF) == 0x000000EA)))
			{
				return real_sendto(sock, buf, len, flags, to, tolen);			
			}
			else
				return len;	 
		}		
	}

	//////////////////////////////////////////////////////////////////////////
	// send
	int __stdcall	my_send(SOCKET s, const char* buf, int len, int flags)
	{
		theSockServer.VerifySocket(s);

		if (theGame.GetActiveGame()->BroadcastNeedSendCheck())
		{
			sockaddr_in inaddr = {0};
			int inaddrlen = sizeof(inaddr);
			if (real_getpeername(s, (sockaddr *)&inaddr, &inaddrlen) == 0)
			{
				if (((inaddr.sin_addr.S_un.S_addr & 0xFF000000) == 0xFF000000) ||
				    ((inaddr.sin_addr.S_un.S_addr & 0x000000FF) == 0x000000EA))
				{
					//theSockServer.Broadcast(s, buf, len, flags, &inaddr, true);
				}

				// Check if we have to skip broadcast packets
				if (theGame.GetActiveGame()->BroadcastDisableInEmulation())
				{
					return len;
				}
			} else
			{
				hk::GetLogManager().Printf("Failed to get send(%x) address. (%x)\n", s, WSAGetLastError());
			}
		}

		if (theConfig.IsDebugLoggingEnabled())
		{
			sockaddr_in inaddr = {0};
			int inaddrlen = sizeof(inaddr);
			if (real_getpeername(s, (sockaddr *)&inaddr, &inaddrlen) == 0)
			{
				hk::GetLogManager().Printf("send (%x) %s:%d\n", s, inet_ntoa(inaddr.sin_addr), ntohs(inaddr.sin_port));
			} else
			{
				hk::GetLogManager().Printf("send (%x) [unconnected] (%x)\n", s, WSAGetLastError());
			}

			if (theConfig.IsTrafficDumpEnabled())
				hk::GetLogManager().Dump((const LPVOID)buf, len);
		}

		// Game hook
		pGameHookBase * pHook = theGame.GetActiveGame()->GetHook();
		if (pHook != NULL)
		{
			hkCallbackResult result = pHook->do_send(s, buf, len, flags);
			switch (result)
			{
			case hkCallback_Accept:
				return len;
			case hkCallback_Fail:
				return -1;
			}
		}

		return real_send(s, buf, len, flags);
	}


  ULONG __stdcall	my_GetAdaptersAddresses ( __in     ULONG Family,
	__in     ULONG Flags,
    __in     PVOID Reserved,
    __inout  PIP_ADAPTER_ADDRESSES AdapterAddresses,
    __inout  PULONG SizePointer
   )

	{ 
		DWORD Result = real_GetAdaptersAddresses(Family, Flags, Reserved, AdapterAddresses, SizePointer);
		return Result;
		hk::GetLogManager().Printf("Going into GetAdaptersAddresses\n");
		if (Result != NO_ERROR) 
		{
			hk::GetLogManager().Printf("Error in real_GetAdaptersAddresses\n");
			return Result;
		}
		if (*SizePointer == 0) 
			return Result;

		hk::GetLogManager().Printf("Ran real getadaptersaddresses\nl");				

		PIP_ADAPTER_ADDRESSES MyAddresses;
		MyAddresses = AdapterAddresses;
		PIP_ADAPTER_ADDRESSES temp;



		temp = MyAddresses;
		hk::GetLogManager().Printf("Before adapterscheck");				
		while (temp != NULL)
		{ 

			hk::GetLogManager().Printf("Checking adapter %s", temp->AdapterName);				
			if (strstr((char *)temp->Description,"pLan")!=NULL)
			{
				hk::GetLogManager().Printf("GetAdaptersAddresses: found interface. Clearing");				
				temp->Next = NULL;
				hk::GetLogManager().Printf("Before memcpy");
				memcpy(AdapterAddresses,temp,sizeof(*temp));
				hk::GetLogManager().Printf("After memcpy");
			}
		}
		return Result;
	}

	//////////////////////////////////////////////////////////////////////////
	// Generic recvfrom handler
	void	int_recvfrom(SOCKET sock, char * buf, int len, int flags, struct sockaddr *to, int *tolen, int & result)
	{
		// If game needs to have emulated broadcast
		/*if (result > 0 && 
			to != NULL && 
			theGame.GetActiveGame()->BroadcastIsEmulated() && 
			!theGame.GetActiveGame()->BroadcastTunnel())
		{
			sockaddr_in taddr;
			int taddrsize = sizeof(taddr);
			if (getsockname(sock, (sockaddr *)&taddr, &taddrsize) == 0)
			{
				if (theGame.GetActiveGame()->BroadcastIsPeerPort(ntohs(taddr.sin_port)))
				{
					sockaddr_in * paddr = (sockaddr_in *)to;

					theSockServer.BroadcastNotifyIP(paddr->sin_addr, paddr->sin_port);
				}
			}
		}*/

	}

	//////////////////////////////////////////////////////////////////////////
	// recvfrom
	int	__stdcall my_recvfrom(SOCKET sock, char * buf, int len, int flags, struct sockaddr *to, int *tolen)
	{
		theSockServer.VerifySocket(sock);

		int result = real_recvfrom(sock, buf, len, flags, to, tolen);

		int_recvfrom(sock, buf, len, flags, to, tolen, result);

		if (theConfig.IsDebugLoggingEnabled() && result > 0)
		{
			sockaddr_in * taddr = (sockaddr_in *)to;

			if (taddr != NULL)
			{
				hk::GetLogManager().Printf("Got recvfrom (%x) %s:%d\n", sock, inet_ntoa(taddr->sin_addr), ntohs(taddr->sin_port));
			} else
			{
				hk::GetLogManager().Printf("Got recvfrom (%x)\n", sock);
			}

			if (theConfig.IsTrafficDumpEnabled())
				hk::GetLogManager().Dump(buf, result);
		} 

		// Game hook
		pGameHookBase * pHook = theGame.GetActiveGame()->GetHook();
		if (pHook != NULL)
		{
			hkCallbackResult result = pHook->do_recvfrom(sock, buf, len, flags, to, tolen);
			switch (result)
			{
			case hkCallback_Accept:
				return result;
			case hkCallback_Fail:
				return -1;
			}
		}

		return result;
	}
	//////////////////////////////////////////////////////////////////////////
	// WSARecvFrom
	int __stdcall	my_WSARecvFrom(SOCKET s,
						LPWSABUF lpBuffers,
						DWORD dwBufferCount,
						LPDWORD lpNumberOfBytesRecvd,
						LPDWORD lpFlags,
						struct sockaddr* lpFrom,
						LPINT lpFromlen,
						LPWSAOVERLAPPED lpOverlapped,
						LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine)
	{
		theSockServer.VerifySocket(s);


		if (dwBufferCount == 1)
		{
			sockaddr_in * maddr = (sockaddr_in *)lpFrom;
			char * fifabuf = DoFIFA11(lpBuffers[0].buf, lpBuffers[0].len, maddr->sin_addr.S_un.S_addr);
			if (fifabuf != NULL)
			{
			  if (lpBuffers[0].buf != fifabuf) 
			  {
				  for (int j=0; j<lpBuffers[0].len; j++)
				  {   
					  lpBuffers[0].buf[j] = fifabuf[j];
				  };
				  free(fifabuf);
				  
			   };				
			}

			int out;

			if (lpOverlapped != NULL)
			{
				out = real_WSARecvFrom(s, lpBuffers, dwBufferCount, lpNumberOfBytesRecvd, lpFlags, lpFrom, lpFromlen, lpOverlapped, lpCompletionRoutine);
				
				hk::GetLogManager().Printf("WSARecvFrom with overlapped operation (%x)(lpBuf = %x)(lpOverlapped = %x)(lpFrom = %x).\n", s, lpBuffers[0].buf, lpOverlapped, lpFrom);

				if (out == 0)
				{
					if ((*lpFlags & WSASYS_STATUS_LEN) == 0)
					{
						hk::GetLogManager().Write("Have data, despite of overlapped flag.\n");
					} else
					{
						hk::GetLogManager().Write("Adding socket [1]\n");
						SetOverlappedSocket(s, lpBuffers[0].buf, lpBuffers[0].len, lpOverlapped, lpFrom, lpFromlen);
					}
				} else
				{
					HRESULT hr = WSAGetLastError();

					if (hr == WSA_IO_PENDING)
					{
						hk::GetLogManager().Write("Adding socket [2]\n");
						SetOverlappedSocket(s, lpBuffers[0].buf, lpBuffers[0].len, lpOverlapped, lpFrom, lpFromlen);
					} else
					if (hr == WSAEINPROGRESS)
					{
						hk::GetLogManager().Write("WSAINPROGRESS\n");
					} else
					{
						//hk::GetLogManager().Printf("WSARecvFrom error %x\n", hr);
					}

					WSASetLastError(hr);
				}
			} else
			{
				out = real_WSARecvFrom(s, lpBuffers, dwBufferCount, lpNumberOfBytesRecvd, lpFlags, lpFrom, lpFromlen, lpOverlapped, lpCompletionRoutine);
			}

			if (out == 0)
			{
				int result = *lpNumberOfBytesRecvd;

				if ((*lpFlags & WSASYS_STATUS_LEN) == 0)
				{
					int_recvfrom(s, lpBuffers[0].buf, lpBuffers[0].len, *lpFlags, lpFrom, lpFromlen, result);
					*lpNumberOfBytesRecvd = result;

					if (theConfig.IsDebugLoggingEnabled() && result > 0)
					{
						sockaddr_in * taddr = (sockaddr_in *)lpFrom;

						if (taddr != NULL)
						{
							hk::GetLogManager().Printf("Got WSARecvFrom (%x) %s:%d\n", s, inet_ntoa(taddr->sin_addr), ntohs(taddr->sin_port));
						} else
						{
							hk::GetLogManager().Printf("Got WSARecvFrom (%x)\n", s);
						}

						if (theConfig.IsTrafficDumpEnabled())
							hk::GetLogManager().Dump(lpBuffers[0].buf, result);
					} 
				}
			} else
			{
//				hk::GetLogManager().Printf("WSARecvFrom error %x\n", WSAGetLastError());
			}

			return out;
		} else
		{
			hk::GetLogManager().Write("WSARecvFrom with dwBufferCount > 1\n");
			return real_WSARecvFrom(s, lpBuffers, dwBufferCount, lpNumberOfBytesRecvd, lpFlags, lpFrom, lpFromlen, lpOverlapped, lpCompletionRoutine);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////
	// WSARecv
	int __stdcall	my_WSARecv(
						SOCKET s,
						LPWSABUF lpBuffers,
						DWORD dwBufferCount,
						LPDWORD lpNumberOfBytesRecvd,
						LPDWORD lpFlags,
						LPWSAOVERLAPPED lpOverlapped,
						LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
					)
	{
		int out = real_WSARecv(s, lpBuffers, dwBufferCount, lpNumberOfBytesRecvd, lpFlags, lpOverlapped, lpCompletionRoutine);

		if (theConfig.IsDebugLoggingEnabled() && out == 0)
		{
			if ((*lpFlags & WSASYS_STATUS_LEN) == 0)
			{
				hk::GetLogManager().Printf("WSARecv (x)\n", s);

				if (theConfig.IsTrafficDumpEnabled())
					hk::GetLogManager().Dump(lpBuffers[0].buf, *lpNumberOfBytesRecvd);
			}
		}

		return out;
	}
	//////////////////////////////////////////////////////////////////////////
	// recv
	int __stdcall	my_recv(SOCKET s, char* buf, int len, int flags)
	{
		int received =  real_recv(s, buf, len, flags);

		if (theConfig.IsDebugLoggingEnabled() && received > 0)
		{
			hk::GetLogManager().Printf("Recv (%x)\n", s);

			if (theConfig.IsTrafficDumpEnabled())
				hk::GetLogManager().Dump(buf, received);
		}

		return received;
	}
	//////////////////////////////////////////////////////////////////////////
	// bind
	int __stdcall my_bind(SOCKET sock, const struct sockaddr *name, int namelen)
	{
		theSockServer.VerifySocket(sock);

		// Game hook
		if (theConfig.IsDebugLoggingEnabled())
		{
						sockaddr taddr = *name;
						sockaddr_in * saddr = (sockaddr_in *)&taddr;
						inet_ntoa(saddr->sin_addr);
						hk::GetLogManager().Printf("Bind: tried to bind on: %s\n", inet_ntoa(saddr->sin_addr));
						
		}
		pGameHookBase * pHook = theGame.GetActiveGame()->GetHook();
		if (pHook != NULL)
		{
			hkCallbackResult result = pHook->do_bind(sock, name, namelen);
			switch (result)
			{
			case hkCallback_Accept:
				return 0;
			case hkCallback_Fail:
				return -1;
			}
		}

		// Check if we faking address
		if (theGame.GetActiveGame()->BindForceAllInterfaces())
		{
			sockaddr taddr = *name;
			sockaddr_in * saddr = (sockaddr_in *)&taddr;

			saddr->sin_addr.S_un.S_addr = 0;//inet_addr(theConfig.m_OpenVPNIP.c_str());

			return real_bind(sock, &taddr, sizeof(taddr));
		} else
		{
			return real_bind(sock, name, namelen);
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// closesocket
	int __stdcall my_closesocket(SOCKET s)
	{
		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Printf("closesocket: %x\n", s);

		CloseOverlappedSocket(s);

		// Game hook
		pGameHookBase * pHook = theGame.GetActiveGame()->GetHook();
		if (pHook != NULL)
		{
			hkCallbackResult result = pHook->do_closesocket(s);
			switch (result)
			{
			case hkCallback_Accept:
				return 0;
			case hkCallback_Fail:
				return -1;
			}
		}

		theSockServer.RemoveSocket(s);

		return real_closesocket(s);
	}

	//////////////////////////////////////////////////////////////////////////
	// select
	int __stdcall my_select(int fdSize, FD_SET * read, FD_SET * write, FD_SET * except, const struct timeval * timeout)
	{
		if (read != NULL)
		{
			for (DWORD i = 0; i < read->fd_count; i++)
			{
				theSockServer.VerifySocket(read->fd_array[i]);
			}
		}

		// Game hook
		pGameHookBase * pHook = theGame.GetActiveGame()->GetHook();
		if (pHook != NULL)
		{
			hkCallbackResult result = pHook->do_select(fdSize, read, write, except, timeout);
			switch (result)
			{
			case hkCallback_Accept:
				return 0;
			case hkCallback_Fail:
				return -1;
			}
		}

		return real_select(fdSize, read, write, except, timeout);
	}
	//////////////////////////////////////////////////////////////////////////
	BOOL _stdcall	my_WSAGetOverlappedResult(
								SOCKET s,
								LPWSAOVERLAPPED lpOverlapped,
								LPDWORD lpcbTransfer,
								BOOL fWait,
								LPDWORD lpdwFlags
								)
	{
		BOOL out = real_WSAGetOverlappedResult(s, lpOverlapped, lpcbTransfer, fWait, lpdwFlags);

		if (out)
		{
			pOverlappedEmu_t * pEmu = FindOverlappedSocket(s, lpOverlapped);
			if (pEmu != NULL)
			{
				int result = *lpcbTransfer;

				int_recvfrom(s, pEmu->lpBuf, pEmu->dwBuf, 0, pEmu->lpFrom, pEmu->lpFromlen, result);

				*lpcbTransfer = result;

				if (theConfig.IsDebugLoggingEnabled() && result > 0)
				{
					sockaddr_in * taddr = (sockaddr_in *)pEmu->lpFrom;

					if (theConfig.IsDebugLoggingEnabled())
						hk::GetLogManager().Printf("Overlapped WSAGetOverlappedResult Sock=%x lpFrom=%x\n", s, pEmu->lpFrom);

					if (taddr != NULL)
					{
						hk::GetLogManager().Printf("Got overlapped WSARecvFrom (%x) %s:%d\n", s, inet_ntoa(taddr->sin_addr), ntohs(taddr->sin_port));
					} else
					{
						hk::GetLogManager().Printf("Got overlapped WSARecvFrom (%x)\n", s);
					}

					if (theConfig.IsTrafficDumpEnabled())
						hk::GetLogManager().Dump(pEmu->lpBuf, result);
				} 
			} else
			{
				hk::GetLogManager().Printf("No overlapped socket found for operation, skipped (%x).\n", s);
			}
		}

		return out;
	}
	////
	struct hostent* _stdcall my_gethostbyname(const char* name)
	{
		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Printf("gethostbyname: %s\n", name);

		if (theGame.GetActiveGame()->IsAddressBlocked(name))
			return NULL;

		{
			return real_gethostbyname(name);
		}
	}

	int	__stdcall my_connect(SOCKET s, const struct sockaddr FAR * name, int namelen)
	{
		if (name != NULL)
		{
			if (theConfig.IsDebugLoggingEnabled())
			{
				sockaddr_in * saddr = (sockaddr_in *)name;

				hk::GetLogManager().Printf("Connect: %s:%d\n", inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port));
			}
		}
		
		return real_connect(s, name, namelen);
	}

	int __stdcall	my_getpeername(SOCKET s, struct sockaddr* name, int* namelen)
	{
		int result = real_getpeername(s, name, namelen);

		if (result == 0 && name != NULL)
		{
			if (theConfig.IsDebugLoggingEnabled())
			{
				sockaddr_in * saddr = (sockaddr_in *)name;

				hk::GetLogManager().Printf("getpeername: %s:%d\n", inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port));
			}

		}

		return result;
	}

	SOCKET __stdcall my_accept(SOCKET s, struct sockaddr* addr, int* addrlen)
	{
		SOCKET hRes = real_accept(s, addr, addrlen);

		if (hRes != INVALID_SOCKET && addr != NULL)
		{
				if (theConfig.IsDebugLoggingEnabled())
				{
					sockaddr_in * saddr = (sockaddr_in *)addr;

					hk::GetLogManager().Printf("accept (%x): %s:%d\n", s, inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port));
				}

		}

		return hRes;
	}
	//////////////////////////////////////////////////////////////////////////
	bool	Initialize()
	{
		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Write("Hooking stuff...\n");

		HMODULE hMod = GetModuleHandle("ws2_32.dll");
		if (hMod != NULL)
		{
			real_sendto = (sendto_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "sendto"), &my_sendto);
			real_send   = (send_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "send"), &my_send);
			real_recvfrom = (recvfrom_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "recvfrom"), &my_recvfrom);
			real_WSARecvFrom = (WSARecvFrom_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "WSARecvFrom"), &my_WSARecvFrom);
			real_WSARecv = (WSARecv_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "WSARecv"), &my_WSARecv);
			real_WSAGetOverlappedResult = (WSAGetOverlappedResult_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "WSAGetOverlappedResult"), &my_WSAGetOverlappedResult);
			real_recv    = (recv_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "recv"), &my_recv);
			real_bind   = (bind_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "bind"), &my_bind);
			real_closesocket = (closesocket_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "closesocket"), &my_closesocket);
			real_select   = (select_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "select"), &my_select);
			real_gethostbyname = (gethostbyname_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "gethostbyname"), &my_gethostbyname);
			real_connect = (connect_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "connect"), &my_connect);
			real_getpeername = (getpeername_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "getpeername"), &my_getpeername);
			real_accept = (accept_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "accept"), &my_accept);

			if (real_sendto == NULL || 
				real_send == NULL ||
				real_recvfrom == NULL || 
				real_recv == NULL ||
				real_bind == NULL || 
				real_closesocket == NULL ||
				real_select == NULL)
			{
				hk::GetLogManager().Write("Failed to hook ws2_32.dll functions.\n");
				return false;
			}
		} else
		{
			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("No ws2_32.dll loaded, skipping hooks.\n");
		}

		hMod = GetModuleHandle("iphlpapi.dll");
		if (hMod != NULL)
		{
			real_GetAdaptersAddresses = (GetAdaptersAddresses_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "GetAdaptersAddresses"), &my_GetAdaptersAddresses);

			if (real_GetAdaptersAddresses == NULL )
			{
				hk::GetLogManager().Write("Failed to hook iphlpapi functions.\n");
				//return false;
			}
			else 
				hk::GetLogManager().Write("Hooked iphlpapi functions.\n");

			real_GetAdaptersInfo = (GetAdaptersInfo_t)hk::GetDetourManager().CreateJump(GetProcAddress(hMod, "GetAdaptersInfo"), &my_GetAdaptersInfo);
			if (real_GetAdaptersInfo == NULL )
			{
				hk::GetLogManager().Write("Failed to hook iphlpapi GetAdaptersInfo.\n");
				//return false;
			}
				

		} else
		{
			if (theConfig.IsDebugLoggingEnabled())
				hk::GetLogManager().Write("No iphlpapi loaded, skipping hooks.\n");
		}


		if (!theSockServer.Initialize())
		{
			hk::GetLogManager().Write("Failed to initialize sock server.\n");
			return false;
		}

		return true;
	}

	void	Deinitialize()
	{
		theSockServer.Deinitialize();
	}
}

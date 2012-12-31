#pragma once

#include <iphlpapi.h>
// sendto
typedef int (__stdcall * sendto_t)(SOCKET s,const char *buf,int len,int flags,const struct sockaddr *to,int tolen);
// recvfrom
typedef int (__stdcall * recvfrom_t)(SOCKET s,char *buf,int len,int flags,struct sockaddr *from,int *fromlen); 
// bind
typedef int (__stdcall * bind_t)(SOCKET s,const struct sockaddr *name,int namelen); 
// closesocket
typedef int (__stdcall * closesocket_t)(SOCKET s);
// select
typedef int (__stdcall * select_t)(int fdSize, FD_SET * read, FD_SET * write, FD_SET * except, const struct timeval * timeout);
// WSASendTo
typedef	int (__stdcall * WSASendTo_t)(
			  SOCKET s,
			  LPWSABUF lpBuffers,
			  DWORD dwBufferCount,
			  LPDWORD lpNumberOfBytesSent,
			  DWORD dwFlags,
			  const struct sockaddr* lpTo,
			  int iToLen,
			  LPWSAOVERLAPPED lpOverlapped,
			  LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
			  );
// send
typedef	int (__stdcall * send_t)(
		 SOCKET s,
		 const char* buf,
		 int len,
		 int flags
		 );
// setsockopt
typedef int (__stdcall * setsockopt_t)(
			   SOCKET s,
			   int level,
			   int optname,
			   const char* optval,
			   int optlen
			   );
// recv
typedef	int (__stdcall * recv_t)(
		 SOCKET s,
		 char* buf,
		 int len,
		 int flags
		 );

// WSARecvFrom
typedef int (__stdcall * WSARecvFrom_t)(
				SOCKET s,
				LPWSABUF lpBuffers,
				DWORD dwBufferCount,
				LPDWORD lpNumberOfBytesRecvd,
				LPDWORD lpFlags,
				struct sockaddr* lpFrom,
				LPINT lpFromlen,
				LPWSAOVERLAPPED lpOverlapped,
				LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
				);

typedef int (__stdcall * WSARecv_t)(
					SOCKET s,
					LPWSABUF lpBuffers,
					DWORD dwBufferCount,
					LPDWORD lpNumberOfBytesRecvd,
					LPDWORD lpFlags,
					LPWSAOVERLAPPED lpOverlapped,
					LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
					);

typedef BOOL (__stdcall * WSAGetOverlappedResult_t)(
							SOCKET s,
							LPWSAOVERLAPPED lpOverlapped,
							LPDWORD lpcbTransfer,
							BOOL fWait,
							LPDWORD lpdwFlags
							);

typedef	struct hostent* (__stdcall * gethostbyname_t)(
							const char* name
							);

typedef int (__stdcall * connect_t)(
							SOCKET s,
							const struct sockaddr FAR * name,
							int namelen
							);

typedef int (__stdcall * getpeername_t)(
							SOCKET s,
							struct sockaddr* name,
							int* namelen
							);

typedef	SOCKET (__stdcall * accept_t)(
							SOCKET s,
							struct sockaddr* addr,
							int* addrlen
							);

typedef ULONG (__stdcall * GetAdaptersAddresses_t)( __in     ULONG Family,
  __in     ULONG Flags,
  __in     PVOID Reserved,
  __inout  PIP_ADAPTER_ADDRESSES AdapterAddresses,
  __inout  PULONG SizePointer
);


typedef DWORD (__stdcall * GetAdaptersInfo_t)(
  __out    PIP_ADAPTER_INFO pAdapterInfo,
  __inout  PULONG pOutBufLen
);

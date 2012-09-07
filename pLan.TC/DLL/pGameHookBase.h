#pragma once

enum	hkCallbackResult
{
	hkCallback_Ignore	=	0,	// Forward call to winsock
	hkCallback_Fail,			// Return with error
	hkCallback_Accept			// Return with default success value
};

class	pGameHookBase
{
public:
		pGameHookBase()
		{
		}
		virtual	~pGameHookBase()
		{
		}

		virtual	bool	Initialize(TiXmlElement * xmlElement)
		{
			return true;
		}

		virtual	bool	Activate()
		{
			return true;
		}

		virtual	void	Deactivate()
		{
		}

		virtual	hkCallbackResult	do_sendto(SOCKET sock, const char *buf, int len, int flags, const struct sockaddr *to, int tolen)
		{
			return hkCallback_Ignore;
		}

		virtual	hkCallbackResult	do_send(SOCKET s, const char* buf, int len, int flags)
		{
			return hkCallback_Ignore;
		}

		virtual	hkCallbackResult	do_recvfrom(SOCKET sock, char * buf, int len, int flags, struct sockaddr *to, int *tolen)
		{
			return hkCallback_Ignore;
		}

		virtual	hkCallbackResult	do_bind(SOCKET sock, const struct sockaddr *name, int namelen)
		{
			return hkCallback_Ignore;
		}

		virtual	hkCallbackResult	do_closesocket(SOCKET s)
		{
			return hkCallback_Ignore;
		}

		virtual	hkCallbackResult	do_select(int fdSize, FD_SET * read, FD_SET * write, FD_SET * except, const struct timeval * timeout)
		{
			return hkCallback_Ignore;
		}
};

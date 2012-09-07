#pragma once

class	pGameHookSWBF2 : public pGameHookBase
{
public:
		pGameHookSWBF2();
		virtual	~pGameHookSWBF2();

		virtual	bool	Initialize(TiXmlElement * xmlElement);
		virtual	bool	Activate();
		virtual	void	Deactivate();

		virtual	hkCallbackResult	do_send(SOCKET s, const char* buf, int len, int flags);
		virtual	hkCallbackResult	do_closesocket(SOCKET s);
private:
		SOCKET	*	m_BroadcastSock;
		SOCKET	*	m_ReceiveSock;

		SOCKET		m_hBroadcastCache;
		SOCKET		m_hReceiveCache;

		DWORD		m_CloseTime;

		pGameSearch	m_BroadcastPatch;
		pGameSearch	m_ReceivePatch;
		pGameSearch	m_ClosePatch;

		BYTE	*	m_pCloseSock;
		int			m_retPatch;
		//////////////////////////////////////////////////////////////////////////
		static		void	WINAPI	Callback();

		void	CloseSockets();
};

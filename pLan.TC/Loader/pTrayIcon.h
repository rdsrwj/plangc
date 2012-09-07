#pragma once

class CTrayIcon : public CWnd 
{
public:
	CTrayIcon() 
	{
		m_OK = FALSE;
		m_Location = 0;
		m_HadAnimation = false;
	}

	CTrayIcon(LPCTSTR szTip, HICON hIcon, UINT hMenu) 
	{
		Create(szTip, hIcon, hMenu);
		m_Location = 0;
	}

	virtual ~CTrayIcon() 
	{
		RemoveIcon();
		DestroyWindow();
	}

	CString GetTooltipText() const 
	{
		return NID.szTip;
	}

	BOOL SetTooltipText(LPCTSTR szTip)
	{
		if(!m_OK) 
			return FALSE;

		NID.uFlags=NIF_TIP;
		_tcscpy(NID.szTip, szTip);
		return Shell_NotifyIcon(NIM_MODIFY, &NID);
	}

	HICON GetIcon() const 
	{
		return NID.hIcon;
	}

	BOOL SetIcon(HICON hIcon) 
	{
		if(!m_OK) return FALSE;
		NID.uFlags=NIF_ICON;
		NID.hIcon=hIcon;
		return Shell_NotifyIcon(NIM_MODIFY, &NID);
	}

	void	SetGameLocation(int location)
	{
		m_Location = location;
	}

	//////////////////////////////////////////////////////////////////////////
	void	EnableAnimation(const CString & gameName);
protected:
	int	 m_Location;
	BOOL m_OK;
	NOTIFYICONDATA NID;
	HICON	m_MainIcon;
	HICON	m_ExclamationIcon;
	
	DWORD	m_AnimationEnd;
	bool	m_HadAnimation;

	CString	m_MainTooltip;
	CString	m_GameList;

	// Operations
	BOOL Create(LPCTSTR szTip, HICON hIcon, UINT hMenu);

	void RemoveIcon() 
	{
		if(!m_OK) 
			return;

		NID.uFlags=0;
		Shell_NotifyIcon(NIM_DELETE, &NID);
		m_OK = false;
	}

	// Overrides
	virtual LRESULT WindowProc(UINT Message, WPARAM wParam, LPARAM lParam);
};

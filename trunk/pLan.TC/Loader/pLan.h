#pragma once

#include "resource.h"		// main symbols
#include "pHookLoader.h"
#include "pConfig.h"
#include "pNotification.h"

#define	RESTART_KEY	"xo3482(3jce43)vn30239NBwqpkhv@8fhal@98f0a"
#define	TIMER_TICK	2000

class	CTrayIcon;
class	CpDialogMain;

#define	_X(id)	theApp.GetString(id)

class CpLanApp : public CWinApp
{
public:
	CpLanApp();

// Overrides
	public:
	virtual BOOL InitInstance();

	CString		GetString(DWORD	sID)
	{
		CString	result;
		TCHAR * charBuf = result.GetBuffer(HKMSL);

		LoadString(m_hInstance, sID, charBuf, HKMSL);

		result.ReleaseBuffer();

		return result;
	}

	CTrayIcon	*	GetTrayIcon()
	{
		return m_TrayIcon;
	}

	CpDialogMain *	GetMainDlg()
	{
		return m_MainDlg;
	}

	CNotification *	GetNotification()
	{
		return &m_Notification;
	}

// Implementation
	DECLARE_MESSAGE_MAP()
private:
	CTrayIcon	*	m_TrayIcon;
	CpDialogMain*	m_MainDlg;
	CNotification	m_Notification;
};

extern CpLanApp theApp;

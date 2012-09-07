// pLan.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "pDialogMain.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

CpLanApp	theApp;

// CpLanApp
BEGIN_MESSAGE_MAP(CpLanApp, CWinApp)
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

CpLanApp::CpLanApp()
{
}

BOOL CpLanApp::InitInstance()
{
	HANDLE hMutex; 

	LPSTR	cmdLine = GetCommandLine();

	if (strstr(cmdLine, RESTART_KEY))
	{
		hMutex = CreateMutex( 
			NULL,
			TRUE,
			"pLanMutex");
		if (hMutex == NULL) 
		{
			ExitProcess(0);
		}

		DWORD	result = WaitForSingleObject(hMutex, INFINITE);
		if (result != WAIT_OBJECT_0)
			ExitProcess(0);
	} else
	{
		hMutex = CreateMutex( 
			NULL,
			TRUE,
			"pLanMutex");
		if (hMutex == NULL) 
		{
			ExitProcess(0);
		}
		HRESULT hr = GetLastError();
		if (hr == ERROR_ALREADY_EXISTS || hr == ERROR_ACCESS_DENIED)
		{
			ExitProcess(0);
		}
	}

	InitCommonControls();

	CWinApp::InitInstance();

	theConfig.Initialize();
	
	m_MainDlg = new CpDialogMain();
	m_pMainWnd = m_MainDlg;

	m_TrayIcon = new CTrayIcon(_X(IDS_TRAY_CAPTION), AfxGetApp()->LoadIcon(IDR_MAINFRAME), IDR_TRAYMENU);

	INT_PTR nResponse = m_MainDlg->DoModal();

	ReleaseMutex(hMutex);

	delete m_MainDlg;

	delete m_TrayIcon;
	m_TrayIcon = NULL;

	return FALSE;
}

#include "stdafx.h"
#include "pDialogMain.h"

// CpDialogMain dialog

IMPLEMENT_DYNAMIC(CpDialogMain, CDialog)

CpDialogMain::CpDialogMain(CWnd* pParent /*=NULL*/)
	: CDialog(CpDialogMain::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

	m_NeedTerminate = FALSE;
}

CpDialogMain::~CpDialogMain()
{
}

LRESULT CpDialogMain::OnGetDefID(WPARAM wp, LPARAM lp) 
{
	return MAKELONG(0,DC_HASDEFID); 
}

void CpDialogMain::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_TAB_MAIN, m_TabCtrl);
	DDX_Control(pDX, IDC_HOMEPAGE, m_Homepage);
}


BEGIN_MESSAGE_MAP(CpDialogMain, CDialog)
	ON_WM_TIMER()
	ON_MESSAGE(DM_GETDEFID, OnGetDefID)
	ON_WM_SYSCOMMAND()
	ON_COMMAND(ID_MENU_EXIT, OnMenuExit)
	ON_COMMAND(ID_MENU_INTERNET, OnMenuInternet)
	ON_COMMAND(ID_MENU_UA, OnMenuUa)
	ON_COMMAND(ID_MENU_VOLIA, OnMenuVolia)
//	ON_STN_CLICKED(IDC_HOMEPAGE, &CpDialogMain::OnStnClickedHomepage)
END_MESSAGE_MAP()


// CpDialogMain message handlers
BOOL CpDialogMain::OnInitDialog()
{
	CDialog::OnInitDialog();

	m_Hyperlink.ConvertStaticToHyperlink(GetSafeHwnd(), IDC_HOMEPAGE, "http://plangc.ru/");

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	m_TabCtrl.InitDialogs();

	theApp.GetTrayIcon()->SetGameLocation(GetCurrentLocation());

	SetTimer(1, TIMER_TICK, NULL);

	return TRUE;
}

//void CpDialogMain::OnTimer(UINT nIDEvent)
//{
//	m_TabCtrl.OnTimer();
//
//	if (m_NeedTerminate)
//	{
//		EndDialog(0);
//	}
//
//	CDialog::OnTimer(nIDEvent);
//}

void CpDialogMain::OnTimer(UINT_PTR nIDEvent)
{
	m_TabCtrl.OnTimer();

	if (m_NeedTerminate)
	{
		EndDialog(0);
	}

	CDialog::OnTimer(nIDEvent);
}

void CpDialogMain::SetCurrentLocation(DWORD loc)
{
	HKEY	hKey;
	if (RegCreateKey(HKEY_CURRENT_USER, PLANROOTKEY, &hKey) != ERROR_SUCCESS)
	{
		return;
	}

	RegSetValueEx(hKey, "Location", NULL, REG_DWORD, (LPBYTE)&loc, sizeof(loc));

	RegCloseKey(hKey);

	theApp.GetTrayIcon()->SetGameLocation(loc);
}

void CpDialogMain::OnMenuInternet()
{
	SetCurrentLocation(0);
}

void CpDialogMain::OnMenuUa()
{
	SetCurrentLocation(1);
}


void CpDialogMain::OnMenuVolia()
{
	SetCurrentLocation(2);
}

void CpDialogMain::OnSysCommand(UINT nID, LPARAM lParam)
{
	switch(nID & 0xFFF0) 
	{
	case SC_MINIMIZE:  
		{
			if(lParam) 
				ShowWindow(SW_HIDE); 
			else 
				SetForegroundWindow(); 
			break;
		}
	default:
		{
			CDialog::OnSysCommand(nID, lParam);
			break;
		}
	} 
}

void CpDialogMain::OnMenuExit()
{
	EndDialog(0);
}

DWORD	CpDialogMain::GetCurrentLocation()
{
	HKEY	hKey;
	if (RegCreateKey(HKEY_CURRENT_USER, PLANROOTKEY, &hKey) != ERROR_SUCCESS)
	{
		return false;
	}

	DWORD loc;
	DWORD pType;
	DWORD pLength = sizeof(loc);

	if (RegQueryValueEx(hKey, "Location", NULL, &pType, (LPBYTE)&loc, &pLength) == ERROR_SUCCESS)
	{
		RegCloseKey(hKey);
		return loc;
	} else
	{
		RegCloseKey(hKey);
		return PLAN_LOCATION_UAIX;
	}
}

//void CpDialogMain::OnStnClickedHomepage()
//{
//	ShellExecute(m_hWnd, "OPEN", "http://plan.volia.org/", NULL, NULL, SW_SHOW);
//}

#include	"stdafx.h"
#include	"pMyTabCtrl.h"

#include	"pLanDlg.h"
#include	"pDialogGames.h"
#include	"pDialogNotify.h"

BEGIN_MESSAGE_MAP(CpMyTabCtrl, CTabCtrl)
	//{{AFX_MSG_MAP(MyTabCtrl)
	ON_NOTIFY_REFLECT(TCN_SELCHANGE, OnSelchange)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

CpMyTabCtrl::CpMyTabCtrl() : CTabCtrl()
{
}

CpMyTabCtrl::~CpMyTabCtrl()
{
	for (DWORD i = 0; i < TAB_SHEETS; i++)
		delete m_Dialogs[i];
}

void	CpMyTabCtrl::InitDialogs()
{
	m_Dialogs[0] = new CpLanDlg(GetParent());
	m_Dialogs[0]->Create(CpLanDlg::IDD, GetParent());
	InsertItem(0, _X(IDS_UPDATE));

	m_Dialogs[1] = new CpDialogGames(GetParent());
	m_Dialogs[1]->Create(CpDialogGames::IDD, GetParent());
	InsertItem(1, _X(IDS_GAMES));

	m_Dialogs[2] = new CpDialogNotify(GetParent());
	m_Dialogs[2]->Create(CpDialogNotify::IDD, GetParent());
	InsertItem(2, _X(IDS_NOTIFICATIONS));

	ActivateTabDialogs();
}

void	CpMyTabCtrl::ChangeTab(int tabNumber)
{
	SetCurSel(tabNumber);
	ActivateTabDialogs();
}

void	CpMyTabCtrl::OnSelchange(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	ActivateTabDialogs();
	*pResult = 0;
}

void	CpMyTabCtrl::ActivateTabDialogs()
{
	int nSel = GetCurSel();
	if(m_Dialogs[nSel]->m_hWnd)
		m_Dialogs[nSel]->ShowWindow(SW_HIDE);

	CRect l_rectClient;
	CRect l_rectWnd;

	GetClientRect(l_rectClient);
	AdjustRect(FALSE,l_rectClient);
	GetWindowRect(l_rectWnd);
	GetParent()->ScreenToClient(l_rectWnd);
	l_rectClient.OffsetRect(l_rectWnd.left,l_rectWnd.top);
	
	for (int nCount = 0; nCount < TAB_SHEETS; nCount++)
	{
		m_Dialogs[nCount]->SetWindowPos(&wndTop, l_rectClient.left, l_rectClient.top, l_rectClient.Width(), l_rectClient.Height(), SWP_HIDEWINDOW);
	}

	m_Dialogs[nSel]->SetWindowPos(&wndTop, l_rectClient.left, l_rectClient.top, l_rectClient.Width(), l_rectClient.Height(), SWP_SHOWWINDOW);

	m_Dialogs[nSel]->ShowWindow(SW_SHOW);
}

void	CpMyTabCtrl::OnTimer()
{
	for (int i = 0; i < TAB_SHEETS; i++)
		m_Dialogs[i]->OnTimer();
}

void	CpMyTabCtrl::OnEndUpdate()
{
	for (int i = 0; i < TAB_SHEETS; i++)
		m_Dialogs[i]->OnEndUpdate();
}
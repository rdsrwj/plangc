#include "stdafx.h"
#include "pLanDlg.h"
#include "pDialogMain.h"

CpLanDlg::CpLanDlg(CWnd* pParent /*=NULL*/)
	: CpMyDialog(CpLanDlg::IDD, pParent)
{
	m_UpdateSucceeded = FALSE;
}

void CpLanDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_EDIT1, m_Information);
	DDX_Control(pDX, IDC_PROGRESS1, m_Progress);
	DDX_Control(pDX, IDC_PROGRESSINFO, m_ProgressInfo);
}

BEGIN_MESSAGE_MAP(CpLanDlg, CDialog)
	ON_WM_PAINT()
	ON_MESSAGE(DM_GETDEFID, OnGetDefID)
	//}}AFX_MSG_MAP
	ON_WM_SHOWWINDOW()
END_MESSAGE_MAP()


// CpLanDlg message handlers
LRESULT CpLanDlg::OnGetDefID(WPARAM wp, LPARAM lp) 
{
	return MAKELONG(0,DC_HASDEFID); 
}

BOOL CpLanDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	m_Updater.Initialize(&m_Progress, &m_ProgressInfo);

	SetDlgItemText(IDC_FRAME_NEWS, _X(IDS_FRAME_NEWS));
	SetDlgItemText(IDC_FRAME_UPDATE_PROGRESS, _X(IDS_FRAME_UPDATE_PROGRESS));
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CpLanDlg::OnPaint() 
{
/*	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	} */

	CDialog::OnPaint();
}

BOOL CpLanDlg::DestroyWindow()
{
	if (m_Loader.Initialized())
		m_Loader.Unhooker();

	return CDialog::DestroyWindow();
}

void CpLanDlg::OnShowWindow(BOOL bShow, UINT nStatus)
{
	CDialog::OnShowWindow(bShow, nStatus);

	static bool updated = false;
	if (!updated)
	{
		DWORD tid;
		CreateThread(0, 0x10000, &threadProc, this, 0, &tid);

		updated = true;
	}
}

DWORD	WINAPI	CpLanDlg::threadProc(LPVOID lpParam)
{
	Sleep(500);

	CpLanDlg * pDialog = (CpLanDlg *)lpParam;
	if (!pDialog->m_Updater.GetNews(pDialog->m_Information))
		return 0;

	if (!pDialog->m_Updater.DoUpdate())
		return 0;

	pDialog->UpdateSucceeded();

	return 0;
}

void	CpLanDlg::UpdateSucceeded()
{
/*	if (m_Loader.Initialize())
	{
		m_Loader.Hooker();

		m_ProgressInfo.SetWindowText("pLan is working.");
	} */

	m_UpdateSucceeded = TRUE;
}

void CpLanDlg::OnTimer()
{
	if (m_UpdateSucceeded && !m_Loader.Initialized())
	{
		if (m_Loader.Initialize())
		{
			m_Loader.Hooker();

			m_Progress.SetPos(0);

			m_ProgressInfo.SetWindowText(_X(IDS_PLAN_IS_WORKING));

			CpDialogMain * pDialog = theApp.GetMainDlg();

			//pDialog->PostMessage(WM_SYSCOMMAND, SC_MINIMIZE, 1);

			pDialog->OnEndUpdate();
		} else
		{
			m_ProgressInfo.SetWindowText(_X(IDS_PLAN_FAILED_TO_INITIALIZE));
		}
	}
}
#pragma once
#include "afxwin.h"
#include "afxcmn.h"
#include "pUpdater.h"

// CpLanDlg dialog
class CpLanDlg : public CpMyDialog
{
// Construction
public:
	CpLanDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_PLAN_DIALOG };
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support

	pUpdater	&	GetUpdater()
	{
		return m_Updater;
	}

// Implementation
protected:
	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg LRESULT OnGetDefID(WPARAM wp, LPARAM lp);
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	DECLARE_MESSAGE_MAP()
public:
	CEdit m_Information;
	CProgressCtrl m_Progress;
	virtual BOOL DestroyWindow();
	CStatic m_ProgressInfo;

	pUpdater	m_Updater;
	pHookLoader	m_Loader;

	bool	m_UpdateSucceeded;

	//////////////////////////////////////////////////////////////////////////
	DWORD	GetCurrentLocation();
	void	SetCurrentLocation(DWORD location);

	static	DWORD	WINAPI	threadProc(LPVOID lpParam);

	void	UpdateSucceeded();
public:
	virtual	void	OnTimer();
};

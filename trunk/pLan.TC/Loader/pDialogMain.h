#pragma once

#include "afxcmn.h"
#include "pMyTabCtrl.h"
#include "afxwin.h"
#include "hyperlink.h"

class CpDialogMain : public CDialog
{
	DECLARE_DYNAMIC(CpDialogMain)

public:
	CpDialogMain(CWnd* pParent = NULL);   // standard constructor
	virtual ~CpDialogMain();

// Dialog Data
	enum { IDD = IDD_DIALOG_MAIN };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	virtual BOOL OnInitDialog();

	void	SetNeedTerminate()
	{
		m_NeedTerminate = true;
	}

	afx_msg LRESULT OnGetDefID(WPARAM wp, LPARAM lp);
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnMenuExit();
	afx_msg void OnMenuInternet();
	afx_msg void OnMenuUa();
	afx_msg void OnMenuVolia();
	afx_msg void OnMenuLocalnetwork();

	DWORD		 GetCurrentLocation();

	void	OnEndUpdate()
	{
		m_TabCtrl.OnEndUpdate();
	}

	CpMyTabCtrl	&	GetTabCtrl()
	{
		return m_TabCtrl;
	}
private:
	CpMyTabCtrl m_TabCtrl;

	HICON		m_hIcon;

	BOOL		m_NeedTerminate;

	void		SetCurrentLocation(DWORD loc);

	CHyperLink	m_Hyperlink;

	CStatic		m_Homepage;
//	afx_msg void OnStnClickedHomepage();
};

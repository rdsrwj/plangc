#pragma once
#include "afxwin.h"

class CpDialogNotify : public CpMyDialog
{
	DECLARE_DYNAMIC(CpDialogNotify)

public:
	CpDialogNotify(CWnd* pParent = NULL);   // standard constructor
	virtual ~CpDialogNotify();

// Dialog Data
	enum { IDD = IDD_DIALOG_NOTIFY };
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	virtual	BOOL OnInitDialog();
	virtual	void OnEndUpdate();
	
	afx_msg LRESULT OnGetDefID(WPARAM wp, LPARAM lp);

	DECLARE_MESSAGE_MAP()
private:
	CListCtrl m_ListCtrl;
	CStatic m_VisibleGameServers;

	CpWinInetWrapper	m_Internet;

	typedef	std::map<CString, int>		iconMap_t;
	iconMap_t	m_GameIcons;
	CImageList	m_IconsList;

	typedef std::map<CString, CString>	gameNames_t;
	gameNames_t	m_GameNames;

	typedef std::vector<CString>	gameIds_t;
	gameIds_t	m_GameIds;
	//////////////////////////////////////////////////////////////////////////
	int		GetIcon(const CString & gameTag);

	DWORD	GetGameID(const CString & name);
	const	CString	&	GetGameName(const CString & gameTag);
	afx_msg void OnNMClickListGames(NMHDR *pNMHDR, LRESULT *pResult);
};

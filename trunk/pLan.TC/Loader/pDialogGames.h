#pragma once
#include "afxwin.h"

class CpDialogGames : public CpMyDialog
{
	DECLARE_DYNAMIC(CpDialogGames)

public:
	CpDialogGames(CWnd* pParent = NULL);   // standard constructor
	virtual ~CpDialogGames();

// Dialog Data
	enum { IDD = IDD_DIALOG_GAMELIST };
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	virtual	BOOL OnInitDialog();
	
	virtual	void OnTimer();
	virtual	void OnEndUpdate();

	afx_msg LRESULT OnGetDefID(WPARAM wp, LPARAM lp);

	DECLARE_MESSAGE_MAP()
private:
	CListCtrl m_ListCtrl;

	CpWinInetWrapper	m_Internet;

	DWORD	  m_UpdateTimer;

	BOOL	m_NeedWork;
	BOOL	m_Working;

	BOOL	m_NeedUpdate;
	DWORD	m_LastUpdate;

	typedef	std::map<CString, int>	iconMap_t;

	iconMap_t	m_GameIcons;
	CImageList	m_IconsList;

	typedef std::map<CString, CString>	gameNames_t;
	gameNames_t	m_GameNames;

	typedef std::vector<CString>	gameIds_t;
	gameIds_t	m_GameIds;

	typedef std::set<CString>		gameSet_t;
	gameSet_t	m_LastGames;
	gameSet_t	m_CurrentGames;
	
private:
	CStatic m_VisibleGameServers;
	CButton m_RefreshButton;

	static	DWORD	WINAPI	threadProc(LPVOID lpParam);

	void	DoUpdate();

	int		GetIcon(const CString & gameTag);

	DWORD	GetGameID(const CString & name);

	const	CString	&	GetGameName(const CString & gameTag);
	afx_msg void OnBnClickedButton1();
	afx_msg void OnNMDblclkListGames(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnGamelistDeleteassociation();
	afx_msg void OnNMRclickListGames(NMHDR *pNMHDR, LRESULT *pResult);
};

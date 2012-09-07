#pragma once

#define	TAB_SHEETS	3

class	CpMyTabCtrl : public CTabCtrl
{
public:
		CpMyTabCtrl();
		~CpMyTabCtrl();

		void	InitDialogs();

		void	OnSelchange(NMHDR* pNMHDR, LRESULT* pResult);
		void	ChangeTab(int tabNumber);

		// Different actions
		void	OnTimer();
		void	OnEndUpdate();
protected:
		void	ActivateTabDialogs();

		CpMyDialog	*	m_Dialogs[TAB_SHEETS];

		DECLARE_MESSAGE_MAP()
};
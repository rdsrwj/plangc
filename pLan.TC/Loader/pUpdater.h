#pragma once

class	pUpdater
{
public:
		pUpdater();
		~pUpdater();

		bool	Initialize(CProgressCtrl * progressCtrl, CStatic * progressInfo);

		bool	GetNews(CEdit & edit);
		bool	DoUpdate();
private:
		CProgressCtrl	*	m_ProgressCtrl;
		CStatic			*	m_ProgressInfo;
		CpWinInetWrapper 	m_Internet;

		bool	GetVersionInfo(const char * tName, int & defVersion, int & dllVersion, int & exeVersion);

		int		GetDllVersion();

		bool	UpdateLoader();

		void	SetInfo(const char * szString)
		{
			if (m_ProgressInfo != NULL)
			{
				m_ProgressInfo->SetWindowText(szString);
//				theApp.GetMainWnd()->RedrawWindow();
			}
		}
};

#pragma once

class	CpWinInetWrapper
{
public:
		CpWinInetWrapper();
		~CpWinInetWrapper();

		BOOL	Initialize(CProgressCtrl * progressCtrl);

		bool	ReceiveFile(const CString & outFile, const CString & inPath);
		bool	ReceiveText(CString & outText, const CString & inPath);

		BOOL	IsInitialized() const
		{
			return m_Initialized;
		}
private:
		CProgressCtrl	*	m_ProgressCtrl;

		HINTERNET	m_hInternet;

		BOOL		m_Initialized;
};
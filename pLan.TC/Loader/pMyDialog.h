#pragma once

class	CpMyDialog : public CDialog
{
public:
	CpMyDialog(UINT nIDTemplate, CWnd* pParent = NULL) : CDialog(nIDTemplate, pParent)
	{
	}

	virtual	void	OnTimer()
	{
	}

	virtual	void	OnEndUpdate()
	{
	}
};
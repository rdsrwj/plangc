#pragma once

class	CNotification
{
public:
		CNotification();
		~CNotification();

		bool	IsNotificationEnabled(const CString & gameID);
		void	SetNotificationEnable(const CString & gameID, bool enable);
private:
		CRegKey	m_RegKey;
};
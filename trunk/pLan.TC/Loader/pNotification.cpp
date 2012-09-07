#include "stdafx.h"
#include "pNotification.h"

CNotification::CNotification()
{
	try
	{
		m_RegKey.Create(HKEY_CURRENT_USER, "Software\\pLan\\Notifications");
	} catch(...)
	{
	}
}

CNotification::~CNotification()
{
	try
	{
		m_RegKey.Close();
	}
	catch (...)
	{		
	}
}

bool	CNotification::IsNotificationEnabled(const CString & gameID)
{
	DWORD	value;
	bool	haveItInList = false;

	try
	{
		if (m_RegKey.QueryDWORDValue(gameID, value) == ERROR_SUCCESS)
			if (value != 0)
				haveItInList = true;
	}
	catch (...)
	{
	}
	
	return haveItInList;
}

void	CNotification::SetNotificationEnable(const CString & gameID, bool enable)
{
	if (enable)
	{
		try
		{
			m_RegKey.SetDWORDValue(gameID, 1);
		}
		catch (...)
		{			
		}
	} else
	{
		try
		{
			m_RegKey.DeleteValue(gameID);
		}
		catch (...)
		{
		}
	}
}

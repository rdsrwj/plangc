#include "stdafx.h"
#include <shlobj.h>
#include "resource.h"

#define	NEW_HOSTING_FIX

pConfig	theConfig;

pConfig::pConfig()
{
}

bool	pConfig::Initialize()
{
	char	buf[HKMSL];

	if (strstr(GetCommandLine(), RESTART_KEY))
	{
		m_AutoStarted = TRUE;
	} else
	{
		m_AutoStarted = FALSE;
	}

	HKEY	hKey;
	if (RegCreateKey(HKEY_CURRENT_USER, PLANROOTKEY, &hKey) != ERROR_SUCCESS)
	{
		return false;
	}

	if (!VerifySettings(hKey))
	{
		return false;
	}

	// Local data path
	if (SHGetSpecialFolderPath(NULL, buf, CSIDL_LOCAL_APPDATA, FALSE ) == TRUE)
	{
		strcat(buf, "\\pLanTC");
		m_DataPath = buf;
	} else
	{
		RegCloseKey(hKey);
		return false;
	}

	if (GetModuleFileName(GetModuleHandle(NULL), buf, HKMSL) == 0)
	{
		RegCloseKey(hKey);
		return false;
	}
	// Local name
	m_LocalName = buf;

	// Game name
	StripName(buf);
	m_GamePath = buf;

	// Tracker URL
	if (!ReadStringValue(hKey, "tracker_host", m_TrackerHost))
	{
		RegCloseKey(hKey);
		return false;
	}

#ifdef NEW_HOSTING_FIX
	if (m_TrackerHost == "plan.volia.org" || m_TrackerHost == "plangc.ru")
	{
#define	NEW_HOST	"tracker.plangc.ru"

		RegSetValueEx(hKey, "tracker_host", 0, REG_SZ, (byte *)NEW_HOST, sizeof(NEW_HOST));
		m_TrackerHost = NEW_HOST;
	}
#endif

	DWORD port;
	if (!ReadDwordValue(hKey, "tracker_port", port))
	{
		/*m_TrackerPort = 80;*/
		m_TrackerPort = INTERNET_DEFAULT_HTTPS_PORT;
	} else
	{
		m_TrackerPort = static_cast<WORD>(port);
	}

	if (!ReadStringValue(hKey, "tracker_path", m_TrackerPath))
	{
		RegCloseKey(hKey);
		return false;
	}

#ifdef NEW_HOSTING_FIX
	if (m_TrackerPath == "/tracker/")
	{
#define	NEW_PATH	"/"

		RegSetValueEx(hKey, "tracker_path", 0, REG_SZ, (byte *)NEW_PATH, sizeof(NEW_PATH));
		m_TrackerPath = NEW_PATH;
	}
#endif

	RegCloseKey(hKey);

	return true;
}

bool	pConfig::ReadBoolValue(HKEY hKey, const char * szName)
{
	DWORD	pType;
	DWORD	pData = 0;
	DWORD	pLength = sizeof(pData);

	if (RegQueryValueEx(hKey, szName, NULL, &pType, (LPBYTE)&pData, &pLength) == ERROR_SUCCESS)
	{
		return pData != 0;
	} else
	{
		return false;
	}
}

bool	pConfig::ReadDwordValue(HKEY hKey, const char * szName, DWORD & dw)
{
	DWORD	pType;
	DWORD	pLength = sizeof(dw);

	if (RegQueryValueEx(hKey, szName, NULL, &pType, (LPBYTE)&dw, &pLength) == ERROR_SUCCESS)
	{
		return true;
	} else
	{
		return false;
	}
}

bool	pConfig::ReadStringValue(HKEY hKey, const char * szName, TiXmlString & xmlString)
{
	DWORD	pType;
	char	buf[HKMSL];
	DWORD	pLength = HKMSL;

	buf[0] = '\0';

	if (RegQueryValueEx(hKey, szName, NULL, &pType, (LPBYTE)&buf, &pLength) == ERROR_SUCCESS)
	{
		if (pType != REG_SZ)
		{
			return false;
		}

		xmlString = buf;

		return true;
	} else
	{
		return false;
	}
}

void	pConfig::StripName(char * buf)
{
	char * c = buf + strlen(buf) - 1;

	while (c > buf && *c != '\\' && *c != '/') c--;

	if (c > buf)
	{
		*c = '\0';
	}
}

void	pConfig::StripPath(const char * source, char * dest)
{
	const char * c = source + strlen(source) - 1;

	while (c > source && *c != '\\' && *c != '/') c--;

	if (c > source) c++;

	strcpy(dest, c);
}

bool	pConfig::VerifySettings(HKEY hKey)
{
	TiXmlString p;

	if (!ReadStringValue(hKey, "tracker_host", p) ||
		!ReadStringValue(hKey, "tracker_path", p))
	{
		CString temp;

		// Host
		temp = _X(IDS_TRACKER_HOST);
		if (temp.IsEmpty())
			return false;

		if (RegSetValueEx(hKey, "tracker_host", 0, REG_SZ, (const BYTE *)temp.GetString(), temp.GetLength()) != ERROR_SUCCESS)
		{
			return false;
		}

		// Path
		temp = _X(IDS_TRACKER_PATH);
		if (temp.IsEmpty())
			return false;

		if (RegSetValueEx(hKey, "tracker_path", 0, REG_SZ, (const BYTE *)temp.GetString(), temp.GetLength()) != ERROR_SUCCESS)
		{
			return false;
		}

		// Port
		temp = _X(IDS_TRACKER_PORT);
		if (temp.IsEmpty())
			return true;

		int port = atoi(temp.GetString());
		if (RegSetValueEx(hKey, "tracker_port", 0, REG_DWORD, (const BYTE *)&port, sizeof(port)) != ERROR_SUCCESS)
		{
			return false;
		}

		// Location
		temp = _X(IDS_LOCATION);
		if (temp.IsEmpty())
			return true;

		int location = atoi(temp.GetString());
		if (RegSetValueEx(hKey, "Location", 0, REG_DWORD, (const BYTE *)&location, sizeof(location)) != ERROR_SUCCESS)
		{
			return false;
		}
	}

	return true;
}

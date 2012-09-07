#include "stdafx.h"
#include <ShlObj.h>

pConfig	theConfig;

pConfig::pConfig()
{
	m_LoggingEnabled = false;
}

bool	pConfig::Initialize(HMODULE hMod)
{
	char	buf[HKMSL], buf2[HKMSL];

	HKEY	hKey;
	if (RegCreateKey(HKEY_CURRENT_USER, PLANROOTKEY, &hKey) != ERROR_SUCCESS)
	{
		return false;
	}

	m_LoggingEnabled = ReadBoolValue(hKey, "log");
	hk::GetLogManager().SetEnable(m_LoggingEnabled);

	m_DebugLogging = ReadBoolValue(hKey, "debug");

	m_DebugTraffic = ReadBoolValue(hKey, "log_traffic");

	// Local data path
	if (SHGetFolderPath(NULL, CSIDL_LOCAL_APPDATA, NULL, SHGFP_TYPE_CURRENT, buf) == S_OK)
	{
		strcat(buf, "\\pLanTC");
		m_DataPath = buf;
	} else
	{
		RegCloseKey(hKey);
		hk::GetLogManager().Write("Failed to get local application data directory.\n");
		return false;
	}

	// DLL path
	if (GetModuleFileName(hMod, buf, HKMSL) == 0)
	{
		RegCloseKey(hKey);
		hk::GetLogManager().Write("Failed to get DLL path.\n");
		return false;
	}
	StripName(buf);
	m_DllPath = buf;

	if (GetModuleFileName(GetModuleHandle(NULL), buf, HKMSL) == 0)
	{
		RegCloseKey(hKey);
		hk::GetLogManager().Write("Failed to get application path.\n");
		return false;
	}

	hk::GetLogManager().Printf("Injected into '%s'\n", buf);

	// Game name
	StripPath(buf, buf2);
	m_GameName = buf2;

	// Game path
	StripName(buf);
	m_GamePath = buf;

	// Tracker URL
	if (!ReadStringValue(hKey, "tracker_host", m_TrackerHost))
	{
		RegCloseKey(hKey);
		hk::GetLogManager().Write("Failed to get tracker Host.\n");
		return false;
	}

	DWORD port;
	if (!ReadDwordValue(hKey, "tracker_port", port))
	{
		m_TrackerPort = 80;
	} else
	{
		m_TrackerPort = (WORD)port;
	}
	if (!ReadStringValue(hKey, "tracker_path", m_TrackerPath))
	{
		RegCloseKey(hKey);
		hk::GetLogManager().Write("Failed to get tracker path.\n");
		return false;
	}

	if (!ReadDwordValue(hKey, "local_addr", port))
	{
		m_LocalAddressByte = FAKEIPNUM;
	} else
	{
		m_LocalAddressByte = (byte)port;
	}

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
		return (dw != 0);
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
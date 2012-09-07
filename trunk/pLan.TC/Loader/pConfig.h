#pragma once

#define	PLANROOTKEY	"Software\\pLan"

class pConfig
{
public:
	pConfig();

	bool	Initialize();

	// Return path to data
	const	char	*	GetDataPath() const
	{
		return m_DataPath.c_str();
	}

	const	char	*	GetLocalPath() const
	{
		return m_GamePath.c_str();
	}

	const	char	*	GetLocalName() const
	{
		return m_LocalName.c_str();
	}

	// Tracker URL
	const	char	*	GetTrackerHost() const
	{
		return m_TrackerHost.c_str();
	}

	WORD	GetTrackerPort() const
	{
		return m_TrackerPort;
	}

	const	char	*	GetTrackerPath() const
	{
		return m_TrackerPath.c_str();
	}

	bool	IsAutoStarted() const
	{
		return m_AutoStarted;
	}
private:
	// Local data path
	TiXmlString	m_DataPath;
	// Tracker URL
	TiXmlString	m_TrackerHost;
	WORD		m_TrackerPort;
	TiXmlString	m_TrackerPath;
	// Game
	TiXmlString	m_LocalName;
	TiXmlString	m_GamePath;
	bool		m_AutoStarted;
private:
	bool		ReadBoolValue(HKEY hKey, const char * szName);
	bool		ReadDwordValue(HKEY hKey, const char * szName, DWORD & dw);
	bool		ReadStringValue(HKEY hKey, const char * szName, TiXmlString & xmlString);

	void		StripName(char * buf);
	void		StripPath(const char * source, char * dest);

	bool		VerifySettings(HKEY hKey);
};

extern	pConfig	theConfig;

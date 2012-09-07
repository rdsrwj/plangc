#pragma once

#define	PLANROOTKEY	"Software\\pLan"

class pConfig
{
public:
		pConfig();

		bool	Initialize(HMODULE hMod);

		// Return path to data
		const	char	*	GetDataPath() const
		{
			return m_DataPath.c_str();
		}

		// Return path to DLL
		const	char	*	GetDllPath() const
		{
			return m_DllPath.c_str();
		}

		// Return path to Game
		const	char	*	GetGamePath() const
		{
			return m_GamePath.c_str();
		}

		// Return name of game executable file
		const	char	*	GetGameName() const
		{
			return m_GameName.c_str();
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

		// Enabled/disabled logging
		bool	IsLoggingEnabled() const
		{
			return m_LoggingEnabled;
		}

		bool	IsDebugLoggingEnabled() const
		{
			return m_DebugLogging;
		}

		bool	IsTrafficDumpEnabled() const
		{
			return m_DebugTraffic;
		}

		byte	GetLocalAddressByte() const
		{
			return m_LocalAddressByte;
		}
private:
		// Local data path
		TiXmlString	m_DataPath;
		// DLL path
		TiXmlString	m_DllPath;
		// Game path
		TiXmlString	m_GamePath;
		// Game executable name
		TiXmlString	m_GameName;
		// Tracker URL
		TiXmlString	m_TrackerHost;
		WORD		m_TrackerPort;
		TiXmlString	m_TrackerPath;

		// Logging related
		bool		m_LoggingEnabled;
		bool		m_DebugLogging;
		bool		m_DebugTraffic;

		// Local address
		byte		m_LocalAddressByte;
private:
		bool		ReadBoolValue(HKEY hKey, const char * szName);
		bool		ReadDwordValue(HKEY hKey, const char * szName, DWORD & dw);
		bool		ReadStringValue(HKEY hKey, const char * szName, TiXmlString & xmlString);

		void		StripName(char * buf);
		void		StripPath(const char * source, char * dest);
};

extern	pConfig	theConfig;

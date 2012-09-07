#include "stdafx.h"

pHookLoader::pHookLoader()
{
	m_hMOD = NULL;

	m_hooker = NULL;
	m_unhooker = NULL;
	m_version = NULL;
}

pHookLoader::~pHookLoader()
{
	if (Initialized())
	{
		Unhooker();
	}

	FreeLibrary(m_hMOD);
}

bool	pHookLoader::Initialize()
{
	CString	path;
	path.Format("%s\\pLan.dll", theConfig.GetDataPath());

	m_hMOD = LoadLibrary(path.GetString());
	if (m_hMOD != NULL)
	{
		m_hooker = (noreturn_t)GetProcAddress(m_hMOD, "Hooker");
		m_unhooker = (noreturn_t)GetProcAddress(m_hMOD, "Unhooker");
		m_version = (dwreturn_t)GetProcAddress(m_hMOD, "Version");

		return true;
	} else
	{
		return false;
	}
}

bool	pHookLoader::Initialized() const
{
	return m_hMOD != NULL;
}

void	pHookLoader::Hooker() const
{
	m_hooker();
}

void	pHookLoader::Unhooker() const
{
	m_unhooker();
}

DWORD	pHookLoader::Version() const
{
	return m_version();
}

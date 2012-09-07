#pragma once

typedef	void	(WINAPI	* noreturn_t)();
typedef	DWORD	(WINAPI	* dwreturn_t)();

class	pHookLoader
{
public:
		pHookLoader();
		~pHookLoader();

		bool	Initialize();
		bool	Initialized() const;

		void	Hooker() const;
		void	Unhooker() const;
		DWORD	Version() const;
private:
		HMODULE	m_hMOD;

		noreturn_t	m_hooker;
		noreturn_t	m_unhooker;
		dwreturn_t	m_version;
};

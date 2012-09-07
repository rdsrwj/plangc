#pragma once

class	hkLog
{
public:
		hkLog();
		~hkLog();

		void	Deinitialize();

		void	Write(const char * szLog);
		void	Printf(const char * szFormat, ...);
		void	Dump(const LPVOID buffer, DWORD bufLen);

		void	SetEnable(bool enable);
private:
		FILE	*	m_fp;

private:
		void	DoOpen();
};

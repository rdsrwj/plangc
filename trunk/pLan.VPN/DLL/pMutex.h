#pragma once

class	pMutex
{
public:
		pMutex()
		{
			InitializeCriticalSection(&m_Section);
		}

		~pMutex()
		{
			DeleteCriticalSection(&m_Section);
		}

		void	Lock()
		{
			EnterCriticalSection(&m_Section);
		}

		void	Unlock()
		{
			LeaveCriticalSection(&m_Section);
		}
private:
		CRITICAL_SECTION	m_Section;
};

class	pAutoMutex
{
public:
		pAutoMutex(pMutex & mutex) : m_Mutex(mutex)
		{
			m_Mutex.Lock();
		}

		~pAutoMutex()
		{
			m_Mutex.Unlock();
		}
private:
		pMutex	&	m_Mutex;
};

#pragma once

template	<class TYPE> class	hkDynBuffer 
{
public:
	hkDynBuffer()
	:	m_Buffer		(NULL)
	,	m_BufferAlloc	(16)
	,	m_BufferLen		(0)
	{
		m_Buffer = new TYPE[m_BufferAlloc];
	}

	hkDynBuffer(const hkDynBuffer<TYPE> & source)
	:	m_Buffer		(NULL)
	,	m_BufferAlloc	(16)
	,	m_BufferLen		(0)
	{
		if (&source != this)
		{
			FeedFrom(source);
		}
	}

	virtual	~hkDynBuffer()
	{
		delete [] m_Buffer;
	}

	inline	DWORD	GetSize() const
	{
		return m_BufferLen;
	}

	inline	void	FeedFrom(const hkDynBuffer<TYPE> & source)
	{
		delete [] m_Buffer;
		m_Buffer = NULL;
		m_BufferAlloc = source.m_BufferAlloc;
		m_BufferLen   = source.m_BufferLen;
		m_Buffer = new TYPE[m_BufferAlloc];
		memcpy(m_Buffer, source.m_Buffer, m_BufferLen * sizeof(TYPE));
	}

	inline	TYPE &	operator[](DWORD index)
	{
		return m_Buffer[index];
	}

	inline const TYPE & operator [](DWORD index) const
	{
		return m_Buffer[index];
	}

	inline	const hkDynBuffer<TYPE> &	operator =(const hkDynBuffer<TYPE> & value)
	{
		if (&value != this)
		{
			FeedFrom(value);
		}
		return *this;
	}

	inline	void	Add(TYPE element = TYPE())
	{
		if ( m_BufferLen + 1 >= m_BufferAlloc )
		{
			m_BufferAlloc *= 2;
			TYPE * temp = new TYPE[m_BufferAlloc];
			memcpy(temp, m_Buffer, m_BufferLen * sizeof(TYPE));
			delete [] m_Buffer;
			m_Buffer = temp;
		}
		m_Buffer[m_BufferLen++] = element;
	}

	inline void		Reserve(DWORD number, TYPE defValue = TYPE())
	{
		// If requested capacity is less than current capacity than do nothing
		if (number <= m_BufferLen) return;
		// Save current element count
		int cnt = m_BufferLen;
		// Else enlarge capacity of buffer
		for (DWORD i = m_BufferLen; i < number; ++i)
		{
			Add(defValue);
		}
		m_BufferLen = cnt;
	}

	inline void Resize(DWORD newSize)
	{
		if (newSize < m_BufferLen)
		{
			m_BufferLen = newSize;
		}
		else
		{
			for (DWORD i = m_BufferLen; i < newSize; ++i)
			{
				Add();
			}
		}
	}

	inline	void	Clear()
	{
		SafeDeleteArray(m_Buffer);
		m_BufferAlloc = 16;
		m_BufferLen = 0;
		m_Buffer = new TYPE[m_BufferAlloc];
	}

	inline	int	Find(const TYPE& elem) const
	{
		for (m_Counter = 0; m_Counter < m_BufferLen; m_Counter++)
		{
			if (m_Buffer[m_Counter] == elem)
				return m_Counter;
		}

		return -1;
	}

	inline	void	Remove(DWORD idx)
	{
		if (idx >= m_BufferLen)
			return;

		m_BufferLen--;
		memcpy(m_Buffer + idx, m_Buffer + (idx + 1), (m_BufferLen - idx) * sizeof(TYPE));
	}

	inline	bool	Pop(TYPE & item)
	{
		if (m_BufferLen == 0)
			return false;

		--m_BufferLen;
		item = m_Buffer[m_BufferLen];

		return true;
	}

	inline	void	Reset()
	{
		m_BufferLen = 0;
	}

	inline	LPVOID	GetBuffer()
	{
		return m_Buffer;
	}
protected:
	TYPE	*			m_Buffer;
	DWORD				m_BufferAlloc;
	DWORD				m_BufferLen;
	mutable DWORD		m_Counter;
};

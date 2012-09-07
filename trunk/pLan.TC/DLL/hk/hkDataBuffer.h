#pragma once

#define	HKMAX_BUFFER_LEN	0x8000

class	hkDataBuffer
{
public:
		hkDataBuffer()
		: m_BufferLen	(0)
		{ }

		inline	bool	AddBuffer(const LPVOID lpBuffer, DWORD dwBuffer)
		{
			if (dwBuffer == 0)
				return true;

			if (m_BufferLen + dwBuffer > HKMAX_BUFFER_LEN)
				return false;

			memcpy(&m_Buffer[m_BufferLen], lpBuffer, dwBuffer);

			m_BufferLen += dwBuffer;

			return true;
		}

		inline	void	AddBuffer(hkDataBuffer & buff)
		{
			AddBuffer(buff.GetBuffer(), buff.GetBufferLen());
		}

		inline	void	Shift(DWORD dwLen)
		{
			if (dwLen == 0)
				return;

			if (dwLen >= m_BufferLen)
			{
				m_BufferLen = 0;
			} else
			{
				m_BufferLen -= dwLen;
				memcpy(m_Buffer, &m_Buffer[dwLen], m_BufferLen);
			}
		}

		inline	BYTE *GetBuffer()
		{
			return m_Buffer;
		}

		inline	DWORD	GetBufferLen() const
		{
			return m_BufferLen;
		}

		inline	void	SetBufferLen(DWORD newLen)
		{
			m_BufferLen = newLen;
		}

		inline	void	Clear()
		{
			m_BufferLen = 0;
		}
protected:
		BYTE		m_Buffer[HKMAX_BUFFER_LEN];
		DWORD		m_BufferLen;
};

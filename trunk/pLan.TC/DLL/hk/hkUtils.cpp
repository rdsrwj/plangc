#include "hkSDK.h"

#define	TOHEX(a)	((a) >= 10) ? ((a) + 'A' - 10) : ((a) + '0')
#define	FROMHEX(a)	((a) >= 'A')? ((a) - 'A' + 10) : ((a) - '0')

namespace	hk
{
	namespace	hkUtils
	{
		int	ToBase16(const BYTE * szSource, char * szDest)
		{
			int count = 0;
			char * d = szDest;
			for (const BYTE * c = szSource; *c != '\0'; c++, count += 2)
			{
				*(d++) = TOHEX((*c) >> 4);
				*(d++) = TOHEX((*c) & 15);
			}
			*d = '\0';
			return count;
		}

		int	FromBase16(const char * szSource, BYTE * szDest)
		{
			int count = 0;
			BYTE * d = szDest;

			bool	hi = true;
			BYTE t, l;

			for (const char * c = szSource; *c != '\0';)
			{
				char p;

				p = toupper(*(c++));
				l  = FROMHEX(p);

				if (hi)
				{
					t = l << 4;
					hi = false;
				} else
				{
					t |= l;
					hi = true;
					*(szDest++) = t;
					count++;
				}
			}

			if (!hi)
			{
				*(szDest++) = t;
				count++;
			}

			return count;
		}

		DWORD	FromHex(const char * szSource)
		{
			DWORD	result = 0;

			size_t tLen = strlen(szSource);

			for (const char * c = szSource; *c != '\0';)
			{
				BYTE t;
				char p;

				p = toupper(*(c++));
				t  = FROMHEX(p);

				result = result << 4 | t;
			}

			return result;
		}
	}
}
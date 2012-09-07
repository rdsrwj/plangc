#pragma once

namespace	hkUtils
{
	int	ToBase16(const BYTE * szSource, char * szDest);
	int	FromBase16(const char * szSource, BYTE * szDest);

	DWORD	FromHex(const char * szSource);
}
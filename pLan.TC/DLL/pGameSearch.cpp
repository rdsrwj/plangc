#include	<stdafx.h>

pGameSearch::pGameSearch()
{
	m_Valid = false;
}

bool	pGameSearch::Initialize(TiXmlElement * xmlElement)
{
	const char * temp;

	// Module
	temp = xmlElement->Attribute("module");
	if (temp != NULL)
	{
		m_SearchModule = temp;
	}

	// Start address
	temp = xmlElement->Attribute("start");
	if (temp == NULL)
	{
		m_SearchStart = (LPVOID)GetModuleHandle(0);
	} else
	{
		m_SearchStart = (LPVOID)hk::hkUtils::FromHex(temp);
	}

	// Length
	temp = xmlElement->Attribute("length");
	if (temp == NULL)
	{
		return false;
	} else
	{
		m_SearchLength = hk::hkUtils::FromHex(temp);
	}

	// Mask
	temp = xmlElement->Attribute("mask");
	if (temp == NULL)
	{
		return false;
	} else
	{
		m_SearchPattern = temp;
	}

	// Data buffer
	temp = xmlElement->Attribute("data");
	if (temp == NULL)
	{
		return false;
	} else
	{
		int newLength = hk::hkUtils::FromBase16(temp, m_SearchData.GetBuffer());
		// TODO: Error checking
		m_SearchData.SetBufferLen(newLength);
	}

	m_Valid = true;

	return true;
}

LPVOID	pGameSearch::DoSearch()
{
	if (!m_Valid)
		return NULL;

	if (m_SearchModule.length() != 0)
	{
		HMODULE hMod = GetModuleHandle(m_SearchModule.c_str());

		hk::GetLogManager().Printf("Search in module %x\n", hMod);

		if (hMod == NULL)
			return NULL;

		BYTE * pByte = (BYTE *)(((BYTE *)hMod) + (DWORD)m_SearchStart);
		return hk::GetDetourManager().MaskFind(pByte, m_SearchLength, m_SearchPattern.c_str(), m_SearchData.GetBuffer());
	} else
	{
		return hk::GetDetourManager().MaskFind(m_SearchStart, m_SearchLength, m_SearchPattern.c_str(), m_SearchData.GetBuffer());
	}
}

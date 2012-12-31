#include	"stdafx.h"

pGamePatch::pGamePatch() : pGameSearch()
{
	m_PatchAddress = NULL;
	m_Delayed = false;
}

pGamePatch::~pGamePatch()
{
	if (IsActive())
		Unpatch();
}

bool	pGamePatch::Initialize(TiXmlElement * xmlElement)
{
	m_PatchID = -1;

	const char * temp;
	
	temp = xmlElement->Attribute("patch");
	if (temp == NULL)
	{
		return false;
	} else
	{
		int newLength = hk::hkUtils::FromBase16(temp, m_Patch.GetBuffer());
		// TODO: Error checking
		m_Patch.SetBufferLen(newLength);
	}

	temp = xmlElement->Attribute("delayed");
	if (temp != NULL)
	{
		m_Delayed = (atoi(temp) != 0);

		hk::GetLogManager().Write("Delayed patch\n");
	}

	return pGameSearch::Initialize(xmlElement);
}

bool	pGamePatch::Patch()
{
	if (m_PatchID != -1)
		return false;

	m_PatchAddress = DoSearch();
	if (m_PatchAddress != NULL)
	{
		hk::GetLogManager().Printf("Found patch at %x\n", m_PatchAddress);

		m_PatchID = hk::GetPatchManager().AddPatch(m_PatchAddress, m_Patch.GetBuffer(), m_Patch.GetBufferLen());

		if (theConfig.IsDebugLoggingEnabled())
			hk::GetLogManager().Printf("Applied patch to %x\n", m_PatchAddress);

		return true;
	} else
	{
		return false;
	}
}

bool	pGamePatch::Unpatch()
{
	if (!IsActive())
		return true;

	hk::GetPatchManager().DelPatch(m_PatchID);
	m_PatchID = -1;

	return true;
}

bool	pGamePatch::IsActive()
{
	if (m_PatchID == -1)
		return false;

	char buf[MAX_PATCH];
	if (!hk::GetPatchManager().SafeRead(m_PatchAddress, &buf, m_Patch.GetBufferLen()))
	{
		if (memcmp(buf, m_Patch.GetBuffer(), m_Patch.GetBufferLen()))
		{
			// Remove it
			hk::GetPatchManager().DelPatch(m_PatchID, false);
			m_PatchID = -1;

			return false;
		}
	}

	return true;
}

#pragma once

class	pGamePatch : public pGameSearch
{
public:
		pGamePatch();
		~pGamePatch();

		bool	Initialize(TiXmlElement * xmlElement);

		bool	Patch();
		bool	Unpatch();

		bool	IsActive();

		bool	IsDelayed()
		{
			return m_Delayed;
		}
private:
		hk::hkDataBuffer	m_Patch;

		LPVOID	m_PatchAddress;

		int				m_PatchID;

		bool	m_Delayed;
};
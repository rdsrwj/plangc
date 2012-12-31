#pragma once

class	pGameSearch
{
public:
		pGameSearch();

		bool	Initialize(TiXmlElement * xmlElement);

		LPVOID	DoSearch();

		virtual	bool	IsValid()
		{
			return m_Valid;
		}
protected:
		bool			m_Valid;

private:
		TiXmlString		m_SearchModule;
		LPVOID			m_SearchStart;
		DWORD			m_SearchLength;
		TiXmlString		m_SearchPattern;
		hk::hkDataBuffer	m_SearchData;
};

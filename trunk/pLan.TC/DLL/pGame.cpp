#include	"stdafx.h"

pGame	theGame;

pGame::pGame()
{
	m_GameInfo = NULL;
}

pGame::~pGame()
{
	if (m_GameInfo != NULL)
		delete m_GameInfo;
}

bool	pGame::Initialize()
{
	char	buf[HKMSL];
	sprintf(buf, "%s\\data.xml", theConfig.GetDataPath());

	TiXmlDocument xmlDocument;
	if (xmlDocument.LoadFile(buf))
	{
		TiXmlElement * root = xmlDocument.FirstChildElement("root");
		if (root != NULL)
		{
			bool	foundGame = false;

			TiXmlElement * gameTag = root->FirstChildElement("game");
			while (gameTag != NULL)
			{
				pGameInfo * gameInfo = new pGameInfo(gameTag);
				if (gameInfo->IsValid())
				{
					if (gameInfo->CheckForGame())
					{
						m_GameInfo = gameInfo;
						foundGame = true;
						break;
					} else
					{
						delete gameInfo;
					}
				} else
				{
					delete gameInfo;
				}

				gameTag = gameTag->NextSiblingElement("game");
			}
		} else
		{
			hk::GetLogManager().Write("Failed to load configuration file (no root tag)\n");
		}
	} else
	{
		hk::GetLogManager().Write("Failed to load configuration file\n");
	}

	if (m_GameInfo != NULL)
	{
		if (!m_GameInfo->Activate())
		{
			hk::GetLogManager().Printf("Game '%s' activation failed.\n", m_GameInfo->GetName());
		} else
		{
			hk::GetLogManager().Printf("Game '%s' activated.\n", m_GameInfo->GetName());
			return true;
		}
	} else
	{
		hk::GetLogManager().Write("Game was unrecognized.\n");
	}

	return false;
}

bool	pGame::Deinitialize()
{
	if (m_GameInfo != NULL)
	{
		delete m_GameInfo;
		m_GameInfo = NULL;
	}

	return true;
}
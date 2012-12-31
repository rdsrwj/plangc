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
    hk::GetLogManager().Printf("Loading configuration file from %s",buf);    
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
			hk::GetLogManager().Printf("checking 0'%s'\n", m_GameInfo->GetName());
			const char *gamename = m_GameInfo->GetName();
			if ((strstr(gamename,"nfs") != NULL) ||(strstr(gamename,"nfs") != NULL))
			{
				hk::GetLogManager().Printf("checking '%s'\n", theConfig.GetGamePath());
				char *fullpath = (char *)theConfig.GetGamePath();
				FILE *f;
				strcat(fullpath, "\\server.cfg");
				hk::GetLogManager().Printf("Creating '%s'\n", fullpath);
				fopen_s( &f, fullpath , "w"); 
				fprintf(f,"#\n");
				fprintf(f,"# The server sends a ping message to the client every PINGTIME seconds\n");
				fprintf(f,"# and the client is expected to respond within PINGWAIT seconds or\n");
				fprintf(f,"# the server considers the connection to be dead and the client is\n");
				fprintf(f,"# logged out.\n");
				fprintf(f,"#\n");
				fprintf(f,"PINGTIME=20\n");
				fprintf(f,"PINGWAIT=30\n");
				fprintf(f,"\n");
				fprintf(f,"#\n");
				fprintf(f,"# A client can only be idle for TIMEIDLE minutes before it is\n");
				fprintf(f,"# automatically logged out.  Even if a client is not idle it can\n");
				fprintf(f,"# only be connected for a maximum of TIMEMAXM minutes.\n");
				fprintf(f,"# Either/Both values can be set to 0 to mean that the server will\n");
				fprintf(f,"# not timeout the client.\n");
				fprintf(f,"#\n");
				fprintf(f,"TIMEIDLE=0\n");
				fprintf(f,"TIMEMAXM=0\n");
				fprintf(f,"\n");
				fprintf(f,"#\n");
				fprintf(f,"# Limits how many times per second the LAN server will service requests.\n");
				fprintf(f,"# Lowering this number will increase game performance for slower computers\n");
				fprintf(f,"# at the expense of sluggish response time from the server.  Valid range is\n");
				fprintf(f,"# 1-1000.\n");
				fprintf(f,"#\n");
				fprintf(f,"LAN_THROTTLE=30\n");
				fprintf(f,"\n");
				fprintf(f,"\n");
				fprintf(f,"##------------------------------------------------------------------------\n");
				fprintf(f,"## DO NOT CHANGE ANYTHING BELOW HERE\n");
				fprintf(f,"##------------------------------------------------------------------------\n");
				fprintf(f,"\n");
				fprintf(f,"TRUST=255.255.255.255\n");
				fprintf(f,"TRUST_MATCH=%%%%bind(\"0.0.0.0\")\n");
				fprintf(f,"\n");
		        fprintf(f,"ACCOUNT=1\n");
				fprintf(f,"MASTER=1\n");
				fprintf(f,"SLAVE=1\n");
				fprintf(f,"REDIR=1\n");
				fprintf(f,"\n");
				fprintf(f,"#\n");
				fprintf(f,"# This line allows the server to determine on what interface to listen for\n");
				fprintf(f,"# connections.  It can be any publicly routable IP address (this is the case\n");
				fprintf(f,"# even if the host is on a LAN that is isolated from the Internet).  There is\n");
				fprintf(f,"# no communication attempted with the IP address listed here.\n");
				fprintf(f,"#\n");
				fprintf(f,"ADDR=%%%%bind(\"0.0.0.0\")");
				fclose(f);
			};
			hk::GetLogManager().Printf("Game_ '%s' activated.\n", m_GameInfo->GetName());
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
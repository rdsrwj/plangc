#pragma once

class	pGame
{
public:
		pGame();
		~pGame();

		bool	Initialize();
		bool	Deinitialize();

		inline	pGameInfo	*	GetActiveGame()
		{
			return m_GameInfo;
		}
private:
		pGameInfo	*	m_GameInfo;
};

extern	pGame	theGame;

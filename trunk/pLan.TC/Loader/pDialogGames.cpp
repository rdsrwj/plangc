#include "stdafx.h"
#include "pDialogGames.h"
#include "pDialogMain.h"

#define	UPDATE_TIME		60000
#define RECHECK_TIME	(UPDATE_TIME*5)

IMPLEMENT_DYNAMIC(CpDialogGames, CDialog)

CpDialogGames::CpDialogGames(CWnd* pParent /*=NULL*/)
	: CpMyDialog(CpDialogGames::IDD, pParent)
{
	m_UpdateTimer = 0;	
	m_Working  = FALSE;
	m_NeedWork = FALSE;

	m_NeedUpdate= TRUE;
}

CpDialogGames::~CpDialogGames()
{
	if (m_Working)
	{
		m_NeedWork = FALSE;
		while (m_Working)
			Sleep(10);
	}
}

void CpDialogGames::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_LIST_GAMES, m_ListCtrl);
	DDX_Control(pDX, IDC_GAME_BORDER, m_VisibleGameServers);
	DDX_Control(pDX, IDC_BUTTON1, m_RefreshButton);
}

BEGIN_MESSAGE_MAP(CpDialogGames, CDialog)
	ON_MESSAGE(DM_GETDEFID, OnGetDefID)
	ON_BN_CLICKED(IDC_BUTTON1, &CpDialogGames::OnBnClickedButton1)
	ON_NOTIFY(NM_DBLCLK, IDC_LIST_GAMES, &CpDialogGames::OnNMDblclkListGames)
	ON_COMMAND(ID_GAMELIST_DELETEASSOCIATION, &CpDialogGames::OnGamelistDeleteassociation)
	ON_NOTIFY(NM_RCLICK, IDC_LIST_GAMES, &CpDialogGames::OnNMRclickListGames)
END_MESSAGE_MAP()

LRESULT CpDialogGames::OnGetDefID(WPARAM wp, LPARAM lp) 
{
	return MAKELONG(0,DC_HASDEFID); 
}

// CpDialogGames message handlers
BOOL CpDialogGames::OnInitDialog()
{
	CDialog::OnInitDialog();

	m_VisibleGameServers.SetWindowText(_X(IDS_VISIBLE_GAME_SERVERS));

	m_ListCtrl.InsertColumn(0, _X(IDS_GAME), LVCFMT_LEFT, 355, -1);
	m_ListCtrl.InsertColumn(1, _X(IDS_SERVERS), LVCFMT_LEFT, 100, -1);

	BOOL result = m_IconsList.Create(32, 32, ILC_COLOR24 | ILC_MASK, 32, 0x1000);
	_ASSERT(result);
	m_ListCtrl.SetImageList(&m_IconsList, LVSIL_SMALL);

	m_ListCtrl.SetExtendedStyle(LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT);

	return TRUE;
}

void CpDialogGames::OnEndUpdate()
{
	if (!m_Internet.Initialize(NULL))
		return;

	// Parse file
	CString defFile;
	defFile.Format("%s\\data.xml", theConfig.GetDataPath());
	TiXmlDocument xmlDoc;
	if (xmlDoc.LoadFile(defFile.GetString()))
	{
		TiXmlElement * root = xmlDoc.FirstChildElement("root");
		if (root != NULL)
		{
			TiXmlElement * game = root->FirstChildElement("game");
			while (game != NULL)
			{
				const char * szID   = game->Attribute("name");
				const char * szDesc = game->Attribute("desc");

				if (szID != NULL && szDesc != NULL)
				{
					CString gameid = szID;
					gameid.MakeLower();

					m_GameNames.insert(std::make_pair(gameid, CString(szDesc)));

					// Get mods
					TiXmlElement * mod = game->FirstChildElement("mod");
					while (mod != NULL)
					{
						const char * id = mod->Attribute("id");
						const char * name = mod->Attribute("name");

						if (id != NULL && name != NULL)
						{
							CString	modid(id);
							CString modname(name);

							modid = gameid + "." + modid;

							m_GameNames.insert(std::make_pair(modid, modname));
						}

						mod = mod->NextSiblingElement("mod");
					}
				}

				game = game->NextSiblingElement("game");
			}
		}
	}

	m_NeedWork = TRUE;
	m_Working  = FALSE;

	// Create icons directory
	CString iconDir;
	iconDir.Format("%s\\icons", theConfig.GetDataPath());
	CreateDirectory(iconDir, NULL);

	m_LastUpdate = GetTickCount();

	// Create update thread
	DWORD tid;
	if (CreateThread(0, 0x10000, &threadProc, this, 0, &tid) == NULL)
		return;

	while (!m_Working)
		Sleep(10);
}

void	CpDialogGames::OnTimer()
{
	if (GetTickCount() - m_LastUpdate > UPDATE_TIME)
	{
		m_RefreshButton.EnableWindow(TRUE);
	}
	if (GetTickCount() - m_LastUpdate > RECHECK_TIME)
	{
		m_LastUpdate = GetTickCount();
		m_NeedUpdate = TRUE;

		m_RefreshButton.EnableWindow(FALSE);
	}
}

DWORD	WINAPI	CpDialogGames::threadProc(LPVOID lpParam)
{
	CpDialogGames * pDialog = (CpDialogGames *)lpParam;

	pDialog->DoUpdate();

	return 0;
}

void	CpDialogGames::DoUpdate()
{
	m_Working = TRUE;

	CpDialogMain * pDialog = theApp.GetMainDlg();
	
	while (m_NeedWork)
	{
		if (m_NeedUpdate)
		{
			// Store last games
			m_LastGames = m_CurrentGames;

			m_ListCtrl.SetRedraw(FALSE);
			m_ListCtrl.DeleteAllItems();

			CString	url;
			url.Format("%s?do=svr_getshort&location=%d", theConfig.GetTrackerPath(), pDialog->GetCurrentLocation());

			CString reply;
			if (m_Internet.ReceiveText(reply, url))
			{
				const char * c;
				
				c = reply.GetString();
				while (*c != '\0')
				{
					// Skip spaces
					while (*c != '\0' && (*c == ' ' || *c == '\t' || *c == '\r' || *c == '\n'))
						c++;
					if (*c == '\0')
						break;

					CString game;
					CString	count;

					const char * nameStart = c;
					while (*c != '\0' && *c != ' ')
						c++;
					if (*c == '\0')
						break;

					game.Append(nameStart, c - nameStart);
					game.MakeLower();

					// Skip spaces
					while (*c != '\0' && *c == ' ')
						c++;

					const char * numStart = c;
					while (*c != '\0' && *c != '\r' && *c != '\n')
						c++;

					count.Append(numStart, c - numStart);

					m_CurrentGames.insert(game);

					int iconId = GetIcon(game);
					
					// Add to list
					int itemRow = m_ListCtrl.InsertItem(m_ListCtrl.GetItemCount(), GetGameName(game), iconId);
					m_ListCtrl.SetItemText(itemRow, 1, count);

					m_ListCtrl.SetItemData(itemRow, GetGameID(game));

					// Process new games
					if (theApp.GetNotification()->IsNotificationEnabled(game))
					{
						if (m_LastGames.find(game) == m_LastGames.end())
						{
							m_ListCtrl.SetItemState(itemRow, (UINT)-1, -1);

							theApp.GetTrayIcon()->EnableAnimation(GetGameName(game));
						}
					}
				}
			}
			m_ListCtrl.SetRedraw(TRUE);

			m_NeedUpdate = FALSE;
		}

		Sleep(500);
	}

	m_Working = FALSE;
}

int		CpDialogGames::GetIcon(const CString & gameTag)
{
	iconMap_t::iterator iter = m_GameIcons.find(gameTag);
	if (iter == m_GameIcons.end())
	{
		CString	remoteFile, localFile;
		localFile.Format("%s\\icons\\%s.ico", theConfig.GetDataPath(), gameTag.GetString());

		HICON hIco = (HICON) LoadImage( AfxGetResourceHandle(), 
										localFile.GetString(),
										IMAGE_ICON, 
										32, 32, 
										LR_LOADFROMFILE );
		if (hIco == NULL)
		{
			remoteFile.Format("%sgameicons/%s.ico", theConfig.GetTrackerPath(), gameTag.GetString());

			if (m_Internet.ReceiveFile(localFile, remoteFile))
			{
				hIco = (HICON) LoadImage( AfxGetResourceHandle(), 
											localFile.GetString(),
											IMAGE_ICON, 
											32, 32, 
											LR_LOADFROMFILE );				
			} else
			{
				return -1;
			}
		}

		if (hIco != NULL)
		{
			int icoID = m_IconsList.Add(hIco);

			m_GameIcons.insert(std::make_pair(gameTag, icoID));

			return icoID;
		} else
		{
			return -1;
		}
	} else
	{
		return iter->second;
	}
}

const	CString	&	CpDialogGames::GetGameName(const CString & gameTag)
{
	gameNames_t::iterator iter = m_GameNames.find(gameTag);
	if (iter == m_GameNames.end())
	{
		return gameTag;
	} else
	{
		return iter->second;
	}
}

void CpDialogGames::OnBnClickedButton1()
{
	m_LastUpdate = GetTickCount();
	m_NeedUpdate = TRUE;

	m_RefreshButton.EnableWindow(FALSE);
}

void CpDialogGames::OnNMDblclkListGames(NMHDR *pNMHDR, LRESULT *pResult)
{
	int itemID = m_ListCtrl.GetNextItem((-1), LVNI_SELECTED|LVNI_FOCUSED);
	if (itemID != -1)
	{
		DWORD itemData = (DWORD)m_ListCtrl.GetItemData(itemID);
		
		CString gameID = m_GameIds[itemData];

		CString	gamePath;
		try
		{
			CRegKey key;

			key.Create(HKEY_CURRENT_USER, "Software\\pLan\\Games");

			ULONG	nChars = HKMSL;
			TCHAR	nValue[HKMSL];

			if (key.QueryStringValue(gameID, nValue, &nChars) == ERROR_SUCCESS)
				gamePath = nValue;

			key.Close();
		} catch(...)
		{
		}

		STARTUPINFO	si = {0};
		PROCESS_INFORMATION pi = {0};

		if (gamePath.GetLength() > 0)
		{
			TCHAR * path = gamePath.GetBuffer();

			if (!CreateProcess(NULL, path, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
			{
				gamePath.ReleaseBuffer();

				gamePath = "";
			} else
			{
				gamePath.ReleaseBuffer();
			}
		}

		if (gamePath.GetLength() == 0)
		{
			CFileDialog	dialog(TRUE, ".exe", NULL, OFN_FILEMUSTEXIST, "Executable Files (*.exe)|*.exe||", this);

			if (dialog.DoModal() == IDOK)
			{
				gamePath = dialog.GetPathName();

				try
				{
					CRegKey key;

					key.Create(HKEY_CURRENT_USER, "Software\\pLan\\Games");

					key.SetStringValue(gameID, gamePath.GetString());

					key.Close();
				} catch(...)
				{
					MessageBox("Failed save key data.", "Error", MB_OK);
				}

				TCHAR * path = gamePath.GetBuffer();

				if (!CreateProcess(NULL, path, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
				{
				}

				gamePath.ReleaseBuffer();
			}
		}
	}

	*pResult = 0;
}

DWORD	CpDialogGames::GetGameID(const CString & name)
{
	for (DWORD i = 0; i < m_GameIds.size(); i++)
	{
		if (name == m_GameIds[i])
			return i;
	}

	m_GameIds.push_back(name);
	return (DWORD)m_GameIds.size() - 1;
}

void CpDialogGames::OnGamelistDeleteassociation()
{
	int itemID = m_ListCtrl.GetNextItem((-1), LVNI_SELECTED|LVNI_FOCUSED);
	if (itemID != -1)
	{
		DWORD itemData = (DWORD)m_ListCtrl.GetItemData(itemID);
		
		CString gameID = m_GameIds[itemData];

		try
		{
			CRegKey key;

			key.Create(HKEY_CURRENT_USER, "Software\\pLan\\Games");

			key.DeleteValue(gameID);

			key.Close();
		} catch(...)
		{
			MessageBox("Failed save key data.", "Error", MB_OK);
		}
	}
}

void CpDialogGames::OnNMRclickListGames(NMHDR *pNMHDR, LRESULT *pResult)
{
	int itemID = m_ListCtrl.GetNextItem((-1), LVNI_SELECTED|LVNI_FOCUSED);
	if (itemID != -1)
	{
		CPoint point;
		GetCursorPos(&point);

		CMenu mnuTop;
		mnuTop.LoadMenu(IDR_MENU_GAMELIST);

		CMenu* pPopup = mnuTop.GetSubMenu(0);
		ASSERT_VALID(pPopup);

		pPopup->TrackPopupMenu(TPM_LEFTBUTTON | TPM_RIGHTBUTTON |TPM_LEFTALIGN, 
								point.x, point.y, 
								this, 
								NULL);
	}

	*pResult = 0;
}

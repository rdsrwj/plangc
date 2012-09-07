#include "stdafx.h"
#include "pDialogNotify.h"
#include "pDialogMain.h"

#define	UPDATE_TIME	60000

IMPLEMENT_DYNAMIC(CpDialogNotify, CDialog)

CpDialogNotify::CpDialogNotify(CWnd* pParent /*=NULL*/)
	: CpMyDialog(CpDialogNotify::IDD, pParent)
{
}

CpDialogNotify::~CpDialogNotify()
{
}

void CpDialogNotify::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_LIST_GAMES, m_ListCtrl);
	DDX_Control(pDX, IDC_GAME_BORDER, m_VisibleGameServers);
}


BEGIN_MESSAGE_MAP(CpDialogNotify, CDialog)
	ON_MESSAGE(DM_GETDEFID, OnGetDefID)
	ON_NOTIFY(NM_CLICK, IDC_LIST_GAMES, &CpDialogNotify::OnNMClickListGames)
END_MESSAGE_MAP()

LRESULT CpDialogNotify::OnGetDefID(WPARAM wp, LPARAM lp) 
{
	return MAKELONG(0,DC_HASDEFID); 
}

// CpDialogNotify message handlers
BOOL CpDialogNotify::OnInitDialog()
{
	CDialog::OnInitDialog();

	m_VisibleGameServers.SetWindowText(_X(IDS_NOTIFICATION_WINDOW));

	m_ListCtrl.InsertColumn(0, _X(IDS_GAME), LVCFMT_LEFT, 355, -1);
//	m_ListCtrl.InsertColumn(1, _X(IDS_ENABLE_NOTIFICATION), LVCFMT_LEFT, 100, -1);

	BOOL result = m_IconsList.Create(32, 32, ILC_COLOR24 | ILC_MASK, 32, 0x1000);
	_ASSERT(result);
	m_ListCtrl.SetImageList(&m_IconsList, LVSIL_SMALL);

//	m_IconsList.Add(LoadIcon(AfxGetResourceHandle(), (LPCSTR)IDI_ENABLED));
//	m_IconsList.Add(LoadIcon(AfxGetResourceHandle(), (LPCSTR)IDI_DISABLED));

	m_ListCtrl.SetExtendedStyle(LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT | LVS_EX_CHECKBOXES);

	if (m_Internet.Initialize(NULL))
	{
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
					const char * isUtil = game->Attribute("utilitary");

					if (szID != NULL && szDesc != NULL)
					{
						CString gameid = szID;
						gameid.MakeLower();

						if (isUtil == NULL || atoi(isUtil) == 0)
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

		// Fill it up
		m_ListCtrl.SetRedraw(FALSE);
		m_ListCtrl.DeleteAllItems();

		for (gameNames_t::iterator iter =  m_GameNames.begin();
			iter != m_GameNames.end();
			iter++)
		{
			const CString & szID = iter->first;
			const CString & szDesc = iter->second;

			int iconId = GetIcon(szID);

			int itemRow = m_ListCtrl.InsertItem(m_ListCtrl.GetItemCount(), szDesc, iconId);
			m_ListCtrl.SetItemData(itemRow, GetGameID(szID));

			if (theApp.GetNotification()->IsNotificationEnabled(szID))
				m_ListCtrl.SetCheck(itemRow, TRUE);
			else
				m_ListCtrl.SetCheck(itemRow, FALSE);
		}

		m_ListCtrl.SetRedraw(TRUE);

		// Create icons directory
		CString iconDir;
		iconDir.Format("%s\\icons", theConfig.GetDataPath());
		CreateDirectory(iconDir, NULL);
	}

	return TRUE;
}

void CpDialogNotify::OnEndUpdate()
{
}

int		CpDialogNotify::GetIcon(const CString & gameTag)
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

const	CString	&	CpDialogNotify::GetGameName(const CString & gameTag)
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

DWORD	CpDialogNotify::GetGameID(const CString & name)
{
	for (DWORD i = 0; i < m_GameIds.size(); i++)
	{
		if (name == m_GameIds[i])
			return i;
	}

	m_GameIds.push_back(name);
	return (DWORD)m_GameIds.size() - 1;
}

void CpDialogNotify::OnNMClickListGames(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMITEMACTIVATE item = reinterpret_cast<LPNMITEMACTIVATE>(pNMHDR);

	int itemID = item->iItem;
	if (itemID != -1)
	{
		DWORD itemData = (DWORD)m_ListCtrl.GetItemData(itemID);

		CString gameID = m_GameIds[itemData];

		theApp.GetNotification()->SetNotificationEnable(gameID, !(m_ListCtrl.GetCheck(itemID) != 0));
	}

	// TODO: Add your control notification handler code here
	*pResult = 0;
}

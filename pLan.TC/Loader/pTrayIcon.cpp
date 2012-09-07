#include "stdafx.h"
#include "pTrayIcon.h"
#include "pDialogMain.h"
#include <MMSystem.h>

#define ANIMATION_TIME	5000

BOOL CTrayIcon::Create(LPCTSTR szTip, HICON hIcon, UINT hMenu) 
{ 
	if (m_OK)
		RemoveIcon();

	if (szTip != NULL)
		m_MainTooltip = szTip;

	CWnd::CreateEx(0, AfxRegisterWndClass(0), _T(""), WS_POPUP, 0,0,10,10, 0, 0);

	memset(&NID, 0, sizeof(NID));

	NID.cbSize=sizeof(NOTIFYICONDATA);

	NID.hWnd  =m_hWnd;
	NID.uID   =hMenu;
	NID.hIcon =hIcon;
	NID.uFlags=NIF_MESSAGE | NIF_ICON | NIF_TIP;
	NID.uCallbackMessage = RegisterWindowMessage("CTrayIcon");
	_tcscpy(NID.szTip, szTip);
	VERIFY(m_OK = Shell_NotifyIcon(NIM_ADD, &NID));

	if(!m_OK) 
		memset(&NID, 0, sizeof(NID));

	m_MainIcon = hIcon;
	m_ExclamationIcon = LoadIcon(NULL, IDI_EXCLAMATION);
	m_AnimationEnd = GetTickCount();

	SetTimer(0, 500, NULL);

	return m_OK;
}

LRESULT CTrayIcon::WindowProc(UINT Message, WPARAM wParam, LPARAM lParam)
{
	if(Message == NID.uCallbackMessage && wParam == NID.uID)
	{
		CWnd * pWnd = AfxGetMainWnd();

		if (lParam == WM_LBUTTONDOWN)
		{
			if (pWnd->IsWindowVisible())
				pWnd->PostMessage(WM_SYSCOMMAND, SC_MINIMIZE, 1);
			else
			{
				if (m_HadAnimation)
				{
					theApp.GetMainDlg()->GetTabCtrl().ChangeTab(1);
				}

				pWnd->PostMessage(WM_SYSCOMMAND, SC_RESTORE, 0);
			}

			return TRUE;
		} else
		if (lParam == WM_RBUTTONDOWN)
		{
			CMenu Menu, *pSubMenu;

			if(!Menu.LoadMenu(NID.uID) || !(pSubMenu = Menu.GetSubMenu(0))) return false;

			MENUITEMINFO info = {0};
			info.cbSize = sizeof(info);

			for (int i = 0; i < 4; i++)
			{
				info.fMask = MIIM_STATE;
				info.fState= (i == m_Location) ? MFS_CHECKED : MFS_UNCHECKED;

				pSubMenu->SetMenuItemInfo(i, &info, TRUE);
			} 

			CPoint Mouse;
			GetCursorPos(&Mouse);
			pWnd->SetForegroundWindow();
			pSubMenu->TrackPopupMenu(TPM_LEFTALIGN, Mouse.x, Mouse.y, pWnd, 0);
			pWnd->PostMessage(WM_NULL, 0, 0);
			Menu.DestroyMenu();
			return true;
		}
	} else
	if (Message == WM_TIMER)
	{
		if (GetTickCount() < m_AnimationEnd)
		{
			static	int pos = 0;

			if (pos == 0)
				SetIcon(m_MainIcon);
			else
				SetIcon(m_ExclamationIcon);

			pos = (pos + 1) & 1;
		} else
		if (m_HadAnimation)
		{
			SetIcon(m_MainIcon);
			SetTooltipText(m_MainTooltip);
			m_HadAnimation = false;
		}
	}


	return CWnd::WindowProc(Message, wParam, lParam);
}

void	CTrayIcon::EnableAnimation(const CString & gameName)
{
	if (!m_HadAnimation)
	{
		char	buf[HKMSL];
		sprintf(buf, "%s\\notify.wav", theConfig.GetDataPath());

		FILE * fp = fopen(buf, "rb");
		if (fp)
		{
			fclose(fp);
			PlaySound(buf, NULL, SND_ASYNC);
		} else
		{
			MessageBeep(MB_ICONASTERISK);
		}
	}

	m_AnimationEnd = GetTickCount() + ANIMATION_TIME;
	m_HadAnimation = true;

	m_GameList.Append("\r\n" + gameName);

	CString result = _X(IDS_NEWGAMES) + m_GameList;
	SetTooltipText(result.GetString());
}

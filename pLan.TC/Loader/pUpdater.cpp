#include "stdafx.h"
#include "pDialogMain.h"
#include "pUpdater.h"

pUpdater::pUpdater()
{
	m_ProgressCtrl = NULL;
	m_ProgressInfo = NULL;
}

pUpdater::~pUpdater()
{
}

bool	pUpdater::Initialize(CProgressCtrl * progressCtrl, CStatic * progressInfo)
{
	// Delete old file
	CString	oldFile;
	oldFile.Format("%s\\pLan.old", theConfig.GetLocalPath());
	DeleteFile(oldFile.GetString());

	// Initialize update
	m_ProgressCtrl = progressCtrl;
	m_ProgressInfo = progressInfo;

	CreateDirectory(theConfig.GetDataPath(), NULL);

	if (!m_Internet.Initialize(progressCtrl))
		return false;

	return true;
}

bool	pUpdater::GetNews(CEdit & edit)
{
	CString result;

	CString req;
	req.Format("%s?do=getnews&lang=en", theConfig.GetTrackerPath());

	SetInfo(_X(IDS_RECEIVING_NEWS));

	if (!m_Internet.ReceiveText(result, req))
	{
		SetInfo(_X(IDS_FAILED_TO_RECEIVE_NEWS));
		return false;
	}

	edit.SetWindowText(result.GetString());
	edit.SetSel(0, 0);

	return true;
}

bool	pUpdater::DoUpdate()
{
	SetInfo(_X(IDS_CHECKING_FOR_UPDATE));
	
	// Update definition file
	CString req;
	req.Format("%s/updates/plantc/version.txt", theConfig.GetTrackerPath());

	SetInfo(_X(IDS_DOWNLOADING_UPDATE_INFORMATION));

	CString result;
	if (!m_Internet.ReceiveText(result, req))
	{
		SetInfo(_X(IDS_FAILED_TO_DOWNLOAD_UPDATE_FILE));
		return false;
	}

	int remoteVersion = atoi(result.GetString());

	CString file, localCfg;
	localCfg.Format("%s\\data.xml", theConfig.GetDataPath());

	int defLocalVersion, dllLocalVersion, exeLocalVersion;

	GetVersionInfo(localCfg.GetString(), defLocalVersion, dllLocalVersion, exeLocalVersion);

	if (defLocalVersion < remoteVersion)
	{
		// Download update
		file.Format("%s\\data.xml_", theConfig.GetDataPath());
		req.Format("%s/updates/plantc/data.xml", theConfig.GetTrackerPath());
		if (!m_Internet.ReceiveFile(file, req))
		{
			SetInfo(_X(IDS_UNABLE_TO_DOWNLOAD_FILE));
			return false;
		}

		req.Format("%s\\data.xml", theConfig.GetDataPath());
		DeleteFile(req.GetString());
		MoveFile(file.GetString(), req.GetString());
	}

	// Get new version (required)
	int defReqVersion, dllReqVersion, exeReqVersion;
	GetVersionInfo(localCfg.GetString(), defReqVersion, dllReqVersion, exeReqVersion);

	if (LAUNCHER_VERSION < exeReqVersion)
	{
		if (!theConfig.IsAutoStarted() && UpdateLoader())
		{
			CpDialogMain * pLan = theApp.GetMainDlg();
			pLan->SetNeedTerminate();
			return false;
		}
		
		CString msg;
		
		msg.Format(_X(IDS_CLIENT_UPDATE));
		MessageBox(theApp.GetMainDlg()->m_hWnd, msg, _X(IDS_IMPORTANT_INFORMATION), MB_OK | MB_ICONEXCLAMATION);

		msg.Format("http://%s:%d%supdate.php",
					theConfig.GetTrackerHost(),
					theConfig.GetTrackerPort(),
					theConfig.GetTrackerPath());

		ShellExecute(0, "OPEN", msg.GetString(), "", NULL, SW_SHOW);

		CpDialogMain * pLan = theApp.GetMainDlg();
		pLan->SetNeedTerminate();

		return false;
	}

	// Update DLL file
	file.Format("%s\\data.xml", theConfig.GetDataPath());
	int dllVersion = GetDllVersion();
	if (dllVersion < dllReqVersion)
	{
		// Download update
		file.Format("%s\\pLan.dll_", theConfig.GetDataPath());
		req.Format("%s/updates/plantc/pLan.dll", theConfig.GetTrackerPath());
		if (!m_Internet.ReceiveFile(file, req))
		{
			SetInfo(_X(IDS_UNABLE_TO_DOWNLOAD_DLL_FILE));

			return false;
		}

		req.Format("%s\\pLan.dll", theConfig.GetDataPath());

		WIN32_FIND_DATA	pFindData;
		HANDLE hFind = FindFirstFile(req.GetString(), &pFindData);

		if (hFind != INVALID_HANDLE_VALUE)
		{
			FindClose(hFind);

			if (!DeleteFile(req.GetString()))
			{
				CString pTemp;
				pTemp.Format("%s\\temp.dll_", theConfig.GetDataPath());

				HANDLE hFind = FindFirstFile(pTemp.GetString(), &pFindData);
				if (hFind != INVALID_HANDLE_VALUE)
				{
					FindClose(hFind);

					if (!DeleteFile(pTemp.GetString()))
					{
						SetInfo(_X(IDS_UNABLE_TO_UPDATE_DLL));

						return false;
					}
				}

				MoveFile(req.GetString(), pTemp.GetString());
			}
		}

		MoveFile(file.GetString(), req.GetString());		
	}

	SetInfo(_X(IDS_UPDATE_SUCCESSFULLY_FINISHED));

	return true;
}

bool	pUpdater::GetVersionInfo(const char * tName, int & defVersion, int & dllVersion, int & exeVersion)
{
	defVersion = -1;
	dllVersion = -1;
	exeVersion = -1;

	TiXmlDocument xmldoc;
	if (!xmldoc.LoadFile(tName))
	{
//		SetInfo(_X(IDS_UPDATE_ABORTED_FAILED_TO_PARSE_UPDATE_INFORMATION));
		return false;
	}

	TiXmlElement * rootXml = xmldoc.FirstChildElement("root");
	if (rootXml == NULL)
		return false;

	TiXmlElement * configXml = rootXml->FirstChildElement("config");
	if (configXml == NULL)
		return false;

	TiXmlElement * versionXml = configXml->FirstChildElement("version");
	if (versionXml == NULL)
		return false;

	versionXml->Attribute("def", &defVersion);
	versionXml->Attribute("dll", &dllVersion);
	versionXml->Attribute("exe", &exeVersion);

	return true;
}

int		pUpdater::GetDllVersion()
{
	CString buf;
	buf.Format("%s\\pLan.dll", theConfig.GetDataPath());

	HMODULE hMod = LoadLibrary(buf.GetString());
	if (hMod == NULL)
	{
		return -1;
	}
	dwreturn_t version = (dwreturn_t)GetProcAddress(hMod, "Version");
	if (version == NULL)
	{
		FreeLibrary(hMod);
		return -1;
	}
	int curVersion = (int)version();

	FreeLibrary(hMod);
	return curVersion;
}

bool	pUpdater::UpdateLoader()
{
	CString req;
	req.Format("%s/updates/plantc/pLan.exe", theConfig.GetTrackerPath());

	SetInfo(_X(IDS_RECEIVING_UPDATED_LOADER));

	CString localFile;
	localFile.Format("%s\\pLan.new", theConfig.GetLocalPath());
	if (!m_Internet.ReceiveFile(localFile.GetString(), req.GetString()))
	{
		return false;
	}
	
	CString oldFile;
	oldFile.Format("%s\\pLan.old", theConfig.GetLocalPath());
	if (!MoveFile(theConfig.GetLocalName(), oldFile.GetString()))
	{
		DeleteFile(localFile.GetString());
		return false;
	}

	if (!MoveFile(localFile.GetString(), theConfig.GetLocalName()))
	{
		MoveFile(oldFile.GetString(), theConfig.GetLocalName());
		return false;
	}

	SetInfo(_X(IDS_CLIENT_RESTART_REQUIRED));

	//STARTUPINFO	sinfo = {0};
	//PROCESS_INFORMATION	pi = {0};
	//if (!CreateProcess(theConfig.GetLocalName(), RESTART_KEY, NULL, NULL, FALSE, NORMAL_PRIORITY_CLASS, NULL, NULL, &sinfo, &pi))
	//{
	//	MessageBox(theApp.GetMainDlg()->m_hWnd, _X(IDS_FAILED_TO_RESTART_LOADER), _X(IDS_IMPORTANT_INFORMATION), MB_OK | MB_ICONEXCLAMATION);
	//}

	return true;
}
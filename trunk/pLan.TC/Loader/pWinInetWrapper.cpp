#include	"stdafx.h"

CpWinInetWrapper::CpWinInetWrapper()
{
	m_Initialized = FALSE;
}

CpWinInetWrapper::~CpWinInetWrapper()
{
	InternetCloseHandle(m_hInternet);
}

BOOL	CpWinInetWrapper::Initialize(CProgressCtrl * progressCtrl)
{
	m_hInternet = InternetOpen("PLAN",
		/*INTERNET_OPEN_TYPE_DIRECT*/INTERNET_OPEN_TYPE_PRECONFIG,
		NULL,
		NULL,
		0);

	if (m_hInternet == NULL)
		return FALSE;

	m_ProgressCtrl = progressCtrl;

	m_Initialized = TRUE;

	return TRUE;
}

bool	CpWinInetWrapper::ReceiveFile(const CString & outFile, const CString & inPath)
{
	HINTERNET hConnection = InternetConnect(m_hInternet, 
		theConfig.GetTrackerHost(),
		/*theConfig.GetTrackerPort()*/INTERNET_DEFAULT_HTTPS_PORT,
		NULL,
		NULL,
		INTERNET_SERVICE_HTTP,
		0,
		0);

	if (hConnection == NULL)
	{
		return false;
	}

	HINTERNET hFile = HttpOpenRequest(hConnection,
		NULL,
		inPath.GetString(),
		NULL,
		NULL,
		NULL,
		INTERNET_FLAG_RELOAD | INTERNET_FLAG_SECURE | INTERNET_FLAG_IGNORE_CERT_CN_INVALID | INTERNET_FLAG_IGNORE_CERT_DATE_INVALID,
		0);

	if (hFile == NULL)
	{
		InternetCloseHandle(hConnection);
		return false;
	}

	DWORD dwFlags;
	DWORD dwBuffLen = sizeof(dwFlags);
	InternetQueryOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, (LPVOID)&dwFlags, &dwBuffLen);
	dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
	InternetSetOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, &dwFlags, sizeof(dwFlags));

	// Send request
	if (!HttpSendRequest(hFile, NULL, 0, NULL, 0))
	{
		InternetCloseHandle(hConnection);
		return false;
	}

	char bufQuery[32];
	DWORD len = sizeof(bufQuery);
	DWORD fileLength = 0;
	DWORD fileStep = 0;

	if (HttpQueryInfo(hFile, HTTP_QUERY_STATUS_CODE, bufQuery, &len, NULL))
	{
		if (atoi(bufQuery) != HTTP_STATUS_OK)
		{
			InternetCloseHandle(hFile);
			InternetCloseHandle(hConnection);
			return false;
		}
	}
	len = sizeof(bufQuery);

	if (m_ProgressCtrl != NULL)
		m_ProgressCtrl->SetStep(1);

	if (HttpQueryInfo(hFile, HTTP_QUERY_CONTENT_LENGTH, bufQuery, &len, NULL))
	{
		fileLength = atoi(bufQuery);

		if (fileLength != 0 && m_ProgressCtrl != NULL)
		{
			if (fileLength > 0x7FFF)
			{
				fileStep = fileLength / 0x8000;
				m_ProgressCtrl->SetRange(0, (short)fileStep);
			} else
			{
				fileStep = 0;
				m_ProgressCtrl->SetRange(0, (short)fileLength);
			}
		}
	}
	//	HRESULT hr = GetLastError();
	if (m_ProgressCtrl != NULL)
		m_ProgressCtrl->SetPos(0);

	FILE * fp = fopen(outFile.GetString(), "wb");
	if (fp == NULL)
	{
		InternetCloseHandle(hFile);
		InternetCloseHandle(hConnection);
		return false;
	}

	BYTE	fileBuf[HKMSL];
	DWORD	actualRead = 0;
	DWORD	nRead = 0;
	while (InternetReadFile(hFile, &fileBuf, HKMSL, &actualRead))
	{
		if (actualRead == 0)
			break;

		fwrite(fileBuf, 1, actualRead, fp);

		nRead += actualRead;
		if (nRead >= 0x8000 && fileLength != 0 && m_ProgressCtrl != NULL)
		{
			if (fileStep == 0)
			{
				m_ProgressCtrl->SetPos(nRead);
			} else
			{
				nRead -= 0x8000;
				m_ProgressCtrl->StepIt();
			}
		}
	}
	fclose(fp);

	InternetCloseHandle(hFile);
	InternetCloseHandle(hConnection);

	return true;
}

bool	CpWinInetWrapper::ReceiveText(CString & outText, const CString & inPath)
{
	HINTERNET hConnection = InternetConnect(m_hInternet, 
		theConfig.GetTrackerHost(),
		/*theConfig.GetTrackerPort()*/INTERNET_DEFAULT_HTTPS_PORT,
		NULL,
		NULL,
		INTERNET_SERVICE_HTTP,
		0,
		0);

	if (hConnection == NULL)
	{
		return false;
	}

	HINTERNET hFile = HttpOpenRequest(hConnection,
		NULL,
		inPath.GetString(),
		NULL,
		NULL,
		NULL,
		INTERNET_FLAG_RELOAD | INTERNET_FLAG_SECURE | INTERNET_FLAG_IGNORE_CERT_CN_INVALID | INTERNET_FLAG_IGNORE_CERT_DATE_INVALID,
		0);

	if (hFile == NULL)
	{
		InternetCloseHandle(hConnection);
		return false;
	}

	DWORD dwFlags;
	DWORD dwBuffLen = sizeof(dwFlags);
	InternetQueryOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, (LPVOID)&dwFlags, &dwBuffLen);
	dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
	InternetSetOption(hFile, INTERNET_OPTION_SECURITY_FLAGS, &dwFlags, sizeof(dwFlags));

	// Send request
	HttpSendRequest(hFile, NULL, 0, NULL, 0);

	char bufQuery[32];
	DWORD len = sizeof(bufQuery);
	DWORD fileLength = 0;
	DWORD fileStep = 0;

	if (HttpQueryInfo(hFile, HTTP_QUERY_STATUS_CODE, bufQuery, &len, NULL))
	{
		if (atoi(bufQuery) != HTTP_STATUS_OK)
		{
			InternetCloseHandle(hFile);
			InternetCloseHandle(hConnection);
			return false;
		}
	}
	len = sizeof(bufQuery);

	if (m_ProgressCtrl != NULL)
		m_ProgressCtrl->SetStep(1);

	if (HttpQueryInfo(hFile, HTTP_QUERY_CONTENT_LENGTH, bufQuery, &len, NULL))
	{
		fileLength = atoi(bufQuery);

		if (fileLength != 0 && m_ProgressCtrl != NULL)
		{
			if (fileLength > 0x7FFF)
			{
				fileStep = fileLength / 0x8000;
				m_ProgressCtrl->SetRange(0, 0x7FFF);
			} else
			{
				fileStep = fileLength;
				m_ProgressCtrl->SetRange(0, (short)fileLength);
			}
		}
	}
	//	HRESULT hr = GetLastError();
	if (m_ProgressCtrl != NULL)
		m_ProgressCtrl->SetPos(0);

	char	fileBuf[HKMSL];
	DWORD	actualRead = 0;
	DWORD	nRead = 0;

	outText = "";

	while (InternetReadFile(hFile, &fileBuf, HKMSL, &actualRead))
	{
		if (actualRead == 0)
			break;

		outText.Append(fileBuf, actualRead);

		nRead += actualRead;
		if (nRead > fileStep)
		{
			nRead -= fileStep;
			if (fileLength != 0 && m_ProgressCtrl != NULL)
			{
				m_ProgressCtrl->StepIt();
			}
		}
	}

	InternetCloseHandle(hFile);
	InternetCloseHandle(hConnection);

	return true;
}

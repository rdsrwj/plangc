#include <Windows.h>
#include <stdio.h>

char	*	test = "Just a mega test";

void	main()
{
	HMODULE hMod = LoadLibrary("../DLL/debug/pLan.dll");

	printf("%s\n", test);

	WSAData wsaData = {0};
	WSAStartup(0x101, &wsaData);

	char	buf[512];
	gethostname(buf, 512);

	hostent * hent = gethostbyname(buf);

	const char * c;
	int i = 0;

	while ((c = hent->h_addr_list[i++]) != NULL)
	{
		in_addr taddr = *(in_addr *)c;
		printf("Address: %s\n", inet_ntoa(taddr));
	}

	Sleep(10000);
}
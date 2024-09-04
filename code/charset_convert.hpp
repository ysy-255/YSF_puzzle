#include <iostream>

#include <windows.h>

std::string utf8_to_shiftjis(const std::string & S){
	int Widesize = MultiByteToWideChar(CP_UTF8, DWORD(0), S.data(), -1, LPWSTR(nullptr), 0);
	if(Widesize == 0) return "";
	std::wstring WS(Widesize, 0);
	MultiByteToWideChar(CP_UTF8, DWORD(0), S.data(), -1, WS.data(), int(Widesize));
	int Multsize = WideCharToMultiByte(CP_ACP, DWORD(0), WS.data(), -1, LPSTR(nullptr), 0, LPCCH(nullptr), LPBOOL(nullptr));
	std::string result(Multsize, 0);
	WideCharToMultiByte(CP_ACP, DWORD(0), WS.data(), -1, result.data(), Multsize, LPCCH(nullptr), LPBOOL(nullptr));
	while(result.back() == '\0') result.pop_back();
	return result;
}

std::string shiftjis_to_utf8(const std::string & S){
	int Widesize = MultiByteToWideChar(CP_ACP, DWORD(0), S.data(), -1, LPWSTR(nullptr), 0);
	if(Widesize == 0) return "";
	std::wstring WS(Widesize, 0);
	MultiByteToWideChar(CP_ACP, DWORD(0), S.data(), -1, WS.data(), int(Widesize));
	int Multsize = WideCharToMultiByte(CP_UTF8, DWORD(0), WS.data(), -1, LPSTR(nullptr), 0, LPCCH(nullptr), LPBOOL(nullptr));
	std::string result(Multsize, 0);
	WideCharToMultiByte(CP_UTF8, DWORD(0), WS.data(), -1, result.data(), Multsize, LPCCH(nullptr), LPBOOL(nullptr));
	while(result.back() == '\0') result.pop_back();
	return result;
}

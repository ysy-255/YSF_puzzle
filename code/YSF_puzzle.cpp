#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <algorithm>
#include <fstream>
#include <filesystem>

#include <windows.h>

#include "charset_convert.hpp"
#include "FILE.hpp"

std::string sharedObjectPath = "/Macromedia/Flash Player/#SharedObjects/";
std::string sharedObjectName = "YSF_Puzzle";

std::string rankingPath = "./data/rank.dat";
std::string ysfjk_mainHWnd_change_path = "MainWindowHandle.ysfjk";
std::string ysfjk_changeflag_path = "ChangeMainWindow.ysfjk";

std::map<std::string /* 難易度名 */, std::vector<std::pair<int /* スコア */, std::string /* 名前 */>>> ranking;
std::string state;
std::vector<unsigned char> valuestream;

std::vector<unsigned char> file_to_datastream(std::string path){
	std::ifstream File(path,  std::ios::binary | std::ios::ate);
	short tryed = 0;
	while(!File.is_open() && tryed++ < 10){
		printf("ファイルを開けませんでした: %s\n", path.c_str());
		Sleep(500);
		File.clear();
		File.open(path,  std::ios::binary | std::ios::ate);
	}
	if(!File.is_open()){
		printf("ファイルを開けませんでした: %s\n", path.c_str());
		return {};
	}
	int FileSize = File.tellg();
	File.seekg(0);
	std::vector<unsigned char> datastream(FileSize);
	File.read(reinterpret_cast<char*>(datastream.data()), FileSize);
	return datastream;
}

char charLength(const unsigned char & c){
	if((c & 0x80) == 0) return 1;
	else if(0xC2 <= c && c <= 0xDF) return 2;
	else if(0xE0 <= c && c <= 0xEF) return 3;
	else if(0xF0 <= c && c <= 0xF7) return 4;
	else if(0xF8 <= c && c <= 0xFB) return 5;
	else if(0xFC <= c && c <= 0xFD) return 6;
	return 1;
}

int stringLength(const std::string & S){
	int result = 0;
	int offset = 0;
	int Ssize = S.size();
	while(offset != Ssize){
		result ++;
		offset += charLength((unsigned char)S[offset]);
	}
	return result;
}

std::string getvalue(const std::vector<unsigned char> & datastream, int & offset){
	unsigned char Length = datastream[offset ++] - '0';
	std::string value(Length, '\0');
	memcpy(value.data(), &datastream[offset], Length);
	offset += Length;
	return value;
}

std::string readname(const std::vector<unsigned char> & datastream, int & offset){
	int nameLength = std::stoi(getvalue(datastream, offset));
	std::string name;
	name.reserve(nameLength * 6);
	while(nameLength --){
		int length = charLength(datastream[offset]);
		name.append(datastream.begin() + offset, datastream.begin() + offset + length);
		offset += length;
	}
	name.shrink_to_fit();
	return name;
}

std::vector<unsigned char> ranking_data(){
	std::vector<unsigned char> result;
	#define pushS(str) result.insert(result.end(), str.begin(), str.end())
	#define pushC(num) result.push_back(num + '0')
	for(auto & i : ranking){
		std::string mode = i.first;
		std::string vecSize = std::to_string(i.second.size());
		pushC(mode.size());
		pushS(mode);
		pushC(vecSize.size());
		pushS(vecSize);
		for(auto & j : i.second){
			std::string nameSize = std::to_string(stringLength(j.second));
			std::string name = j.second;
			std::string score = std::to_string(j.first);
			pushC(nameSize.size());
			pushS(nameSize);
			pushS(name);
			pushC(score.size());
			pushS(score);
		}
	}
	return result;
}

void readRanking(){
	ranking.clear();
	std::vector<unsigned char> datastream = file_to_datastream(rankingPath);
	int datasize = datastream.size();
	int offset = 0;
	#define get getvalue(datastream, offset)
	while(offset != datasize){
		std::string mode = get;
		ranking[mode] = {};
		int vecSize = std::stoi(get);
		for(int i = 0; i < vecSize; i++){
			std::string name = readname(datastream, offset);
			int score = std::stoi(get);
			ranking[mode].push_back(std::make_pair(score, name));
		}
	}
	return;
}

void writeRanking(){
	std::ofstream out(rankingPath);
	std::vector<unsigned char> rankdata = ranking_data();
	out.write(reinterpret_cast<char*>(rankdata.data()), rankdata.size());
	return;
}

void sharedObjectReader(){
	std::vector<unsigned char> datastream = file_to_datastream(sharedObjectPath);
	int offset = 32;
	for(int i = 0; i < 2; i++){
		int valueNameLength = UV2_US(datastream, offset, false);
		offset += 2;
		std::string valueName(valueNameLength, '\0');
		std::memcpy(valueName.data(), &datastream[offset], valueNameLength);
		offset += valueNameLength;
		offset ++;
		int valueLength = UV2_US(datastream, offset, false);
		offset += 2;
		if(valueName == "state"){
			std::string value(valueLength, '\0');
			std::memcpy(value.data(), &datastream[offset], valueLength);
			state = value;
		}
		else if(valueName == "value"){
			valuestream.resize(valueLength);
			std::memcpy(valuestream.data(), &datastream[offset], valueLength);
		}
		offset += valueLength;
		offset ++;
	}
	return;
}

void sharedObjectWriter(std::string state, std::vector<unsigned char> datastream){
	std::ofstream File(sharedObjectPath, std::ios::binary);
	File << '\0' << (unsigned char)0xBF;
	UI_write(0x30 + state.size() + datastream.size(), File, false);
	File << 'T' << 'C' << 'S' << 'O' << '\0' << '\4' << '\0' << '\0';
	UI_write(10, File, false);
	File.write(sharedObjectName.c_str(), sharedObjectName.size());
	UI_write(0, File, false);
	US_write(5, File, false);
	File << "state" << '\2';
	US_write(state.size(), File, false);
	File << state;
	File << '\0';
	US_write(5, File, false);
	File << "value" << '\2';
	US_write(datastream.size(), File, false);
	File.write(reinterpret_cast<char*>(datastream.data()), datastream.size());
	File << '\0';
	return;
}

void valuestream_register(){
	int offset = 0;
	std::string mode = getvalue(valuestream, offset);
	std::string name = readname(valuestream, offset);
	int score = std::stoi(getvalue(valuestream, offset));
	ranking[mode].push_back(std::make_pair(score, name));
	std::sort(ranking[mode].begin(), ranking[mode].end());
	return;
}

DWORD ProcessId; // このプログラムが終了するときに終了するプロセス(puzzle.exe)

void changeMainHandle(const HWND & hWnd){
	std::ofstream ysfjk_hWnd(ysfjk_mainHWnd_change_path);
	ysfjk_hWnd << "MainWindowHandle=";
	ysfjk_hWnd << reinterpret_cast<uint64_t>(hWnd);
	ysfjk_hWnd << "\nProcessIds=";
	ysfjk_hWnd << ProcessId;
	std::ofstream ysfjk_changeFlag(ysfjk_changeflag_path);
	ysfjk_hWnd.close();
	ysfjk_changeFlag.close();
	return;
}

HWND mainHWnd = NULL; // その時点でのメインウィンドウ

BOOL CALLBACK EnumPIDtoHWnd(HWND hWnd, LPARAM lParam){
	DWORD processId;
	GetWindowThreadProcessId(hWnd, &processId);
	if(processId == lParam){
		mainHWnd = hWnd;
		ShowWindow(hWnd, SW_MAXIMIZE);
		return FALSE;
	}
	return TRUE;
}

void changeMainByPI(PROCESS_INFORMATION & pi){
	WaitForInputIdle(pi.hProcess, 10000);
	EnumWindows(EnumPIDtoHWnd, pi.dwProcessId);
	if(mainHWnd == NULL){
		puts("ハンドルを入手できませんでした");
	}
	else changeMainHandle(mainHWnd);
	return;
}

#include <shlobj.h> // C:/Users/{username}/AppData/Roaming を取得するため
int main(){
	SetConsoleOutputCP(CP_UTF8);
	SetConsoleCP(CTRY_JAPAN);
	std::filesystem::path currentpath = std::filesystem::current_path();
	puts(currentpath.string().c_str());
	if(currentpath.string().size() > 46){
		std::string S = "ランチャー本体";
		std::string T = currentpath.string();
		bool flag = true;
		int Ssize = S.size();
		int Tsize = T.size();
		for(int offset = 0; offset < Ssize; ++offset) flag &= (T[offset + Tsize - Ssize] == S[offset]);
		if(flag){
			std::filesystem::current_path(currentpath.parent_path() / "ゲーム/YSF_puzzle");
		}
	}
	readRanking();
	STARTUPINFOA si;
	memset(&si, 0, sizeof(si));
	si.cb = sizeof(si);
	PROCESS_INFORMATION pi;
	if(!CreateProcessA(NULL, const_cast<char*>("FlashPlayer10.exe puzzle.swf"),NULL,NULL,false,0,NULL,NULL,&si,&pi)){
		puts("puzzle.exe の生成に失敗しました。");
		return 1;
	}
	ProcessId = pi.dwProcessId;
	changeMainByPI(pi);

	// shareObjectのパスを取得したい！
	Sleep(1000);
	CHAR AppDataPath[MAX_PATH];
	SHGetSpecialFolderPathA(NULL, AppDataPath, CSIDL_APPDATA, 0);
	sharedObjectPath = std::string(AppDataPath) + sharedObjectPath;
	auto directry = std::filesystem::directory_iterator(sharedObjectPath);
	for(auto & i : directry){
		sharedObjectPath = i.path().string();
		break;
	}
	sharedObjectPath += "/localhost/";
	HANDLE hDir = FindFirstChangeNotificationA(
		sharedObjectPath.c_str(),     // 監視するディレクトリの完全パス
		FALSE,                        // 指定したディレクトリのみ
		FILE_NOTIFY_CHANGE_LAST_WRITE // ファイルの更新時
	);
	if(hDir == INVALID_HANDLE_VALUE){
		puts("SharedObjectの監視に失敗しました:");
		puts(sharedObjectPath.c_str());
		return 1;
	}
	sharedObjectPath += sharedObjectName + ".sol";
	puts(sharedObjectPath.c_str());

	HANDLE handles[2] = {hDir, pi.hProcess};
	std::string laststate; // デバウンス用
	while(true){
		DWORD dwWaitStatus = WaitForMultipleObjects(2, handles, FALSE, INFINITE);
		Sleep(10);
		switch(dwWaitStatus){
			case WAIT_OBJECT_0:{
				sharedObjectReader();
				printf("state : %s", state.c_str());
				if(state != "data"){
					printf(", value : ");
					for(unsigned char & c : valuestream) putchar(c);
				}
				puts("");
				if(state == "ranking"){
					readRanking();
					sharedObjectWriter("data", ranking_data());
				}
				else if(state == "register"){
					readRanking();
					valuestream_register();
					writeRanking();
					sharedObjectWriter("data", ranking_data());
				}
				else if(state == "nick" && laststate != "nick"){
					HWND hWnd = GetConsoleWindow();
					ShowWindow(hWnd, SW_MAXIMIZE);
					LONG style = GetWindowLong(hWnd, GWL_STYLE);
					SetWindowLong(hWnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW); // 全画面準備
					SetWindowPos(mainHWnd, HWND_NOTOPMOST, 0, 0, 0, 0, 0); // .swf最上位やめ
					SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_SHOWWINDOW); // 最上位を.exeに
					SetForegroundWindow(hWnd); // .exeをアクティブに
					MoveWindow(
						hWnd,
						GetSystemMetrics(SM_XVIRTUALSCREEN),
						GetSystemMetrics(SM_YVIRTUALSCREEN),
						GetSystemMetrics(SM_CXVIRTUALSCREEN),
						GetSystemMetrics(SM_CYVIRTUALSCREEN),
						TRUE
					); // 全画面表示
					changeMainHandle(hWnd);

					std::string nickname;
					bool flag;
					do{
						flag = false;
						puts("クリックして名前を入力してEnterを押してください。");
						std::cin >> nickname;
						nickname = shiftjis_to_utf8(nickname);
						if(stringLength(nickname) == 1){
							puts("短すぎます");
							flag = true;
						}
						if(stringLength(nickname) > 20){
							puts("長すぎます");
							flag = true;
						}
						if(nickname == "名前"){
							std::string S;
							puts("名前を名前にしたいですか？[Y/n]");
							std::cin >> S;
							flag = (S != "Y" && S != "y");
						}
						if(nickname == "クリックして名前"){
							std::string S;
							puts("　を入力してください(\?\?\?)");
							puts("名前をクリックして名前にしたいですか？[Y/n]");
							std::cin >> S;
							flag = (S != "Y" && S != "y");
						}
					}while(flag);
					valuestream.clear();
					valuestream.reserve(nickname.size());
					for(unsigned char c : nickname) valuestream.push_back(c);
					sharedObjectWriter("return", valuestream);

					SetWindowLong(hWnd, GWL_STYLE, style); // 全画面終わり
					SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, 0); // .exe最上位やめ
					SetWindowPos(mainHWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_SHOWWINDOW); // 最上位を.swfに
					SetForegroundWindow(mainHWnd); // .swfをアクティブに
					changeMainByPI(pi);
				}
				else if(state == "quit"){
					puts("quit");
					return 0;
				}
				if(!FindNextChangeNotification(hDir)){
					puts("couldn't make NextChangeNotification");
					return 1;
				}
				break;
			}
			case WAIT_OBJECT_0 + 1:{
				puts("quit from swf");
				return 0;
				break;
			}
			default:{
				puts("err in wait_object loop");
				printf("%ld\n", GetLastError());
				return 1;
				break;
			}
		}
		laststate = state;
	}
}

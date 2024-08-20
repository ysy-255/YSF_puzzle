#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <algorithm>
#include <fstream>
#include <filesystem>

#include <windows.h>

#include "FILE.hpp"

std::string sharedObjectPath = "C:\\Users\\haru1\\AppData\\Roaming\\Macromedia\\Flash Player\\#SharedObjects\\";
std::string sharedObjectName = "YSF_Puzzle";

std::string rankingPath = "./data/rank.dat";

std::map<std::string/* 難易度名 */, std::vector<std::pair<int /* スコア */, std::string /* 名前 */>>> ranking;
std::string state;
std::vector<unsigned char> valuestream;

std::vector<unsigned char> file_to_datastream(std::string path){
	std::ifstream File(path,  std::ios::binary | std::ios::ate);
	if(!File.is_open()){
		std::cerr << (File.eof() ? "EOF " : "") << (File.fail() ? "FAIL " : "") << (File.bad() ? "BAD " : "") << std::endl;
	}
	int FileSize = File.tellg();
	File.seekg(0);
	std::vector<unsigned char> datastream(FileSize);
	File.read(reinterpret_cast<char*>(datastream.data()), FileSize);
	return datastream;
}

char charLength(const unsigned char c){
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
}

void writeRanking(){
	std::ofstream out(rankingPath);
	auto rankdata = ranking_data();
	out.write(reinterpret_cast<char*>(rankdata.data()), rankdata.size());
	return;
}

void sharedObjectReader(){
	Sleep(10);
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

int main(){
	STARTUPINFOA si = {sizeof(STARTUPINFOA)};
	si.cb = sizeof(si);
	PROCESS_INFORMATION pi;
	if(!CreateProcessA(NULL, const_cast<char*>("FlashPlayer10.exe puzzle.swf"),NULL,NULL,false,0,NULL,NULL,&si,&pi)){
		std::cerr << "err[4]\n";
		return 1;
	}
	auto directry = std::filesystem::directory_iterator(sharedObjectPath);
	for(auto & i : directry){
		sharedObjectPath = i.path().string();
		break;
	}
	sharedObjectPath += "\\localhost\\";
    HANDLE hDir = FindFirstChangeNotificationA(
        sharedObjectPath.c_str(),     // 監視するディレクトリの完全パス
        FALSE,                        // 指定したディレクトリのみ
        FILE_NOTIFY_CHANGE_LAST_WRITE // ファイルの更新時
    );
	if(hDir == INVALID_HANDLE_VALUE){
		std::cerr << "err[1]\n";
		puts(sharedObjectPath.c_str());
		return 1;
	}
	sharedObjectPath += sharedObjectName + ".sol";
	HANDLE handles[3] = {hDir, pi.hProcess, NULL};
	short handlesnum = 2;
	std::string laststate;
	while(true){
		DWORD dwWaitStatus = WaitForMultipleObjects(handlesnum, handles, FALSE, INFINITE);
		switch(dwWaitStatus){
			case WAIT_OBJECT_0:{
				sharedObjectReader();
				std::cerr << "state :" << state << std::endl;
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
					STARTUPINFOA si_h = {sizeof(STARTUPINFOA)};
					PROCESS_INFORMATION pi_h;
					si_h.dwFlags = STARTF_USESHOWWINDOW;
					si_h.wShowWindow = SW_MAXIMIZE;
					if(!CreateProcessA(NULL, const_cast<char*>("FlashPlayer10.exe register_helper.swf"),NULL,NULL,false,0,NULL,NULL,&si_h,&pi_h)){
						std::cerr << "err[5]\n";
						return 1;
					}
					handles[2] = pi_h.hProcess;
					handlesnum = 3;
				}
				else if(state == "quit"){
					std::cerr << "quit\n";
					return 0;
				}
				if(!FindNextChangeNotification(hDir)){
					std::cerr << "err[3]\n";
					return 1;
				}
				break;
			}
			case WAIT_OBJECT_0 + 1:{
				return 0;
				break;
			}
			case WAIT_OBJECT_0 + 2:{
				sharedObjectReader();
				if(state == "nick"){
					sharedObjectWriter("return", {'n', 'o', 'n', 'a', 'm', 'e'});
				}
				handles[2] = NULL;
				handlesnum = 2;
				break;
			}
			default:{
				std::cerr << "err[2]\n";
				std::cerr <<GetLastError();
				return 1;
				break;
			}
		}
		laststate = state;
	}
}

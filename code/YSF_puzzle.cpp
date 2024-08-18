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

std::string rankingPath = "C:\\Users\\haru1\\AppData\\Local\\Temp\\data\\rank.dat";

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

std::string getvalue(std::vector<unsigned char> & datastream, int & offset){
	unsigned char Length = datastream[offset ++] - '0';
	std::string value(Length, '\0');
	memcpy(value.data(), &datastream[offset], Length);
	offset += Length;
	return value;
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
			int nameSize = std::stoi(get);
			std::string name(nameSize, '\0');
			memcpy(name.data(), &datastream[offset], nameSize);
			offset += nameSize;
			int score = std::stoi(get);
			ranking[mode].push_back(std::make_pair(score, name));
		}
	}
}

void writeRanking(){
	std::ofstream out(rankingPath);
	for(auto & i : ranking){
		out << i.first.size();
		out << i.first;
		std::string vecSize = std::to_string(i.second.size());
		out << vecSize.size();
		out << vecSize;
		for(auto & j : i.second){
			std::string nameSize = std::to_string(j.second.size());
			out << nameSize.size();
			out << nameSize;
			out << j.second;
			std::string score = std::to_string(j.first);
			out << score.size();
			out << score;
		}
	}
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

void sharedObjectWriter(){
	std::ofstream File(sharedObjectPath, std::ios::binary);
	std::vector<unsigned char> datastream;
	#define pushS(str) datastream.insert(datastream.end(), str.begin(), str.end())
	#define pushC(num) datastream.push_back(num + '0')
	for(auto & i : ranking){
		pushC(i.first.size());
		pushS(i.first);
		int vecSize = i.second.size();
		std::string vecSizeStr = std::to_string(vecSize);
		pushC(vecSizeStr.size());
		pushS(vecSizeStr);
		for(auto & j : i.second){
			int nameSize = stringLength(j.second);
			std::string nameSizeStr = std::to_string(nameSize);
			pushC(nameSizeStr.size());
			pushS(nameSizeStr);
			pushS(j.second);
			std::string scoreStr = std::to_string(j.first);
			pushC(scoreStr.size());
			pushS(scoreStr);
		}
	}
	File << '\0' << (unsigned char)0xBF;
	UI_write(0x34 + datastream.size(), File, false);
	File << 'T' << 'C' << 'S' << 'O' << '\0' << '\4' << '\0' << '\0';
	UI_write(10, File, false);
	File.write(sharedObjectName.c_str(), sharedObjectName.size());
	UI_write(0, File, false);
	US_write(5, File, false);
	File << "state" << '\2';
	US_write(4, File, false);
	File << "data";
	File << '\0';
	US_write(5, File, false);
	File << "value" << '\2';
	US_write(datastream.size(), File, false);
	File.write(reinterpret_cast<char*>(datastream.data()), datastream.size());
	File << '\0';
	return;
}

int main(){
	std::system("start FlashPlayer10.exe puzzle.swf");
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
		return 0;
	}
	sharedObjectPath += sharedObjectName + ".sol";
	while(true){
		DWORD dwWaitStatus = WaitForSingleObject(hDir, INFINITE);
		switch(dwWaitStatus){
			case WAIT_OBJECT_0:{
				sharedObjectReader();
				std::cerr << "state :" << state << std::endl;
				if(state == "ranking"){
					readRanking();
					for(auto & i : ranking){
						std::sort(i.second.begin(), i.second.end());
					}
					sharedObjectWriter();
				}
				else if(state == "register"){
					readRanking();
					int offset = 0;
					std::string mode = getvalue(valuestream, offset);
					int nameLength = std::stoi(getvalue(valuestream, offset));
					std::string name;
					name.reserve(nameLength * 6);
					while(nameLength --){
						int length = charLength(valuestream[offset]);
						name.append(valuestream.begin() + offset, valuestream.begin() + offset + length);
						offset += length;
					}
					int score = std::stoi(getvalue(valuestream, offset));
					ranking[mode].push_back(std::make_pair(score, name));
					std::sort(ranking[mode].begin(), ranking[mode].end());
					writeRanking();
					sharedObjectWriter();
				}
				else if(state == "nick"){
					std::system("start /MAX FlashPlayer10.exe registar_helper.exe");
				}
				else if(state == "quit"){
					return 0;
				}
				if(!FindNextChangeNotification(hDir)){
					std::cerr << "err[3]\n";
				}
				break;
			}
			default:{
				std::cerr << "err[2]\n";
				break;
			}
		}
	}
}

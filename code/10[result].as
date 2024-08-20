goresult.removeMovieClip();

var mode2 = mode;

shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
if(shared_obj){
	shared_obj.data.state = "ranking";
	shared_obj.data.value = String(Math.random());
	shared_obj.flush();
}

// もどる
createEmptyMovieClip("back_game", 9);
drawRect(back_game, 0, height / 7 * 6, width / 12, height, 1, LColor, FColor);
textBox(back_game, "戻ﾙ", width / 24, height / 14 * 13, data.myfont, false);
back_game.onPress = function(){
	popUp("タイトル画面に戻りますか？", function(){
		shared_obj = null;
		_root.rank.removeMovieClip();
		_root.smode.removeMovieClip();
		while (modes.length > 0){
			modes.pop().removeMovieClip();
		}
		back_game.removeMovieClip();
		gotoAndPlay("title");
	});
};

var rank = createEmptyMovieClip("ranking", 100);
data.myfont.size = 24;
textBox(rank, "ランキング", width / 6, height / 14, data.myfont, false);
data.myfont.size = 16;
var sukoatouroku = "--------スコア登録--------\n";
var _ = 0;
for(; _ < 12; _++) sukoatouroku += "|                        |\n";
sukoatouroku += "--------------------------";
textBox(rank, sukoatouroku, width / 6, height / 21 * 10, data.myfont, false);
textBox(rank, "あなたの\nクリアタイム：", width / 6, height / 21 * 6, data.myfont, false);
textBox(rank, timeconvert(time), width / 6, height / 21 * 8, data.myfont, false);
textBox(rank, "ニックネーム：", width / 6, height / 21 * 10, data.myfont, false);
nickname = rank.createEmptyMovieClip("nickname", rank.getNextHighestDepth());
textBox(nickname, "ここをクリック", width / 6, height / 21 * 11, data.myfont, true);
nickname.onPress = function(){
	shared_obj.data.state = "nick";
	shared_obj.data.value = String(Math.random());
	shared_obj.flush();
	this.onEnterFrame = function(){
		shared_obj = null;
		shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
		if (shared_obj.data.state == "return"){
			getURL("FSCommand:" add "fullscreen", "true");
			this.label0.text = shared_obj.data.value;
			shared_obj.data.state = "none";
			shared_obj.flush();
			this.onEnterFrame = null;
		}
	};
};
data.myfont.size = 8;
textBox(rank, "(セキュリティの関係で新しいウィンドウで開きます)", width / 6, height / 21 * 12, data.myfont, false);
data.myfont.size = 16;
register = rank.createEmptyMovieClip("register", rank.getNextHighestDepth());
textBox(register, "登録", width / 6, height / 21 * 14, data.myfont, true);
data.myfont.size = defaultFontSize;
register.onPress = function(){
	var name = rank.nickname.label0.text;
	if(name == "ここをクリック"){
		popUp("ニックネームを\n入力してください");
	}
	else{
		popUp("登録してよろしいですか？", function(){
			rank.register.onPress = null;
			var text = "";
			var modename = ["easy", "normal", "hard", "insane"][mode2 - 1];
			text += String(modename.length);
			text += modename;
			text += String(name.length).length;
			text += String(name.length);
			text += name;
			text += String(time).length;
			text += String(time);
			shared_obj.data.state = "register";
			shared_obj.data.value = text;
			shared_obj.flush();
		});
	}
};

textBox(rank, "Loading...", width / 2, height / 2, data.myfont, false);
rank.mode = "no";
rank.data = "no";
rank.onEnterFrame = function(){
	if(shared_obj.data.state != "data" && shared_obj.data.state != "nick" && shared_obj.data.state != "none"){
		shared_obj = null;
		shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
		this.data = "no";
	}
	else if(this.data == "no"){
		this.data = [[], [], [], []];
		this.label8._visible = false;
		var value = shared_obj.data.value;
		var offset = 0;
		while(offset < value.length){
			var modeLength = Number(value.charAt(offset));
			offset ++;
			var mode_ = value.substr(offset, modeLength);
			offset += modeLength;
			if(mode_ == "easy") mode_ = 1;
			if(mode_ == "normal") mode_ = 2;
			if(mode_ == "hard") mode_ = 3;
			if(mode_ == "insane") mode_ = 4;
			var vecSizeLength = Number(value.charAt(offset));
			offset ++;
			var vecSize = Number(value.substr(offset, vecSizeLength));
			offset += vecSizeLength;
			while(vecSize--){
				var nameLengthLength = Number(value.charAt(offset));
				offset ++;
				var nameLength = Number(value.substr(offset, nameLengthLength));
				offset += nameLengthLength;
				var name = value.substr(offset, nameLength);
				offset += nameLength;
				var scoreLength = Number(value.charAt(offset));
				offset ++;
				var score = Number(value.substr(offset, scoreLength));
				offset += scoreLength;
				this.data[mode_ - 1].push([score, name]);
			}
		}
		this.mode = -1;
	}
	else if (this.mode != mode){
		this.label8.removeTextField();
		this.mode = mode;
		var vecSize = this.data[mode - 1].length;
		var text = "------------------------------------------------\n|クリアタイム| ニックネーム      \n------------------------------------------------";
		var _ = 0;
		for(; _ < vecSize; _++){
			var score = this.data[mode - 1][_][0];
			var name = this.data[mode - 1][_][1];
			text += "\n| ";
			text += timeconvert(score);
			text += " | ";
			text += name;
			text += "\n------------------------------------------------";
		}
		data.myfont.size = 16;
		data.myfont.align = "left";
		textBox(this, text, width / 3 * 2, height / 2, data.myfont, false);
		data.myfont.size = defaultFontSize;
		data.myfont.align = "center";
		this.label8._y = 48;
		this.label8.autoSize = "left";
		var scrollbar = (this.label8._height + 48 - height > 0);
		scroll._visible = scrollbar;
		if(scrollbar){
			scroll._yscale = (height - 48) * 100 / this.label8._height;
		}
	}
	scroll._x = 0;
	scroll._y = Math.min(height - scroll._height * scroll._yscale / 100 - 48, Math.max(0, scroll._y));
	this.label8._y = - scroll._y / (height - (scroll._height * scroll._yscale / 100) - 48) * (this._height - height + 48) + 48;
}

var scroll = createEmptyMovieClip("scroll", 110);
drawRect(scroll, width - 16, 48, width, height, 0.5, LColor, FColor);
scroll.onPress = function(){
	this.startDrag (false);
};
scroll.onRelease = function(){
	stopDrag ();
};


var smode = createEmptyMovieClip("selected_mode", 99);
smode._x = - width;
smode._y = 0;
smode.onEnterFrame = function(){
	if(mode != "no"){
		if(this._x < 0) this._x = modes[mode - 1]._x;
		this._x -= (this._x - modes[mode - 1]._x) / 3;
	}
};
drawRect(smode, 0, 0, width / 20 * 3, 48, 1, 0x00C000, FColor);
modes = new Array(0, 0, 0, 0);
data.myfont.size = 16;
for(i in modes){
	modes[i] = createEmptyMovieClip(["easy", "normal", "hard", "insane"][i], 101 + i);
	modes[i]._x = width / 19 * 7 + width / 20 * 3 * i;
	modes[i]._y = 0;
		modes[i].mode = Number(i) + 1;
		drawRect(modes[i], 4, 4, width / 20 * 3 - 4, 44, 0.5, LColor, FColor);
		textBox(modes[i], ["一般向け", "生徒向け", "ぜんぶ", (darkmode ? "::black::" : "::white::")][i], width / 40 * 3, 24, data.myfont, false);
		modes[i].onPress = function(){
			mode = this.mode;
		};
}
data.myfont.size = defaultFontSize;
stop();

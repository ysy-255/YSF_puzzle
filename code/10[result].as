var base_diff = Difficulty;

s_obj = SharedObject.getLocal("YSF_puzzle", "/");
if(s_obj){
	s_obj.data.state = "ranking";
	s_obj.data.value = String(Math.random());
	s_obj.flush();
}

// もどる
createEmptyMovieClip("back_game", 9);
drawRect(back_game, 0, Height / 7 * 6, Width / 12, Height / 7, 1, LColor, FColor);
textBox(back_game, "戻ﾙ", Width / 24, Height / 14 * 13, false);
back_game.onPress = function(){
	confirmPopUp("タイトル画面に戻りますか？", function(){
		s_obj = null;
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
t_fmt.size = 24;
textBox(rank, "ランキング", Width / 6, Height / 14, false);
t_fmt.size = 16;
var sukoatouroku = "--------スコア登録--------\n";
var _ = 0;
for(; _ < 12; _++) sukoatouroku += "|                        |\n";
sukoatouroku += "--------------------------";
textBox(rank, sukoatouroku, Width / 6, Height / 21 * 10, false);
textBox(rank, "あなたの\nクリアタイム：", Width / 6, Height / 21 * 6, false);
textBox(rank, timeconvert(time), Width / 6, Height / 21 * 8, false);
textBox(rank, "ニックネーム：", Width / 6, Height / 21 * 10, false);
nickname = rank.createEmptyMovieClip("nickname", rank.getNextHighestDepth());
var nickname_tf = textBox(nickname, "ここをクリック", Width / 6, Height / 21 * 11, true);
nickname.onPress = function(){
	getURL("FSCommand:" add "fullscreen", "false");
	s_obj.data.state = "nick";
	s_obj.data.value = String(Math.random());
	s_obj.flush();
	this.onEnterFrame = function(){
		s_obj = null;
		s_obj = SharedObject.getLocal("YSF_puzzle", "/");
		if (s_obj.data.state == "return"){
			getURL("FSCommand:" add "fullscreen", "true");
			nickname_tf.text = s_obj.data.value;
			s_obj.data.state = "none";
			s_obj.flush();
			this.onEnterFrame = null;
		}
	};
};
t_fmt.size = 8;
textBox(rank, "(セキュリティの関係で新しいウィンドウで開きます)", Width / 6, Height / 21 * 12, false);
t_fmt.size = 16;
register = rank.createEmptyMovieClip("register", rank.getNextHighestDepth());
textBox(register, "登録", Width / 6, Height / 21 * 14, true);
t_fmt.size = defaultFontSize;
register.onPress = function(){
	var name = nickname_tf.text;
	if(name == "ここをクリック"){
		confirmPopUp("ニックネームを\n入力してください");
	}
	else{
		confirmPopUp("登録してよろしいですか？", function(){
			rank.register.onPress = null;
			var text = "";
			var modename = ["easy", "normal", "hard", "insane"][base_diff];
			text += String(modename.length);
			text += modename;
			text += String(name.length).length;
			text += String(name.length);
			text += name;
			text += String(time).length;
			text += String(time);
			s_obj.data.state = "register";
			s_obj.data.value = text;
			s_obj.flush();
		});
	}
};

var rank_tf = textBox(rank, "Loading...", Width / 2, Height / 2, false);
rank.mode = "no";
rank.data = "no";
rank.onEnterFrame = function(){
	if(s_obj.data.state != "data" && s_obj.data.state != "nick" && s_obj.data.state != "none"){
		s_obj = null;
		s_obj = SharedObject.getLocal("YSF_puzzle", "/");
		this.data = "no";
	}
	else if(this.data == "no"){
		this.data = [[], [], [], []];
		rank_tf._visible = false;
		var value = s_obj.data.value;
		var offset = 0;
		while(offset < value.length){
			var modeLength = Number(value.charAt(offset));
			offset ++;
			var mode_ = value.substr(offset, modeLength);
			offset += modeLength;
			if(mode_ == "easy") mode_ = 0;
			if(mode_ == "normal") mode_ = 1;
			if(mode_ == "hard") mode_ = 2;
			if(mode_ == "insane") mode_ = 3;
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
				this.data[mode_].push([score, name]);
			}
		}
		this.mode = -1;
	}
	else if (this.mode != Difficulty){
		rank_tf.removeTextField();
		this.mode = Difficulty;
		var vecSize = this.data[Difficulty].length;
		var text = "------------------------------------------------\n|順位|クリアタイム| ニックネーム      \n------------------------------------------------";
		var _ = 0;
		for (; _ < vecSize; _++){
			var jyunni = Number(_) + 1; if(jyunni < 10) jyunni = ' ' + jyunni;
			var score = this.data[Difficulty][_][0];
			var name = this.data[Difficulty][_][1];
			text += "\n| ";
			text += jyunni;
			text += " | ";
			text += timeconvert(score);
			text += " | ";
			text += name;
			text += "\n------------------------------------------------";
		}
		t_fmt.size = 16;
		t_fmt.align = "left";
		textBox(this, text, Width / 3 * 2, Height / 2, false);
		t_fmt.size = defaultFontSize;
		t_fmt.align = "center";
		rank_tf._y = 48;
		rank_tf.autoSize = "left";
		var scrollbar = (rank_tf._height + 48 - Height > 0);
		scroll._visible = scrollbar;
		if(scrollbar){
			scroll._yscale = (Height - 48) * (Height - 48) / rank_tf._height / Height * 100;
			scroll._y = Math.min(scroll._y, Height * (1 - scroll._yscale / 100));
		}
	}
	rank_tf._y = - (scroll._y - 48) / ((Height * (1 - scroll._yscale / 100)) - 48) * (this._height - Height + 48) + 48;
};

var scroll = createEmptyMovieClip("scroll", 110);
drawRect(scroll, Width - 16, 0, 16, Height, 0.5, LColor, FColor);
scroll._y = 48;
scroll.onPress = function(){
	this.startDrag (false, 0, 48, 0, Height * (1 - this._yscale / 100));
};
scroll.onRelease = function(){
	stopDrag ();
};


var smode = createEmptyMovieClip("selected_mode", 99);
smode._x = - Width;
smode._y = 0;
smode.onEnterFrame = function(){
	if(Difficulty != "no"){
		if(this._x < 0) this._x = modes[Difficulty]._x;
		this._x -= (this._x - modes[Difficulty]._x) / 3;
	}
};
drawRect(smode, 0, 0, Width / 20 * 3, 48, 1, 0x00C000, FColor);
modes = new Array(0, 0, 0, 0);
t_fmt.size = 16;
for(i in modes){
	modes[i] = createEmptyMovieClip(["easy", "normal", "hard", "insane"][i], 101 + i);
	modes[i]._x = Width / 19 * 7 + Width / 20 * 3 * i;
	modes[i]._y = 0;
	modes[i].mode = Number(i);
	drawRect(modes[i], 4, 4, Width / 20 * 3 - 8, 40, 0.5, LColor, FColor);
	textBox(modes[i], ["一般向け", "生徒向け", "ぜんぶ", (DarkMode ? "::black::" : "::white::")][i], Width / 40 * 3, 24, false);
	modes[i].onPress = function(){
		Difficulty = this.mode;
	};
}
t_fmt.size = defaultFontSize;
stop();

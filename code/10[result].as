var current_diff:Number = Difficulty;
var diff_labels:Array = ["一般向け", "生徒向け", "ぜんぶ", (DarkMode ? "::black::" : "::white::")];

s_obj = SharedObject.getLocal("YSF_puzzle", "/");
s_obj.data.state = "ranking";
s_obj.data.value = String(Math.random());
s_obj.flush();

// もどる
var back_game:MovieClip = _root.createEmptyMovieClip("back_game", 9);
var smode:MovieClip = _root.createEmptyMovieClip("selected_mode", 99);
var rank:MovieClip = _root.createEmptyMovieClip("ranking", 100);
var scroll:MovieClip = createEmptyMovieClip("scroll", 110);

rank.loaded = false;
rank.rawData = "";
rank.shownDiff = -1;

drawRect(scroll, Width - 16, 0, 16, Height, 0.5, LColor, FColor);
scroll._y = 48;
scroll.onPress = function(){
	this.startDrag (false, 0, 48, 0, Height * (1 - this._yscale / 100));
};
scroll.onRelease = function(){
	stopDrag ();
};
scroll._visible = false;


drawRect(back_game, 0, Height / 7 * 6, Width / 12, Height / 7, 1, LColor, FColor);
textBox(back_game, "戻ﾙ", Width / 24, Height / 14 * 13, false);
back_game.onPress = function(){
	confirmPopUp("タイトル画面に戻りますか？", function(){
		s_obj = null;
		rank.removeMovieClip();
		smode.removeMovieClip();
		while (modes.length > 0){
			modes.pop().removeMovieClip();
		}
		back_game.removeMovieClip();
		gotoAndPlay("title");
	});
};

t_fmt.size = 24;
textBox(rank, "ランキング", Width / 6, Height / 14, false);
t_fmt.size = 16;
var sukoatouroku:String = "--------スコア登録--------\n";
var _i:Number = 0;
for(; _i < 12; _i++) sukoatouroku += "|                        |\n";
sukoatouroku += "--------------------------";
textBox(rank, sukoatouroku, Width / 6, Height / 21 * 10, false);
textBox(rank, "あなたの\nクリアタイム：", Width / 6, Height / 21 * 6, false);
textBox(rank, timeconvert(elapsed), Width / 6, Height / 21 * 8, false);
textBox(rank, "ニックネーム：", Width / 6, Height / 21 * 10, false);
var nickname:MovieClip = rank.createEmptyMovieClip("nickname", rank.getNextHighestDepth());
var nickname_tf:TextField = textBox(nickname, "ここをクリック", Width / 6, Height / 21 * 11, true);
nickname.onPress = function(){
	fscommand("fullscreen", false);
	s_obj.data.state = "nick";
	s_obj.data.value = String(Math.random());
	s_obj.flush();
	this.onEnterFrame = function(){
		s_obj = null;
		s_obj = SharedObject.getLocal("YSF_puzzle", "/");
		if (s_obj.data.state == "return"){
			fscommand("fullscreen", true);
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
var register:MovieClip = rank.createEmptyMovieClip("register", rank.getNextHighestDepth());
textBox(register, "登録", Width / 6, Height / 21 * 14, true);
t_fmt.size = defaultFontSize;
register.onPress = function(){
	var name:String = nickname_tf.text;
	if(name == "ここをクリック"){
		confirmPopUp("ニックネームを\n入力してください");
	}
	else{
		confirmPopUp("登録してよろしいですか？", function(){
			rank.register.onPress = null;
			var text:String = "";
			var modename:String = ["easy", "normal", "hard", "insane"][Difficulty];
			text += String(modename.length);
			text += modename;
			text += String(name.length).length;
			text += String(name.length);
			text += name;
			text += String(elapsed).length;
			text += String(elapsed);
			s_obj.data.state = "register";
			s_obj.data.value = text;
			s_obj.flush();
			rank.loaded = false;
			current_diff = Difficulty;
			rank_tf.removeTextField();
			rank_tf = textBox(rank, "Registering...", Width / 2, Height / 2, false);
		});
	}
};

var rank_tf:TextField = textBox(rank, "Loading...", Width / 2, Height / 2, false);
rank.onEnterFrame = function(){
	if (!this.loaded){
		s_obj = null;
		s_obj = SharedObject.getLocal("YSF_puzzle", "/");
		if (s_obj.data.state == "data"){
			fscommand("fullscreen", true);
			rank.rawData = s_obj.data.value;
		}
		else{
			return;
		}
		this.data = [[], [], [], [], [], []];
		var offset:Number = 0;
		var src:String = this.rawData;
		while(offset < src.length){
			var modeLength:Number = Number(src.charAt(offset));
			offset ++;
			var modeName:String = src.substr(offset, modeLength);
			var mode:Number = 5;
			offset += modeLength;
			if(modeName == "easy") mode = 0;
			if(modeName == "normal") mode = 1;
			if(modeName == "hard") mode = 2;
			if(modeName == "insane") mode = 3;
			var vecSizeLength:Number = Number(src.charAt(offset));
			offset ++;
			var vecSize:Number = Number(src.substr(offset, vecSizeLength));
			offset += vecSizeLength;
			while(vecSize--){
				var nameLengthLength:Number = Number(src.charAt(offset));
				offset ++;
				var nameLength:Number = Number(src.substr(offset, nameLengthLength));
				offset += nameLengthLength;
				var name:String = src.substr(offset, nameLength);
				offset += nameLength;
				var scoreLength:Number = Number(src.charAt(offset));
				offset ++;
				var score:Number = Number(src.substr(offset, scoreLength));
				offset += scoreLength;
				this.data[mode].push([score, name]);
			}
		}
		this.shownDiff = -1;
		this.loaded = true;
	}
	else if (this.shownDiff != current_diff){
		this.shownDiff = current_diff;
		rank_tf.removeTextField();
		var vecSize:Number = this.data[current_diff].length;
		var text:String = "------------------------------------------------\n|順位|クリアタイム| ニックネーム      \n------------------------------------------------";
		var index:Number = 0;
		for (; index < vecSize; index++){
			var rank_str:String = index + 1; if(rank_str < 10) rank_str = ' ' + rank_str;
			var score_str:String = this.data[current_diff][index][0];
			var name_str:String = this.data[current_diff][index][1];
			text += "\n| ";
			text += rank_str;
			text += " | ";
			text += timeconvert(score_str);
			text += " | ";
			text += name_str;
			text += "\n------------------------------------------------";
		}
		t_fmt.size = 16;
		t_fmt.align = "left";
		rank_tf = textBox(this, text, Width / 3 * 2, Height / 2, false);
		t_fmt.size = defaultFontSize;
		t_fmt.align = "center";
		rank_tf._y = 48;
		rank_tf.autoSize = "left";
		var scrollbar:Boolean = (rank_tf._height + 48 - Height > 0);
		scroll._visible = scrollbar;
		if(scrollbar){
			scroll._yscale = (Height - 48) * (Height - 48) / rank_tf._height / Height * 100;
			scroll._y = Math.min(scroll._y, Height * (1 - scroll._yscale / 100));
		}
	}
	rank_tf._y = - (scroll._y - 48) / ((Height * (1 - scroll._yscale / 100)) - 48) * (this._height - Height + 48) + 48;
};


smode._x = - Width;
smode._y = 0;
smode.onEnterFrame = function(){
	if(this._x < 0) this._x = modes[current_diff]._x;
	this._x -= (this._x - modes[current_diff]._x) / 3;
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
	textBox(modes[i], diff_labels[i], Width / 40 * 3, 24, false);
	modes[i].onPress = function(){
		current_diff = this.mode;
	};
}
t_fmt.size = defaultFontSize;
stop();

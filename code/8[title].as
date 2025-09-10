/* [6]title */

DataLoader.removeMovieClip();


var smode_mc:MovieClip = _root.createEmptyMovieClip("selected_mode", 99);
smode_mc._x = - Width;
smode_mc._y = Height / 12 * 5;
drawRect(smode_mc, 0, 0, Width / 5, Height / 6, 1, 0x00C000, -1);
smode_mc._visible = false;

var mode_proceed_mc:MovieClip = _root.createEmptyMovieClip("gomode", 100);
var mode_proceed_mc_tf:TextField = textBox(mode_proceed_mc, "モード選択へ", Width / 2, Height / 3 * 2, false);

var title_mc:MovieClip = _root.createEmptyMovieClip("Title", 110);
t_fmt.size = 24;
var title_mc_tf:TextField = textBox(title_mc, GameName, Width / 2, Height / 3, false);
t_fmt.size = defaultFontSize;

var start_mc:MovieClip = _root.createEmptyMovieClip("start", 150);
var start_mc_tf:TextField = textBox(start_mc, "ゲームスタート", Width / 2, Height / 3 * 2, false);
start_mc._visible = false;

var setting_mc:MovieClip = _root.createEmptyMovieClip("setting", 65534);
drawRect(setting_mc, 0, 0, 80, 80, 0.1, 0, 0xC0C0C0);
var setting_mc_tf:TextField = textBox(setting_mc, "設　\n　定", 40, 40, false);

var description_mc:MovieClip = _root.createEmptyMovieClip("description", 65530);
drawRect(description_mc, 80, 0, 80, 80, 0.1, 0, 0xC0C0C0);
var description_mc_tf:TextField = textBox(description_mc, "操作\n方法", 120, 40, false);

var mode_labels:Array = ["一般向け", "生徒向け", "ぜんぶ", (DarkMode ? "::black::" : "::white::")];
var mode_names:Array = ["easy", "normal", "hard", "insane"];
var modes:Array = [0, 0, 0, 0];

for (_i in mode_labels){
	var i:Number = Number(_i);
	modes[i] = _root.createEmptyMovieClip(mode_names[i], i + 101);
	modes[i]._x = Width / 10 * (1 + i * 2);
	modes[i]._y = Height / 12 * 5;
	modes[i].i = Number(i);
	modes[i]._visible = false;
}

mode_proceed_mc.onPress = function(){
	//_root.getInstanceAtDepth(65538).removeMovieClip();
	t_fmt.size = 24;
	for (_i in modes){
		var i:Number = Number(_i);
		modes[i]._visible = true;
		modes[i].tf = textBox(modes[i], mode_labels[i], Width / 10, Height / 12, false);
		drawRect(modes[i], 4, 4, Width / 5 - 8, Height / 6 - 8, 0.5, LColor, FColor);
		modes[i].onPress = function(){
			Difficulty = this.i;
		};
	}
	t_fmt.size = defaultFontSize;
	title_mc.removeMovieClip();
	smode_mc._visible = true;
	smode_mc.onEnterFrame = function(){
		if(Difficulty != -1){
			if(this._x < 0) this._x = modes[Difficulty]._x;
			this._x += (modes[Difficulty]._x - this._x) / 3;
		}
	};
	start_mc._visible = true;
	start_mc.onPress = function(){
		if(!Paused){
			if(Difficulty === -1){
				confirmPopUp("モードを選択してください", false);
			}
			else{
				setting_mc.removeMovieClip();
				smode_mc.removeMovieClip();
				description_mc.removeMovieClip();
				while(modes.length > 0){
					modes.pop().removeMovieClip();
				}
				play();
				this.removeMovieClip();
			}
		}
	};
	this.removeMovieClip();
	stop();
};

var last_toggled = getTimer();
setting_mc.onPress = function(){
	if (Paused) return;
	Paused = true;
	var dialog:MovieClip = _root.createEmptyMovieClip("dialog", 65535);
	dialog._x = Width / 2 - 100;
	dialog._y = Height / 2 - 100;
	var dialog_quit:MovieClip = dialog.createEmptyMovieClip("quit", 1);
	drawRect(dialog, 0, 0, 200, 200, 1, LColor, FColor);
	quitButton(dialog_quit, 200, 0, function(){
		Paused = false;
		dialog.removeMovieClip();
	});
	var dmode_mc:MovieClip = dialog.createEmptyMovieClip("darkmode", 2);
	t_fmt.size = 16;
	var dmode_mc_tf:TextField = textBox(dmode_mc, "ダークモード：" + (DarkMode ? " ON" : "OFF"), 100, 50, false);
	t_fmt.size = defaultFontSize;
	dmode_mc.onPress = function(){
		var nowTime = getTimer();
		if(nowTime - last_toggled < 500) return;
		last_toggled = nowTime;
		if(DarkMode){
			DarkMode = false;
			dmode_mc_tf.text = "ダークモード：OFF";
			modes[3].tf.text = "::white::";
		}
		else{
			DarkMode = true;
			dmode_mc_tf.text = "ダークモード： ON";
			modes[3].tf.text = "::black::";
		}
		ToggleColor();
		setting_mc_tf.textColor = LColor;
		description_mc_tf.textColor = LColor;
		title_mc_tf.textColor = LColor;
		mode_proceed_mc_tf.textColor = LColor;
		dmode_mc_tf.textColor = LColor;
		start_mc_tf.textColor = LColor;
		for (i in modes){
			modes[i].tf.textColor = LColor;
		}
		for (i in modes){
			drawRect(modes[i], 4, 4, Width / 5 - 8, Height / 6 - 8, 0.5, LColor, FColor);
		}
		drawRect(dialog, 0, 0, 200, 200, 1, LColor, FColor);
	}
}

description_mc.onPress = function(){
	if (Paused) return;
	Paused = true;
	var dialog:MovieClip = _root.createEmptyMovieClip("dialog", 65531);
	dialog._x = Width / 2 - 100;
	dialog._y = Height / 2 - 100;
	var desc_quit = dialog.createEmptyMovieClip("quit", 1);
	quitButton(desc_quit, 200, 0, function(){
		Paused = false;
		dialog.removeMovieClip();
	});
	drawRect(dialog, 0, 0, 200, 200, 1, LColor, FColor);
	var de = dialog.createEmptyMovieClip("de", 2);
	t_fmt.size = 16;
	textBox(de, "役立つ操作方法！\n\nマウスホイール：　　\n　　マップ拡大縮小　\n\n１～５キー：　　　　\n　　階選択　　　　　\n\n以上！", 100, 100, false);
	t_fmt.size = defaultFontSize;
}

stop();

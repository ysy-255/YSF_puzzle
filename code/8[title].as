/* [6]title */

loading.removeTextField();


data.myfont.align = "center";
data.myfont.size = defaultFontSize;


createEmptyMovieClip("gomode", 100);
data.myfont.size = 32;
textBox(gomode, "モード選択へ", width / 2, height / 3 * 2, data.myfont, false);
data.myfont.size = defaultFontSize;
modes = new Array(0, 0, 0, 0);
gomode.onPress = function(){
	Title.removeMovieClip();
	popUp.removeMovieClip();
	data.myfont.size = 24;
	var smode = createEmptyMovieClip("selected_mode", 99);
	smode._x = - width;
	smode._y = height / 12 * 5;
	smode.onEnterFrame = function(){
		if(mode != "no"){
			if(this._x < 0) this._x = modes[mode - 1]._x;
			this._x -= (this._x - modes[mode - 1]._x) / 3;
		}
	};
	drawRect(smode, 0, -4, width / 5, height / 6 + 4, 1, 0x00C000, FColor);
	for (i in modes){
		modes[i] = createEmptyMovieClip(["easy", "normal", "hard", "insane"][i], 101 + i);
		modes[i]._x = width / 10 * (1 + i * 2);
		modes[i]._y = height / 12 * 5;
		modes[i].mode = Number(i) + 1;
		// if (modes[i].mode == 1) modes[i].mode = 0;
		drawRect(modes[i], 4, 0, width / 5 - 4, height / 6, 0.5, LColor, FColor);
		textBox(modes[i], ["一般向け", "生徒向け", "ぜんぶ", (darkmode ? "::black::" : "::white::")][i], width / 10, height / 12, data.myfont, false);
		modes[i].onPress = function(){
			mode = this.mode;
		};
	}
	data.myfont.size = 36;
	createEmptyMovieClip("start", 150);
	textBox(start, "ゲームスタート", width / 2, height / 3 * 2, data.myfont, false);
	start.onPress = function(){
		if(!stopped){
			if(mode === "no"){
				popUp("モードを選択してください", false);
			}
			else{
				setting.removeMovieClip();
				smode.removeMovieClip();
				description.removeMovieClip();
				while(modes.length > 0){
					modes.pop().removeMovieClip();
				}
				gotoAndPlay("game");
			}
		}
	};
	gomode.removeMovieClip();
	stop();
};

createEmptyMovieClip("Title", 110);
data.myfont.size = 24;
textBox(Title, gameName, width / 2, height / 3, data.myfont, false);
data.myfont.size = defaultFontSize;

setting = createEmptyMovieClip("setting", 65534);
drawRect(setting, 0, 0, 80, 80, 0.1, 0, 0xC0C0C0);
textBox(setting, "設　\n　定", 40, 40, data.myfont, false);
setting.onPress = function(){
	if (stopped) return;
	stopped = true;
	var dialog = createEmptyMovieClip("dialog", 65535);
	dialog._x = width / 2 - 100;
	dialog._y = height / 2 - 100;
	var quit_temp = dialog.createEmptyMovieClip("quit", 1);
	quitButton(quit_temp, 200, 0, function(){
		stopped = false;
		dialog.removeMovieClip();
	});
	drawRect(dialog, 0, 0, 200, 200, 1, LColor, FColor);
	var dark = dialog.createEmptyMovieClip("darkmode", 2);
	data.myfont.size = 16;
	textBox(dark, "ダークモード：" + (darkmode ? " ON" :"OFF"), 100, 50, data.myfont, false);
	data.myfont.size = defaultFontSize;
	dark.onPress = function(){
		if(darkmode){
			darkmode = false;
			this.label0.text = "ダークモード：OFF";
			insane.label0.text = "::white::";
		}
		else{
			darkmode = true;
			this.label0.text = "ダークモード： ON";
			insane.label0.text = "::black::";
		}
		wb();
		this.label0.backgroundColor = FColor;
		this.label0.textColor = LColor;
		Title.label0.textColor = LColor;
		gomode.label0.textColor = LColor;
		easy.label0.textColor = LColor;
		normal.label0.textColor = LColor;
		hard.label0.textColor = LColor;
		insane.label0.textColor = LColor;
		start.label0.textColor = LColor;
		for(i in modes){
			drawRect(modes[i], 4, 0, width / 5 - 4, height / 6, 0.5, LColor, FColor);
		}
		drawRect(selected_mode, 0, -4, width / 5, height / 6 + 4, 1, 0x00C000, FColor);
		drawRect(dialog, 0, 0, 200, 200, 1, LColor, FColor);
	}
}

description = createEmptyMovieClip("setting", 65530);
drawRect(description, 80, 0, 160, 80, 0.1, 0, 0xC0C0C0);
textBox(description, "操作\n方法", 120, 40, data.myfont, false);
description.onPress = function(){
	if (stopped) return;
	stopped = true;
	var desc = createEmptyMovieClip("desc", 65531);
	desc._x = width / 2 - 100;
	desc._y = height / 2 - 100;
	var quit_temp = desc.createEmptyMovieClip("quit", 1);
	quitButton(quit_temp, 200, 0, function(){
		stopped = false;
		desc.removeMovieClip();
	});
	drawRect(desc, 0, 0, 200, 200, 1, LColor, FColor);
	var de = desc.createEmptyMovieClip("de", 2);
	data.myfont.size = 16;
	textBox(de, "役立つ操作方法！\n\nマウスホイール：　　\n　　マップ拡大縮小　\n\n１～５キー：　　　　\n　　階選択　　　　　\n\n以上！", 100, 100, data.myfont, false);
	data.myfont.size = defaultFontSize;
}

stop();

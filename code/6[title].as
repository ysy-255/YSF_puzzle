/* [6]title */

loading.removeTextField();


data.myfont.align = "center";
data.myfont.size = defaultFontSize;


createEmptyMovieClip("gomode", 100);
data.myfont.size = 32;
textBox(gomode, "モード選択へ", width / 2, height / 3 * 2, data.myfont, false);
data.myfont.size = defaultFontSize;
gomode.onPress = function(){
	gotoAndPlay("mode");
};

createEmptyMovieClip("Title", 110);
data.myfont.size = 24;
textBox(Title, gameName, width / 2, height / 4, data.myfont, false);
data.myfont.size = defaultFontSize;

// デフォルトのモード
mode = "no";

stop();

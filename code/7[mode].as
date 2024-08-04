/* [7]mode */

gomode.removeMovieClip();
Title.removeMovieClip();
popUp.removeMovieClip();


data.myfont.size = 24;

createEmptyMovieClip("easy", 101);
textBox(easy, "外部の方向け", width / 5, height / 3, data.myfont, false);
easy.onPress = function(){
	mode = 1;
};

createEmptyMovieClip("normal", 102);
textBox(normal, "生徒向け", width / 5 * 2, height / 3, data.myfont, false);
normal.onPress = function(){
	mode = 2;
};

createEmptyMovieClip("hard", 103);
textBox(hard, "ぜんぶ", width / 5 * 3, height / 3, data.myfont, true);
hard.onPress = function(){
	mode = 3;
};

createEmptyMovieClip("white", 104); // しろっていいよね
textBox(white, "::White::", width / 5 * 4, height / 3, data.myfont, true);
white.onPress = function(){
	mode = 4;
};

data.myfont.size = 36;


createEmptyMovieClip("start", 150);
textBox(start, "ゲームスタート", width / 2, height / 3 * 2, data.myfont, false);
start.onPress = function(){
	if(mode === "no"){
		popUp("モードを選択してください", false);
	}
	else{
		gotoAndPlay("game");
	}
};


stop();

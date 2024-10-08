/* [1] 基本的な変数・関数 */

gameName = "Flashゲーム\n横浜市立横浜サイエンスフロンティア高等学校・附属中学校\n校内図パズル";

// フルスクリーンコマンド(ブルスクとフルスクリーンって似てるよね)
getURL("FSCommand:" add "fullscreen", "true");

// 再生中に右クリック->再生とかされると困ります　なつみSTEP！のおまけじゃあるまいし
Stage.showMenu = false;

width = Stage.width;
height = Stage.height;

defaultFontSize = 36;

shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
shared_obj.data.state = "none";
shared_obj.data.value = "none";
shared_obj.flush();
// ---------- 深度管理表 ----------
// 背景色(黒)          : 0
// データ              : 1
// メニュー            : 65534
// メニューダイアログ  : 65535
// EXIT                : 65537
// ポップアップ        : 65538
// 読み込み中          : 5     [2 - 5]
// 選択されたモード    : 99    [6]
// モードへ            : 100   [6]
// 結果へ              : 100   [8]
// ランキング          : 100   [9]
// タイトル            : 110   [6]
// モード              : 101 - 104  [7]
// スクロール          : 110
// ゲームスタート      : 150   [7]
// main                : 1000  [8]
// timer               : 1001  [8]
// マップ管理          : 200   [8]
// 1階 - 5階           : 201 - 205 [8] 
// 部屋                : 1100 - 2300 [8]
// ホールド中の部屋    : 3000  [8]

//                      ↑いやそんなに被らず置くなら深度管理の意味なくない？それ

// デフォルトのモード
mode = "no";

// font.swf からフォントを読み込むまでこれ使う
format_temp = new TextFormat();
format_temp.align = "center";
format_temp.font = "ＭＳ ゴシック";
format_temp.size = 36;

// ゲームが進行していると false
stopped = false;

function drawRect(parent, x1, y1, x2, y2, line_width, line_color, fill_color){
	if(line_width == 0){
		parent.lineStyle(0, line_color, 0);
	}
	else{
		parent.lineStyle(line_width, line_color, 100);
	}
	parent.beginFill(fill_color, 100);
	parent.moveTo(x1, y1);
	parent.lineTo(x2, y1);
	parent.lineTo(x2, y2);
	parent.lineTo(x1, y2);
	parent.lineTo(x1, y1);
	parent.endFill();
};

function drawCircle(parent, x, y, radius, from, to, line_width, line_color, line_alpha, fill_color, fill_alpha){
	parent.lineStyle(line_width, line_color, line_alpha);
	parent.beginFill(fill_color, fill_alpha);
	parent.moveTo(Math.cos(from) * radius + x, Math.sin(from) * radius + y);
	while(from < to){
		var x2 = Math.cos(from) * radius;
		var y2 = Math.sin(from) * radius;
		from = Math.min(from + Math.PI / 4, to);
		var x_now = x2;
		var y_now = y2;
		x2 = Math.cos(from) * radius;
		y2 = Math.sin(from) * radius;
		var k = radius * radius / (x_now * y2 - y_now * x2);
		var y1 = (x_now - x2) * k;
		var x1 = (y2 - y_now) * k;
		parent.curveTo(x + x1, y + y1, x + x2, y + y2);
	}
	return;
};


darkmode = false;
LColor = 0x000000;
FColor = 0xFFFFFF;
BackGround = createEmptyMovieClip("bg0", 0);
drawRect(BackGround, -10, -10, width + 10, height + 10, 0, 0, 0x000000);
wb = function(){
	if(darkmode){
		bg0._visible = true;
		LColor = 0xFFFFFF;
		FColor = 0x000000;
	}
	else{
		bg0._visible = false;
		LColor = 0x000000;
		FColor = 0xFFFFFF;
	}
	data.myfont.color = LColor;
	format_temp.color = LColor;
};
bg0.onEnterFrame = wb;


function textBox(parent, text, x, y, format, box){
	var tf = parent.createTextField("label" + parent.getNextHighestDepth(), parent.getNextHighestDepth(), 0, 0, width, height);
	tf.setNewTextFormat(format);
	tf.text = text;
	tf.autoSize = "center";
	tf.embedFonts = true;
	if(text.split('\n').length > 1){
		tf.multiline = true;
	}
	var text_width = tf.textWidth + 4;
	var text_height = tf.textHeight + 4;
	x -= text_width / 2;
	y -= text_height / 2;
	tf._x = x;
	tf._y = y;
	tf._width = text_width;
	tf._height = text_height;
	if(box){
		drawRect(parent, x, y, x + text_width, y + text_height, 0.5, LColor, FColor);
	}
	return parent.getNextHighestDepth();
};


function quitButton(parent, x, y, onPressFunc){
	drawRect(parent, x - 20, y, x, y + 10, 1, 0xA00000, 0xFF4444);
	parent.lineStyle(1.5, 0xFFFFFF, 100);
	parent.moveTo(x - 14, y + 2);
	parent.lineTo(x -  6, y + 8);
	parent.moveTo(x -  6, y + 2);
	parent.lineTo(x - 14, y + 8);
	parent.onPress = function(){
		onPressFunc();
	};
};


function popUp(text, yes_func){
	stopped = true;
	var twidth = width / 8;
	var theight = height / 5;

	var pop = _root.createEmptyMovieClip("popUp", 65538);
	pop._x = twidth * 3;
	pop._y = theight * 2;
	drawRect(pop, 0, 0, twidth * 2, theight * 1, 0.5, LColor, FColor);
	drawRect(pop, 0, 0, twidth * 2, 10, 0.5, LColor, 0xC0C0C0);

	pop.createEmptyMovieClip("quit", 10);
	quitButton(pop.quit, twidth * 2, 0, function(){
		stopped = false;
		pop.removeMovieClip();
		return;
	});

	format_temp.size = 12;
	textBox(pop, text, twidth, theight / 3, format_temp, false);

	var yes = pop.createEmptyMovieClip("Yes", 2);
	textBox(yes, "はい", twidth / 2, theight / 1.5, format_temp, true);
	yes.onPress = function(){
		stopped = false;
		yes_func();
		this._parent.removeMovieClip();
		return;
	};

	var no = pop.createEmptyMovieClip("No", 3);
	textBox(no, "いいえ", twidth * 1.5, theight / 1.5, format_temp, true);
	no.onPress = function(){
		stopped = false;
		this._parent.removeMovieClip();
		return;
	};
	
	
	format_temp.size = defaultFontSize;
};


// 右上のやつ          ↓Closeじゃないの？
createEmptyMovieClip("quit", 65537);
quitButton(quit, width, 0, function(){
	popUp("進行状況を破棄して\nゲームを終了しますか？", function(){
		var shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
		shared_obj.data.state = "quit";
		shared_obj.data.value = String(Math.random());
		shared_obj.flush();
		getURL("FSCommand:" add "quit",0);
	});
});



function timeconvert(time_){
	var text = "";
	var minute = String(Math.floor(time_ / 60000));
	if(minute == "0"){
		text += "  　";
	}
	else{
		if(minute.length == 1){
			minute = " " + minute;
		}
		text += minute;
		text += "分";
	}
	var second = String(Math.floor(time_ / 1000) % 60);
	if(second.length == 1){
		text += " ";
	}
	text += second;
	text += "秒";
	var decimal = String(Math.floor(time_ / 10) % 100);
	if(decimal.length == 1){
		decimal = '0' + decimal;
	}
	text += decimal;
	return text;
};

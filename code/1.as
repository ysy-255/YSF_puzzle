/* [1] 基本的な変数・関数 */

GameName = "Flashゲーム\n横浜市立横浜サイエンスフロンティア高等学校・附属中学校\n校内図パズル";
Width = Stage.width;
Height = Stage.height;
defaultFontSize = 36;
s_obj = SharedObject.getLocal("YSF_puzzle", "/");
t_fmt = new TextFormat();
Difficulty = -1;
Paused = false;
DarkMode = false;
LColor = 0x000000;
FColor = 0xFFFFFF;


s_obj.data.state = "none";
s_obj.data.value = "none";
s_obj.flush();

t_fmt.align = "center";
t_fmt.font = "ＭＳ ゴシック";
t_fmt.size = defaultFontSize;


// https://open-flash.github.io/mirrors/as2-language-reference/global_functions.html#fscommand()
fscommand("fullscreen", true);

// 再生中に右クリック->再生とかされると困ります　なつみSTEP！のおまけじゃあるまいし
Stage.showMenu = false;


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


function drawRect(
	parent:MovieClip,
	x1:Number,
	y1:Number,
	width:Number,
	height:Number,
	line_width:Number,
	line_color:Number,
	fill_color:Number
){
	var x2:Number = x1 + width;
	var y2:Number = y1 + height;
	var has_fill = fill_color != -1;
	var has_line = line_width != 0;
	if(has_line){
		parent.lineStyle(line_width, line_color, 100);
	}
	else{
		parent.lineStyle(0, line_color, 0);
	}
	if(has_fill) parent.beginFill(fill_color, 100);
	parent.moveTo(x1, y1);
	parent.lineTo(x2, y1);
	parent.lineTo(x2, y2);
	parent.lineTo(x1, y2);
	parent.lineTo(x1, y1);
	if(has_fill) parent.endFill();
};

function drawCircle(
	parent:MovieClip,
	x0:Number,
	y0:Number,
	radius:Number,
	from:Number,
	to:Number,
	line_width:Number,
	line_color:Number,
	line_alpha:Number,
	fill_color:Number,
	fill_alpha:Number
){
	parent.lineStyle(line_width, line_color, line_alpha);
	parent.beginFill(fill_color, fill_alpha);
	parent.moveTo(x0 + Math.cos(from) * radius, y0 + Math.sin(from) * radius);
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
		parent.curveTo(x0 + x1, y0 + y1, x0 + x2, y0 + y2);
	}
	return;
};

function textBox(
	parent:MovieClip,
	text:String,
	x:Number,
	y:Number,
	box:Boolean
){
	var depth:Number = parent.getNextHighestDepth();
	var tf:TextField = parent.createTextField("textBox" + depth, depth, 0, 0, Width, Height);
	tf.setNewTextFormat(t_fmt);
	tf.text = text;
	tf.autoSize = "center";
	tf.embedFonts = true;
	if(text.split('\n').length > 1){
		tf.multiline = true;
	}
	var text_width:Number = tf.textWidth + 4;
	var text_height:Number = tf.textHeight + 4;
	x -= text_width / 2;
	y -= text_height / 2;
	tf._x = x;
	tf._y = y;
	tf._width = text_width;
	tf._height = text_height;
	if(box){
		drawRect(parent, x, y, text_width, text_height, 0.5, LColor, FColor);
	}
	return tf;
};

function quitButton(
	parent:MovieClip,
	x:Number,
	y:Number,
	onPressFunc:Function
){
	drawRect(parent, x - 20, y, 20, 10, 1, 0xA00000, 0xFF4444);
	parent.lineStyle(1.5, 0xFFFFFF, 100);
	parent.moveTo(x - 14, y + 2);
	parent.lineTo(x -  6, y + 8);
	parent.moveTo(x -  6, y + 2);
	parent.lineTo(x - 14, y + 8);
	parent.onPress = function (){
		onPressFunc();
	};
};

function confirmPopUp(text:String, yes_func:Function){
	Paused = true;
	var twidth:Number = Width / 8;
	var theight:Number = Height / 5;

	var pop:MovieClip = _root.createEmptyMovieClip("popUp", 65538);
	pop._x = twidth * 3;
	pop._y = theight * 2;
	drawRect(pop, 0, 0, twidth * 2, theight, 0.5, LColor, FColor);
	drawRect(pop, 0, 0, twidth * 2, 10, 0.5, LColor, 0xC0C0C0);

	var pop_quit:MovieClip = pop.createEmptyMovieClip("quit", 10);
	quitButton(pop_quit, twidth * 2, 0, function(){
		Paused = false;
		pop.removeMovieClip();
		return;
	});

	t_fmt.size = 12;
	textBox(pop, text, twidth, theight / 3, false);

	var yes_mc:MovieClip = pop.createEmptyMovieClip("Yes", 2);
	textBox(yes_mc, "はい", twidth * 0.5, theight / 1.5, true);
	yes_mc.onPress = function(){
		Paused = false;
		yes_func();
		this._parent.removeMovieClip();
		return;
	};

	var no_mc:MovieClip= pop.createEmptyMovieClip("No", 3);
	textBox(no_mc, "いいえ", twidth * 1.5, theight / 1.5, true);
	no_mc.onPress = function(){
		Paused = false;
		this._parent.removeMovieClip();
		return;
	};


	t_fmt.size = defaultFontSize;
};

function timeconvert(time_:Number){
	var text:String = "";
	var minutes:String = String(Math.floor(time_ / 60000));
	if(minutes == "0"){
		text += "  　";
	}
	else{
		if(minutes.length == 1){
			text += " ";
		}
		text += minutes;
		text += "分";
	}
	var seconds:String = String(Math.floor(time_ / 1000) % 60);
	if(seconds.length == 1){
		text += " ";
	}
	text += seconds;
	text += "秒";
	var decimal = String(Math.floor(time_ / 10) % 100);
	if(decimal.length == 1){
		decimal = '0' + decimal;
	}
	text += decimal;
	return text;
};


// (背景)色管理
function ToggleColor(){
	if(DarkMode){
		LColor = 0xFFFFFF;
		FColor = 0x000000;
	}
	else{
		LColor = 0x000000;
		FColor = 0xFFFFFF;
	}
}

var bg_mc:MovieClip = _root.createEmptyMovieClip("bg", 0);
drawRect(bg_mc, -10, -10, Width + 10, Height + 10, 0, 0, 0x000000);
bg_mc.onEnterFrame = function(){
	this._visible = DarkMode;
	//data.myfont.color = LColor;
	t_fmt.color = LColor;
};


// 右上のやつ
var quit_mc:MovieClip = _root.createEmptyMovieClip("quit", 65537);
quitButton(quit_mc, Width, 0, function(){
	confirmPopUp("進行状況を破棄して\nゲームを終了しますか？", function(){
		s_obj.data.state = "quit";
		s_obj.data.value = String(Math.random());
		s_obj.flush();
		fscommand("quit");
	});
});


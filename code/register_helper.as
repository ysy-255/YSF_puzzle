shared_obj = SharedObject.getLocal("YSF_puzzle", "/");

Stage.showMenu = false;

Stage.scaleMode = "exactFit";
width = Stage.width;
height = Stage.height;
format_temp = new TextFormat();
format_temp.align = "center";
format_temp.font = "ＭＳ ゴシック";
format_temp.size = 16;


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

function textBox(parent, text, x, y, format, box){
	var tf = parent.createTextField("label" + parent.getNextHighestDepth(), parent.getNextHighestDepth(), 0, 0, width, height);
	tf.setNewTextFormat(format);
	tf.text = text;
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

textBox(_root, "ニックネーム：", width / 2, height / 6, format_temp, false);
format_temp.color = "0xC0C0C0";
textBox(_root, "ここに入力...　　　　　　　　　", width / 2, height / 3, format_temp, false);
format_temp.color = "0x000000";
format_temp.align = "left";
textBox(_root, "", width / 2, height / 3, format_temp, false);
format_temp.align = "center";
label2.type = "input";
label1.selectable = false;
label2._x = label1._x;
label2._width = label1._width;
label2._y = label1._y;
label2._height = label1._height;
drawRect(_root, label2._x, label2._y, label2._x + label2._width, label2._y + label2._height, 3, 0, 0xFFFFFF);
_root.onEnterFrame = function(){
	if(label2.text.length > 0){
		label1._visible = false;
	}
	else {
		label1._visible = true;
	}
};

createEmptyMovieClip("kettei", 123);
textBox(kettei, "決定", width / 2, height / 3 * 2, format_temp, true);
kettei.onPress = function(){
	if(label2.text.length == 0){
		popUp("入力して下さい");
	}
	else if(label2.text.length < 2){
		popUp("短すぎます");
	}
	else if(label2.text.length > 16){
		popUp("長すぎます");
	}
	else {
		var shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
		shared_obj.data.state = "return";
		shared_obj.data.value = label2.text;
		shared_obj.flush();
		getURL("FSCommand:" add "quit",0);
	}
}


createEmptyMovieClip("quit", 65537);
quitButton(quit, width, 0, function(){
	popUp("戻りますか？", function(){
		var shared_obj = SharedObject.getLocal("YSF_puzzle", "/");
		shared_obj.data.state = "return";
		shared_obj.data.value = "noname";
		shared_obj.flush();
		getURL("FSCommand:" add "quit",0);
	});
});



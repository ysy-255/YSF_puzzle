/* [8]game */

var areas:Array = Data.map.split('\n');

var mapPadX:Number = 379;
var mapPadY:Number = 228;


rooms = 0;
complete = 0; // マップ完成率 = complete / rooms

rooms_floor = [0, 0, 0, 0, 0, 0];
complete_floor = [0, 0, 0, 0, 0, 0];

zoom = 30; // 拡大度 大きいほど大きくなる (小泉)

nowfloor = 1;


var allfloors:MovieClip = _root.createEmptyMovieClip("allfloors", 200);
var back_game:MovieClip = _root.createEmptyMovieClip("back_game", 280);
var goresult:MovieClip = _root.createEmptyMovieClip("goresult", 290);
var sfloor:MovieClip = _root.createEmptyMovieClip("selected_floor", 310);
var main:MovieClip = _root.createEmptyMovieClip("main", 1000);
var timer:MovieClip = _root.createEmptyMovieClip("timer", 1001);
var allrooms:MovieClip = _root.createEmptyMovieClip("allrooms", 1099);
var floor_switch:Array = [0, 0, 0, 0, 0, 0];


// マウスホイール回転時に拡大度を変えます
var mouselistener:Object = new Object();
mouselistener.onMouseWheel = function(delta:Number){
	var zoom_old:Number = zoom;
	zoom = Math.max(10, Math.min(100, zoom * Math.exp(delta / 10)));
	var mouse_x:Number = _root._xmouse;
	var mouse_y:Number = _root._ymouse;
	allfloors._x = allfloors._x - (mouse_x - allfloors._x) * (zoom / zoom_old - 1);
	allfloors._y = allfloors._y - (mouse_y - allfloors._y) * (zoom / zoom_old - 1);
};
Mouse.addListener(mouselistener);

var keylistener:Object = new Object();
keylistener.onKeyDown = function(){
	var keycode:Number = Key.getCode();
	if(49 <= keycode && keycode <= 54){
		nowfloor = keycode - 48;
	}
};
Key.addListener(keylistener);

// ムービークリップのonReleaseより正確にドラッグを止めてくれます (ムービークリップのほうはムービークリップ上でないと動かないのかも)
onMouseUp = function (){
	stopDrag ();
};


// 時間計測など
elapsed = 0;
var oldTime:Number = getTimer();
main.onEnterFrame = function(){
	var newTime:Number = getTimer();
	if(!Paused){
		elapsed += newTime - oldTime;
		if (rooms == complete){
			Data.chirin.start();
			confirmPopUp("complete!!\nクリアタイム：" + timeconvert(elapsed) + "\n\n完成したマップを十分に堪能したら\n右下から結果画面へ進んでね", null);
			goresult._visible = true;
			this.removeMovieClip();
		}
	}
	oldTime = newTime;
};


t_fmt.size = 16;
var timer_tf:TextField = textBox(timer, "準備中..", Width / 24, Height / 28 * 23, false);
t_fmt.size = defaultFontSize;
timer.onEnterFrame = function(){
	if (!Paused){
		var timestr:String = String(Math.floor(elapsed / 100) / 10);
		if(timestr.charAt(timestr.length - 2) != '.'){
			timestr += ".0";
		}
		timer_tf.text = timestr + "秒";
	}
};


// もどる
drawRect(back_game, 0, Height / 7 * 6, Width / 12, Height / 7, 1, LColor, FColor);
textBox(back_game, "戻ﾙ", Width / 24, Height / 14 * 13,  false);
back_game.onPress = function(){
	confirmPopUp("前の画面に戻りますか？\n進行状況は破棄されます", function(){
		goresult.removeMovieClip();
		allfloors.removeMovieClip();
		sfloor.removeMovieClip();
		main.removeMovieClip();
		timer.removeMovieClip();
		allrooms.removeMovieClip();
		while (floor_switch.length > 0){
			floor_switch.pop().removeMovieClip();
		}
		Mouse.removeListener(mouselistener);
		Key.removeListener(keylistener);
		prevFrame();
		back_game.removeMovieClip();
	});
};



sfloor._x = 0;
sfloor._y = - Height;
sfloor.onEnterFrame = function(){
	if(this._y < 0) this._y = floor_switch[nowfloor - 1]._y;
	this._y += (floor_switch[nowfloor - 1]._y - this._y) / 3;
};
drawRect(sfloor, 4, 4, Width / 12 - 8, Height / 7 - 8, 1, 0x00C000);

var floor_labels:Array = ["１", "２", "３", "４", "５", "Ｒ"];

for (var _i in floor_switch){
	var i:Number = Number(_i);
	var floor:Number = i + 1;
	floor_switch[i] = _root.createEmptyMovieClip("switch_" + floor, 300 + i);
	floor_switch[i].floor = floor;
	floor_switch[i]._y = Height / 7 * i;
	textBox(floor_switch[i], floor_labels[i] + "F", Width / 24, Height / (floor == 6 ? 28 : 14), false);
	drawRect(floor_switch[i], 0.5, 0, Width / 12 - 0.5, Height / (floor == 6 ? 14 : 7), 0.5, LColor, FColor);
	floor_switch[i].onPress = function(){
		nowfloor = this.floor;
	};
}


allfloors._x = Width / 6 + (-mapPadX) * zoom / 100;
allfloors._y = (-mapPadY) * zoom / 100;
allfloors.onEnterFrame = function(){
	this._xscale = zoom;
	this._yscale = zoom;
	var X:Number = this._x;
	var Y:Number = this._y;
	var W:Number = this._width;
	var H:Number = this._height;
	if(W < Width / 3 * 2){
		this._x = X - (X - Math.min(Math.max(X, Width / 12), Width / 12 * 9 - W)) / 10;
	}
	else{
		this._x = X - (X - Math.max(Math.min(X, Width / 12), Width / 12 * 9 - W)) / 10;
	}
	if(H < Height){
		this._y = Y - (Y - Math.min(Math.max(Y, 0), Height - H)) / 10;
	}
	else{
		this._y = Y - (Y - Math.max(Math.min(Y, 0), Height - H)) / 10;
	}
};

var map_bg:MovieClip = allfloors.createEmptyMovieClip("bg", 200);
var mcLoader:MovieClipLoader = new MovieClipLoader();
mcLoader.loadClip("./data/surroundings875.png", map_bg);
map_bg._xscale = 200;
map_bg._yscale = 200;
map_bg._x = 0;
map_bg._y = 0;
map_bg._alpha = 50;

var floors:Array = [0, 0, 0, 0, 0, 0];
for (var _i in floors){
	var i:Number = Number(_i);
	var floor:Number = i + 1;
	floors[i] = allfloors.createEmptyMovieClip("floor_" + floor, 200 + floor);
	floors[i].floor = floor;
	floors[i]._x = mapPadX;
	floors[i]._y = mapPadY;
	floors[i].onEnterFrame = function(){
		if(nowfloor != this.floor){
			this._visible = false;
		}
		else{
			this._visible = true;
		}
	};
	floors[i].onPress = function(){
		allfloors.startDrag (false);
	}
}


function draw_d(
	parent:MovieClip,
	src:String,
	X:Number,
	Y:Number,
	line_width:Number,
	color:Number
){
	if(line_width == 0){
		parent.lineStyle(0, LColor, 0);
	}
	else{
		parent.lineStyle(line_width, LColor, 100);
	}
	var has_fill = color != -1;
	var ops:Array = src.split(' ');
	var index:Number = 0;
	var inSubpath:Boolean = false;
	var x0:Number = -X;
	var y0:Number = -Y;
	var x:Number = -X;
	var y:Number = -Y;
	var lastop:Number = 76;
	var lower:Boolean = false;
	for (; index < ops.length; ++index){
		var rest = ops.length - index - 1;
		var op:Number = ops[index].charCodeAt(0);
		if (48 <= op && op < 58 || op == 45){
			op = lastop;
			rest ++;
			index --;
		}
		else{
			lower = op >= 97;
			if (lower) op -= 32;
		}
		switch(op){
			case 77:{ // 'M
				if (rest < 2) return;
				lastop = 76;
				var _1 = Number(ops[++index]);
				var _2 = Number(ops[++index]);
				if (lower){
					x += _1;
					y += _2;
				}
				else{
					x = _1 - X;
					y = _2 - Y;
				}
				parent.moveTo(x, y);
				x0 = x;
				y0 = y;
				if (!inSubpath && has_fill) parent.beginFill(color, 100);
				inSubpath = true;
				break;
			}
			case 90:{ // 'Z'
				if (!inSubpath) return;
				inSubpath = false;
				if(x != x0 || y != y0){
					x = x0;
					y = y0;
					parent.lineTo(x, y);
				}
				if (has_fill) parent.endFill();
				break;
			}
			case 76:{ // 'L'
				if (rest < 2) return;
				lastop = 76;
				var _1 = Number(ops[++index]);
				var _2 = Number(ops[++index]);
				if (lower){
					x += _1;
					y += _2;
				}
				else{
					x = _1 - X;
					y = _2 - Y;
				}
				parent.lineTo(x, y);
				break;
			}
			case 72:{ // 'H'
				if (rest < 1) return;
				lastop = 72;
				var _1 = Number(ops[++index]);
				if (lower){
					x += _1;
				}
				else{
					x = _1 - X;
				}
				parent.lineTo(x, y);
				break;
			}
			case 86:{ // 'V'
				if (rest < 1) return;
				lastop = 86;
				var _1 = Number(ops[++index]);
				if (lower){
					y += _1;
				}
				else{
					y = _1 - Y;
				}
				parent.lineTo(x, y);
				break;
			}
			case 67:{ // 'C' 独自形式 一度しか使わないのでこれでいい
				if (rest < 5) return;
				var _1 = Number(ops[++index]) - X;
				var _2 = Number(ops[++index]) - Y;
				var _3 = Number(ops[++index]);
				var _4 = Number(ops[++index]) * Math.PI / 180;
				var _5 = Number(ops[++index]) * Math.PI / 180;
				drawCircle(parent, _1, _2, _3, _4, _5);
				x = _1 + _3 * Math.cos(_5);
				y = _2 + _3 * Math.sin(_5);
				break;
			}
			default:{
				return;
			}
		}
	}
}

Paused = true;
lastfloor = 6;


allrooms.onEnterFrame = function(){
	if(areas.length == 0){
		Paused = false;
		this.onEnterFrame = null;
		return;
	}
	var area:Array = areas.pop().split("\\n").join('\n').split(',');
	var floor:Number = Number(area[0]);
	var color:Number = parseInt(area[1], 16);
	var thre:Number = Number(area[2]);
	var canPiece:Boolean = thre >= 0;
	var isPiece:Boolean = canPiece && thre <= Difficulty;
	var divideFillAndStroke = area.length == 10;
	var roomNumber:Number;
	var roomNameEN:String;
	var roomNameJP:String;
	var X:Number;
	var Y:Number;
	var d:String;
	var d2:String;
	if (canPiece){
		roomNumber = Number(area[3]);
		roomNameEN = area[4];
		roomNameJP = area[5];
		X = Number(area[6]);
		Y = Number(area[7]);
		d = area[8];
		if (divideFillAndStroke){
			d2 = area[9];
		}
	}
	else{
		d = area[3];
	}
	if (color == 0 && !canPiece) color = -1;
	else{
		if(Difficulty == 3){
			if(DarkMode){
				color = 0x000000;
			}
			else{
				color = 0xFFFFFF;
			}
		}
		else if(DarkMode){
			var r:Number = (color >> 16) & 0xFF;
			var g:Number = (color >>  8) & 0xFF;
			var b:Number = (color >>  0) & 0xFF;
			r = Math.max(r - 96, 0);
			g = Math.max(g - 96, 0);
			b = Math.max(b - 96, 0);
			color = (r << 16) | (g << 8) | b;
		}
	}
	draw_d(floors[floor - 1], d, 0, 0, canPiece ? 1 : color == -1 ? 1 : 0, color);
	if (divideFillAndStroke) draw_d(floors[floor - 1], d2, 0, 0, 1, -1);
	if (!isPiece && canPiece){
		var new_mc:MovieClip = floors[floor - 1].createEmptyMovieClip(roomNameEN, roomNumber);
		textBox(new_mc, roomNameJP, X, Y, false);
	}
	nowfloor = floor;
	if (!isPiece) return;
	rooms ++;
	rooms_floor[floor - 1] ++;
	var mc:MovieClip = this.createEmptyMovieClip(roomNameEN, roomNumber);
	mc._xscale = zoom;
	mc._yscale = zoom;
	mc._x = Width / 3 * 2 + ((Width / 3 - 50) * Math.random()) + 25;
	mc._y = (Height / 7 * 6 - 50) * Math.random() + 25;
	mc.to_x = X;
	mc.to_y = Y;
	mc.floor = floor;
	mc.nameEN = roomNameEN;
	mc.nameJP = roomNameJP;
	mc.num = roomNumber;
	draw_d(mc, d, X, Y, 2, color);
	if (divideFillAndStroke) draw_d(mc, d2, X, Y, 1, -1);
	textBox(mc, roomNameJP, 0, 0, false);
	mc.onPress = function(){
		if(!Paused){
			this.startDrag (false);
			this.swapDepths(3000);
		}
	};
	mc.onRelease = function(){
		stopDrag ();
		var dx:Number = (this._x - allfloors._x) * 100 / zoom - this.to_x - mapPadX;
		var dy:Number = (this._y - allfloors._y) * 100 / zoom - this.to_y - mapPadY;
		if (this.floor == nowfloor && dx * dx + dy * dy < 2500){
			Data.koteltu.start();
			this._x = this.to_x;
			this._y = this.to_y;
			this.onPress = null;
			this.onRelease = null;
			this.onEnterFrame = null;
			complete ++;
			complete_floor[this.floor - 1] ++;
			var new_mc:MovieClip = floors[this.floor - 1].createEmptyMovieClip(this.nameEN, this.num);
			textBox(new_mc, this.nameJP, this.to_x, this.to_y, false);
			this.removeMovieClip();
		}
	};
	mc.onEnterFrame = function(){
		if(Difficulty == 3){
			this._visible = true;
		}
		else if(nowfloor != this.floor){
			this._visible = false;
		}
		else{
			this._visible = true;
		}
		this._xscale = zoom;
		this._yscale = zoom;
	}
}


drawRect(goresult, Width / 12 * 11, Height / 7 * 6, Width / 12, Height / 7, 1, LColor, FColor);
textBox(goresult, "進ﾑ", Width / 24 * 23, Height / 14 * 13, false);
goresult.onPress = function(){
	allfloors.removeMovieClip();
	sfloor.removeMovieClip();
	main.removeMovieClip();
	timer.removeMovieClip();
	allrooms.removeMovieClip();
	while (floor_switch.length > 0){
		floor_switch.pop().removeMovieClip();
	}
	Mouse.removeListener(mouselistener);
	Key.removeListener(keylistener);
	back_game.removeMovieClip();
	play();
	this.removeMovieClip();
};
goresult._visible = false;

stop();

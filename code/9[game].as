/* [8]game */

areas = Data.map.split('\n');


rooms = 0;
complete = 0; // マップ完成率 = complete / rooms

rooms_floor = [0, 0, 0, 0, 0, 0];
complete_floor = [0, 0, 0, 0, 0, 0];

zoom = 30; // 拡大度 大きいほど大きくなる (小泉)

nowfloor = 1;


var back_game:MovieClip = _root.createEmptyMovieClip("back_game", 9);
var goresult:MovieClip = _root.createEmptyMovieClip("goresult", 100);
var allfloors:MovieClip = _root.createEmptyMovieClip("allfloors", 200);
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
time = 0;
oldTime = getTimer();
main.onEnterFrame = function(){
	var nowTime = getTimer();
	if(Paused){
		// なにもしないよ
	}
	else{
		time += nowTime - oldTime;
		if (rooms == complete){
			Data.chirin.start();
			confirmPopUp("complete!!\nクリアタイム：" + timeconvert(time) + "\n完成したマップを十分に堪能したら\n右下から結果画面へ進んでね", null);
			goresult._visible = true;
			main.removeMovieClip();
		}
	}
	oldTime = nowTime;
};


t_fmt.size = 16;
var timer_tf:TextField = textBox(timer, "準備中..", Width / 24, Height / 28 * 23, false);
t_fmt.size = defaultFontSize;
timer.onEnterFrame = function(){
	if (!Paused){
		var timestr = String(Math.floor(time / 100) / 10);
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


allfloors._x = Width / 6;
allfloors._y = Height / 36;
allfloors.onPress = function(){
	if(Paused){
		// うごかすもんか！
	}
	else{
		this.startDrag (false);
	}
};
allfloors.onEnterFrame = function(){
	this._xscale = zoom;
	this._yscale = zoom;
	if(this._width < Width / 3 * 2){
		this._x = this._x - (this._x - Math.min(Math.max(this._x, Width / 12), Width / 12 * 9 - this._width)) / 10;
	}
	else{
		this._x = this._x - (this._x - Math.max(Math.min(this._x, Width / 12), Width / 12 * 9 - this._width)) / 10;
	}
	if(this._height < Height){
		this._y = this._y - (this._y - Math.min(Math.max(this._y, 0), Height - this._height)) / 10;
	}
	else{
		this._y = this._y - (this._y - Math.max(Math.min(this._y, 0), Height - this._height)) / 10;
	}
};

var floors:Array = [0, 0, 0, 0, 0, 0];
for (var _i in floors){
	var i:Number = Number(_i);
	var floor:Number = i + 1;
	floors[i] = allfloors.createEmptyMovieClip("floor_" + floor, 200 + floor);
	floors[i].floor = floor;
	floors[i].onEnterFrame = function(){
		if(nowfloor != this.floor){
			this._visible = false;
		}
		else{
			this._visible = true;
		}
	};
}

// (右側のピースでなく)マップに追加
function map_add(parent, type, x1, y1, x2, y2, line_width, color){
	var offset = 1;
	if(line_width == 0){
		parent.lineStyle(0, LColor, 0);
	}
	else{
		parent.lineStyle(line_width, LColor, 100);
	}
	switch (type){
		case 'r':{
			drawRect(parent, x1, y1, x2 - x1, y2 - y1, line_width, LColor, color);
			offset += 4;
			break;
		}
		case 'm':{
			parent.beginFill(color, 100);
			parent.moveTo(x1, y1);
			offset += 2;
			break;
		}
		case 'l':{
			parent.lineTo(x1, y1);
			offset += 2;
			break;
		}
	}
	return offset;
}

function line_add(parent, type, x1, y1, x2, y2){
	var offset = 1;
	parent.lineStyle(1.5, LColor, 100);
	parent.endFill();
	switch (type){
		case 'r':{
			parent.moveTo(x1, y1);
			parent.lineTo(x2, y1);
			parent.lineTo(x2, y2);
			parent.lineTo(x1, y2);
			parent.lineTo(x1, y1);
			offset += 4;
			break;
		}
		case 'm':{
			parent.moveTo(x1, y1);
			offset += 2;
			break;
		}
		case 'l':{
			parent.lineTo(x1, y1);
			offset += 2;
			break;
		}
	}
	return offset;
}

// マップは文字なし　右側にピース追加
function room_add(parent, type, x1, y1, x2, y2, color, x, y){
	var offset = 1;
	parent.lineStyle(1.5, DarkMode ? 0xC0C0C0 : 0x808080, 100);
	switch(type){
		case 'r':{
			drawRect(parent, x1 - x, y1 - y, x2 - x1, y2 - y1, 1.5, DarkMode ? 0xC0C0C0 : 0x808080, color);
			offset += 4;
			break;
		}
		case 'm':{
			parent.beginFill(color, 100);
			parent.moveTo(x1 - x, y1 - y);
			offset += 2;
			break;
		}
		case 'l':{
			parent.lineTo(x1 - x, y1 - y);
			offset += 2;
			break;
		}
		default:{
			// コメントｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!
		}
	}
	return offset;
}

var loaded = false; // マップのロードが終わるまで待つ用
Paused = true;
lastfloor = 6;




// マップ構築
// root にくっつけている意味は大してないけどいちいちムービークリップ作るのも億劫なので
allrooms.onEnterFrame = function(){
	var area = areas.pop().split("\\n").join('\n').split(',');
	for(num2 in area){
		if(isNaN(parseInt(area[num2], 10)) || area[num2][2] == 'x'){
			// 文字列だー
		}
		else{
			area[num2] = parseInt(area[num2]);
		}
	}
	var floor = area[0];
	if(floor != lastfloor){
		nowfloor = Number(floor);
		lastfloor = floor;
	}
	var color = parseInt(area[1], 16);
	if(DarkMode){
		var r = (color >> 16) & 0xFF;
		var g = (color >>  8) & 0xFF;
		var b = (color >>  0) & 0xFF;
		r = Math.max(r - 96, 0);
		g = Math.max(g - 96, 0);
		b = Math.max(b - 96, 0);
		color = (r << 16) | (g << 8) | b;
	}
	if (area[2] == -1){
		var offset = 3;
		while(offset < area.length){
			var type = area[offset];
			if(type == 'm' || type == 'l'){
				var x = area[offset + 1];
				var y = area[offset + 2];
				offset += (color == 0x000000) ? line_add(floors[floor - 1], type, x, y, -1, -1) : map_add(floors[floor - 1], type, x, y, -1, -1, 1, color);
			}
			else if(type == 'c'){
				var x = area[offset + 1];
				var y = area[offset + 2];
				var r = area[offset + 3];
				var from = area[offset + 4] / 180 * Math.PI;
				var to = area[offset + 5] / 180 * Math.PI;
				drawCircle(floors[floor - 1], x, y, r, from, to, (color == 0x000000) ? 1 : 0, LColor, (color == 0x000000) ? 100 : 0, color, (color == 0x000000) ? 0 : 100);
				offset += 6;
			}
			else{
				var x1 = area[offset + 1];
				var y1 = area[offset + 2];
				var x2 = area[offset + 3];
				var y2 = area[offset + 4];
				offset += (color == 0x000000) ? line_add(floors[floor - 1], type, x1, y1, x2, y2) : map_add(floors[floor - 1], type, x1, y1, x2, y2, 0, color);
			}
		};
	}
	else if (Difficulty >= area[2]){
		if(Difficulty == 3){
			color = FColor;
		}
		rooms ++;
		var room_num = area[3];
		var name = area[4];
		var room_name = area[5];
		var room_mc = allrooms.createEmptyMovieClip(name, room_num);
		room_mc.floor = floor;
		room_mc.num = room_num;
		room_mc.name_en = name;
		room_mc.name_jp = room_name;
		
		room_mc._xscale = zoom;
		room_mc._yscale = zoom;
		
		if(area[6] == 'r'){
			var x1 = area[7];
			var y1 = area[8];
			var x2 = area[9];
			var y2 = area[10];
			var x = (x1 + x2) / 2;
			var y = (y1 + y2) / 2;
			room_mc._x = Width / 3 * 2 + (Width / 3 * Math.random());
			room_mc._y = Height * Math.random();
			room_mc.to_x = x;
			room_mc.to_y = y;
			map_add(floors[floor - 1], 'r', x1, y1, x2, y2, 0.5, color);
			room_add(room_mc, 'r', x1, y1, x2, y2, color, x, y);
			textBox(room_mc, room_name, 0, 0, false);
		}
		else if(area[6] == 'd'){
			var x = area[7];
			var y = area[8];
			room_mc._x = Width / 3 * 2 + (Width / 3 * Math.random());
			room_mc._y = Height * Math.random();
			room_mc.to_x = x;
			room_mc.to_y = y;
			var offset = 9;
			while (offset < area.length){
				var type = area[offset];
				if(type == 'c'){
					var x1 = area[offset + 1];
					var y1 = area[offset + 2];
					var r = area[offset + 3];
					var from = area[offset + 4] / 180 * Math.PI;
					var to = area[offset + 5] / 180 * Math.PI;
					drawCircle(floors[floor - 1], x1, y1, r, from, to, 0.5, LColor, 100, color, (color == 0x000000) ? 0 : 100);
					drawCircle(room_mc, x1 - x, y1 - y, r, from, to, 0.5, DarkMode ? 0xC0C0C0 : 0x808080, 100, color, (color == 0x000000) ? 0 : 100);
					offset += 6;
					continue;
				}
				var x1 = area[offset + 1];
				var y1 = area[offset + 2];
				var x2 = area[offset + 3];
				var y2 = area[offset + 4];
				map_add(floors[floor - 1], type, x1, y1, x2, y2, 0.5, color);
				offset += room_add(room_mc, type, x1, y1, x2, y2, color, x, y);
			}
			textBox(room_mc, room_name, 0, 0, false);
		}
		room_mc.onPress = function(){
			if(Paused){
				// 動かせない！！
			}
			else{
				this.startDrag (false);
				this.swapDepths(3000);
			}
		};
		room_mc.onRelease = function(){
			stopDrag ();
			var dx = (this._x - allfloors._x) * 100 / zoom - this.to_x;
			var dy = (this._y - allfloors._y) * 100 / zoom - this.to_y;
			if (this.floor == nowfloor &&dx * dx + dy * dy < 2500){
				Data.koteltu.start();
				this._x = this.to_x;
				this._y = this.to_y;
				this.onPress = null;
				this.onRelease = null;
				this.onEnterFrame = null;
				var new_mc = floors[this.floor - 1].createEmptyMovieClip(this.name_en, this.num);
				textBox(new_mc, this.name_jp, this.to_x, this.to_y, false);
				complete ++;
				this.removeMovieClip();
			}
		};
		room_mc.onEnterFrame = function(){
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
	else{
		var room_num = area[3];
		var name = area[4];
		var room_name = area[5];
		var x;
		var y;
		if(area[6] == 'r'){
			var x1 = area[7];
			var y1 = area[8];
			var x2 = area[9];
			var y2 = area[10];
			x = (x1 + x2) / 2;
			y = (y1 + y2) / 2;
			map_add(floors[floor - 1], 'r', x1, y1, x2, y2, 0.5, color);
		}
		else if(area[6] == 'd'){
			x = area[7];
			y = area[8];
			var offset = 9;
			while (offset < area.length){
				var type = area[offset];
				if(type == 'c'){
					var x = area[offset + 1];
					var y = area[offset + 2];
					var r = area[offset + 3];
					var from = area[offset + 4] / 180 * Math.PI;
					var to = area[offset + 5] / 180 * Math.PI;
					drawCircle(floors[floor - 1], x, y, r, from, to, (color == 0x000000) ? 1 : 0, LColor, (color == 0x000000) ? 100 : 0, color, (color == 0x000000) ? 0 : 100);
					offset += 6;
					continue;
				}
				var x1 = area[offset + 1];
				var y1 = area[offset + 2];
				var x2 = area[offset + 3];
				var y2 = area[offset + 4];
				offset += map_add(floors[floor - 1], type, x1, y1, x2, y2, 0.5, color);
			}
		}
		var new_mc = floors[floor - 1].createEmptyMovieClip(name, room_num);
		textBox(new_mc, room_name, x, y, false);
	}
	if (areas.length == 0){
		loaded = true;
		Paused = false;
		this.onEnterFrame = null;
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

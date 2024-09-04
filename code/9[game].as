/* [8]game */


start.removeMovieClip();

areas = data.map.split('\n');


rooms = 0;
complete = 0; // マップ完成率 = complete / rooms

zoom = 30; // 拡大度 大きいほど大きくなる (小泉)

// マウスホイール回転時に拡大度を変えます
var listener = new Object();
listener.onMouseWheel = function(delta){
	var zoom_old = zoom;
	zoom = Math.max(10, Math.min(100, Math.pow(Math.E, Math.log(zoom) + delta / 10)));
	var mouse_x = _root._xmouse;
	var mouse_y = _root._ymouse;
	allfloors._x = allfloors._x - (mouse_x - allfloors._x) * (zoom / zoom_old - 1);
	allfloors._y = allfloors._y - (mouse_y - allfloors._y) * (zoom / zoom_old - 1);
};
Mouse.addListener(listener);


// 時間計測など
createEmptyMovieClip("main", 1000);
time = 0;
oldTime = 0;
main.onEnterFrame = function(){
	var nowTime = getTimer();
	if(stopped){
		// なにもしないよ
	}
	else{
		time += nowTime - oldTime;
		if (rooms == complete){
			data.tereen.start();
			popUp("complete!!\nクリアタイム：" + timeconvert(time), null);
			goresult._visible = true;
			main.onEnterFrame = null;
		}
	}
	oldTime = nowTime;
};

createEmptyMovieClip("timer", 1001);
timer.createMovieClip("reserve", 10);
data.myfont.size = 16;
textBox(timer, "準備中..", width / 24, height / 28 * 23, data.myfont, false);
data.myfont.size = defaultFontSize;
timer.onEnterFrame = function(){
	if (!stopped){
		var timestr = String(Math.floor(time / 100) / 10);
		if(timestr.charAt(timestr.length - 2) != '.'){
			timestr += ".0";
		}
		this.label0.text = timestr + "秒";
	}
};


// もどる
createEmptyMovieClip("back_game", 9);
drawRect(back_game, 0, height / 7 * 6, width / 12, height, 1, LColor, FColor);
textBox(back_game, "戻ﾙ", width / 24, height / 14 * 13, data.myfont, false);
back_game.onPress = function(){
	popUp("前の画面に戻りますか？\n進行状況は破棄されます", function(){
		_root.allfloors.removeMovieClip();
		_root.allrooms.removeMovieClip();
		_root.timer.removeMovieClip();
		_root.sfloor.removeMovieClip();
		while (floor_switch.length > 0){
			floor_switch.pop().removeMovieClip();
		}
		back_game.removeMovieClip();
		prevFrame();
	});
};


nowfloor = 1;


var sfloor = createEmptyMovieClip("selected_floor", 310);
sfloor._x = 0;
sfloor._y = - height;
sfloor.onEnterFrame = function(){
	if(this._y < 0) this._y = floor_switch[nowfloor - 1]._y;
	this._y -= (this._y - floor_switch[nowfloor - 1]._y) / 3;
};
sfloor.lineStyle(1, 0x00C000, 100);
sfloor.moveTo(4, 4);
sfloor.lineTo(width / 12 - 4, 4);
sfloor.lineTo(width / 12 - 4, height / 7 - 4);
sfloor.lineTo(4, height / 7 - 4);
sfloor.lineTo(4, 4);

floor_switch = new Array(0, 0, 0, 0, 0);
for(_3 in floor_switch){
	var floor = (Number(_3) + 1);
	floor_switch[_3] = createEmptyMovieClip("switch_" + floor, 300 + Number(_3));
	floor_switch[_3].floor = floor;
	floor_switch[_3]._y = height / 7 * _3;
	textBox(floor_switch[_3], ["０","１","２","３","４","５"][floor] + "F", width / 24, height / 14, data.myfont, false);
	drawRect(floor_switch[_3], 0.5, 0, width / 12, height / 7, 0.5, LColor, FColor);
	floor_switch[_3].onPress = function(){
		nowfloor = this.floor;
	};
}
listener.onKeyDown = function(){
	var Key = Key.getCode();
	if(49 <= Key && Key <= 53){
		nowfloor = Key - 48;
	}
};
Key.addListener(listener);

var allfloors = createEmptyMovieClip("allfloors", 200);
allfloors._x = width / 6;
allfloors._y = height / 36;
allfloors.onPress = function(){
	if(stopped){
		// うごかすもんか！
	}
	else{
		this.startDrag (false);
	}
};
allfloors.onEnterFrame = function(){
	this._xscale = zoom;
	this._yscale = zoom;
	if(this._width < width / 3 * 2){
		this._x = this._x - (this._x - Math.min(Math.max(this._x, width / 12), width / 12 * 9 - this._width)) / 10;
	}
	else{
		this._x = this._x - (this._x - Math.max(Math.min(this._x, width / 12), width / 12 * 9 - this._width)) / 10;
	}
	if(this._height < height){
		this._y = this._y - (this._y - Math.min(Math.max(this._y, 0), height - this._height)) / 10;
	}
	else{
		this._y = this._y - (this._y - Math.max(Math.min(this._y, 0), height - this._height)) / 10;
	}
};

floors = new Array(0, 0, 0, 0, 0);
for(_1 in floors){
	var floor = (Number(_1) + 1);
	floors[_1] = allfloors.createEmptyMovieClip("floor_" + floor, 201 + Number(_1));
	floors[_1].floor = floor;
	floors[_1].onEnterFrame = function(){
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
			drawRect(parent, x1, y1, x2, y2, line_width, LColor, color);
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

// マップは文字なし　右側にピース追加
function room_add(parent, type, x1, y1, x2, y2, color, x, y){
	var offset = 1;
	parent.lineStyle(1.5, 0x808080, 100);
	switch(type){
		case 'r':{
			drawRect(parent, x1 - x, y1 - y, x2 - x, y2 - y, 1.5, 0x808080, color);
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

// ムービークリップのonReleaseより正確にドラッグを止めてくれます (ムービークリップのほうはムービークリップ上でないと動かないのかも)
onMouseUp = function (){
	stopDrag ();
};

var loaded = false; // マップのロードが終わるまで待つ用
stopped = true;
lastfloor = 6;


createEmptyMovieClip("allrooms", 1099);


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
	if(darkmode){
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
				offset += map_add(floors[floor - 1], type, x, y, -1, -1, 1, color);
			}
			else{
				var x1 = area[offset + 1];
				var y1 = area[offset + 2];
				var x2 = area[offset + 3];
				var y2 = area[offset + 4];
				offset += map_add(floors[floor - 1], type, x1, y1, x2, y2, 0, color);
			}
		};
	}
	else if (mode > area[2]){
		if(mode == 4){
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
			room_mc._x = width / 3 * 2 + (width / 3 * Math.random());
			room_mc._y = height * Math.random();
			room_mc.to_x = x;
			room_mc.to_y = y;
			map_add(floors[floor - 1], 'r', x1, y1, x2, y2, 0.5, color);
			room_add(room_mc, 'r', x1, y1, x2, y2, color, x, y);
			textBox(room_mc, room_name, 0, 0, data.myfont, false);
		}
		else if(area[6] == 'd'){
			var x = area[7];
			var y = area[8];
			room_mc._x = width / 3 * 2 + (width / 3 * Math.random());
			room_mc._y = height * Math.random();
			room_mc.to_x = x;
			room_mc.to_y = y;
			var offset = 9;
			while (offset < area.length){
				var type = area[offset];
				var x1 = area[offset + 1];
				var y1 = area[offset + 2];
				var x2 = area[offset + 3];
				var y2 = area[offset + 4];
				map_add(floors[floor - 1], type, x1, y1, x2, y2, 0.5, color);
				offset += room_add(room_mc, type, x1, y1, x2, y2, color, x, y);
			}
			textBox(room_mc, room_name, 0, 0, data.myfont, false);
		}
		room_mc.onPress = function(){
			if(stopped){
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
				data.koteltu.start();
				this._x = this.to_x;
				this._y = this.to_y;
				this.onPress = null;
				this.onRelease = null;
				this.onEnterFrame = null;
				var new_mc = floors[this.floor - 1].createEmptyMovieClip(this.name_en, this.num);
				textBox(new_mc, this.name_jp, this.to_x, this.to_y, data.myfont, false);
				complete ++;
				this.removeMovieClip();
			}
		};
		room_mc.onEnterFrame = function(){
			if(mode == 4){
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
				var x1 = area[offset + 1];
				var y1 = area[offset + 2];
				var x2 = area[offset + 3];
				var y2 = area[offset + 4];
				offset += map_add(floors[floor - 1], type, x1, y1, x2, y2, 0.5, color);
			}
		}
		var new_mc = floors[floor - 1].createEmptyMovieClip(name, room_num);
		textBox(new_mc, room_name, x, y, data.myfont, false);
	}
	if (areas.length == 0){
		loaded = true;
		stopped = false;
		allrooms.onEnterFrame = null;
	}
}

createEmptyMovieClip("goresult", 100);
drawRect(goresult, width / 12 * 11, height / 7 * 6, width, height, 1, LColor, FColor);
textBox(goresult, "進ﾑ", width / 24 * 23, height / 14 * 13, data.myfont, false);
goresult.onPress = function(){
	goresult._visible = true;
	_root.allfloors.removeMovieClip();
	_root.allrooms.removeMovieClip();
	_root.timer.removeMovieClip();
	_root.sfloor.removeMovieClip();
	while (floor_switch.length > 0){
		floor_switch.pop().removeMovieClip();
	}
	back_game.removeMovieClip();
	gotoAndPlay("result");
};
goresult._visible = false;

stop();

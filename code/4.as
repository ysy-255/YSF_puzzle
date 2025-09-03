/* [4]読み込み準備 */

DataLoader_tf.text = "マップデータを読み込み中・・・";
DataLoader.lv = new LoadVars();
DataLoader.lv.onData = function(buf:String){
	Data.map = buf;
}

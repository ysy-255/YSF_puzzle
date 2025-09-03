/* [6]読み込み準備 */

DataLoader_tf.text = "サウンド(効果音)を読み込み中・・・";
Data.koteltu = new Sound();
Data.chirin = new Sound();
Data.koteltu.onLoad = function(){
	Data.koteltu.start(0.35);
};
Data.chirin.onLoad = function(){
	Data.chirin.start(0.8);
};

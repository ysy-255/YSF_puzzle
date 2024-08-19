/* [6]読み込み準備 */

loading.text = "サウンド(効果音)を読み込み中・・・";

data.koteltu = new Sound();
data.tereen = new Sound();
data.koteltu.onLoad = function(){
	data.koteltu.start(0.35);
};
data.tereen.onLoad = function(){
	data.tereen.start(0.8);
};

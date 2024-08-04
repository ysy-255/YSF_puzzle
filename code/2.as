/* [2]読み込み準備 */

createTextField("loading", 5, 0, (height - 36) / 2, width, (height + 36)/ 2);
loading.setNewTextFormat(format_temp);
loading.text = "フォントを読み込み中・・・";

// データ読み込み用ムービークリップ
data = createEmptyMovieClip("data", 1);

function split( val ) {
	return val.split( /,\s*/ );
}
function extractLast( term ) {
	return split( term ).pop();
}

// オートコンプリートで、複数アイテムを選択可能にするプラグイン
// NOTE: Vue.jsに対応するため無理やり改造
//       - Vue.jsのリアクティブに対応するため、Vueデータにセットする関数を渡せるようにしている
//       - DOMにプラグインをアタッチした時に多分ここのcreateが呼ばれてそこで値をセットしたときにVue dataを上書きしてしまうので、createの内容をコメントアウト（今の仕様では不要な処理だし）
jQuery.fn.autocompleteMultiple = function(taglist, setTagList) {
	this
		.autocomplete({
			minLength: 0, // 文字入力なしで↓キーを押すだけで候補が表示されるように
			create: function( event, ui ) {
				// value = this.value.split( /\s+/ ).join( ", " );
				// // this.value = xxx; にした場合はVue.jsを介さずに直接フィールドに値を設定
				// setTagList(value);
				return false;
			},
			source: function( request, response ) {
				// delegate back to autocomplete, but extract the last term
				response( $.ui.autocomplete.filter(
					taglist, extractLast( request.term ) ) );
			},
			focus: function() {
				// prevent value inserted on focus
				return false;
			},
			select: function( event, ui ) {
				var terms = split( this.value );
				// remove the current input
				terms.pop();
				// add the selected item
				terms.push( ui.item.value );
				// add placeholder to get the comma-and-space at the end
				terms.push( "" );
				value = terms.join( ", " );
				setTagList(value);
				return false;
			}
		});
}

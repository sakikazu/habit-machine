function split( val ) {
	return val.split( /,\s*/ );
}
function extractLast( term ) {
	return split( term ).pop();
}

jQuery.fn.autocompleteMultiple = function(taglist) {
	this
		.autocomplete({
			minLength: 0, // 文字入力なしで↓キーを押すだけで候補が表示されるように
			create: function( event, ui ) {
				this.value = this.value.split( /\s+/ ).join( ", " );
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
				this.value = terms.join( ", " );
				return false;
			}
		});
}

// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui/widgets/autocomplete
//= require rails-ujs
//= require turbolinks
//= require popper
//= require bootstrap-sprockets
//= require jquery.selection
//= require jquery.markdown-easily
//= require_tree .

// for best_in_place
//= require best_in_place
// NOTE: jQuery UI datepickersを使用する場合
// require best_in_place.jquery-ui

// lazy_high_charts
// NOTE: highchartsはhighstock内でincludeされてるから不要。-moreの方はわからないが動作に異常はないので無効にしとく
// require highcharts/highcharts
// require highcharts/highcharts-more
//= require highcharts/highstock

$(document).on('turbolinks:load', function() {
	// best_in_place内のpopoverを表示させてそのtextareaにフォーカスすると、popoverが表示されたままになってしまう問題の対処
	$('table.hm_top td.record').on('click', function() {
		$('.popover').hide();
	});

  $('[data-toggle="popover"]').popover({
    html: true,
  });

  $("a[rel=tooltip]").tooltip();

	$('.best_in_place').best_in_place()
	// textareaタイプの場合、turbolinksの遷移から戻った後に変更内容が失われる問題の対処
	$('.best_in_place').bind("ajax:success", function() {
		if ($(this).data('bip-type') != 'textarea') {
			return
		}
		// 正しい値はspan.best_in_place > aが持っている
		var updatedValue = $(this).children('a').first().data('content');
		// data-bip-original-contentを書き換えると、遷移後も値が正しいままとなる
		// data()メソッドでは書き換えができなかった
		$(this).attr('data-bip-original-content', updatedValue);
		// popoverが古い値もまま表示されたままになる問題があり、消すこともできないので、更新された値で再度表示できるようにする
		$(this).children('a').popover('update');
	});
})


// Diaryのフォームのタグフィールドに選択したタグ名をトグルで追加/削除する
toggleTag = function(tagname) {
  var $tag_input = $('input[name="diary[tag_list]"]');
  var inputted_tags_string = $tag_input.val();
  if (inputted_tags_string.length == 0) {
    $tag_input.val(tagname);
    return
  }
  var inputted_tags = inputted_tags_string.split(/\s*,\s*/);
  var find_idx = inputted_tags.indexOf(tagname);
  if (find_idx > -1) {
    inputted_tags.splice(find_idx, 1);
  } else {
    inputted_tags.push(tagname);
  }
  $tag_input.val(inputted_tags.join(', '));
}


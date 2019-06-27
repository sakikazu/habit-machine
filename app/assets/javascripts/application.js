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
  $('[data-toggle="popover"]').popover({
    html: true,
  });
  $("a[rel=tooltip]").tooltip();
  $('.best_in_place').best_in_place()

  //
  // for best_in_place
  //
  var shownPopoverElements = [];
  // セルをクリック時、recordのメモをポップアップ表示する
  // bipの入力フォームの場合はポップアップはせず、現在表示されているポップアップを非表示にする
  $('table.hm_top td.record').on('click', function(e) {
    if($(e.target).hasClass('record')) {
      var $ele = $(this).find('.habit-data');
      hidePopover(shownPopoverElements, $ele);
      $ele.popover('toggle');
      shownPopoverElements.push($ele);
    } else {
      hidePopover(shownPopoverElements);
    }
  });

  // bipがtextareaタイプの場合、turbolinksの遷移から戻った後に変更内容が失われる問題の対処
  // NOTE: 理由：bipは変更確定時、データをポストし、表示用であるdisplay_withの関数にのみ、変更後の値を保持するようだ
  //             でも、turbolinksで戻った時、textareaの値は、data-bip-original-content属性からセットされるので、
  //             diaplay_withの中の値をdata-bip-original-contentにセットすることで、正しくtextarea値をセットすることができる
  // NOTE: この中ではdata-*属性はdata()メソッドで書き換えできなかった。毎度datasetを使った方が良さそう
  $('.best_in_place').bind("ajax:success", function() {
    if ($(this).data('bip-type') != 'textarea') { return }

    // best_in_placeのtextarea編集を完了するには他の要素をクリックする必要があるが、
    // その際にPopoverが表示されてしまうので、それをこのタイミングで非表示にする
    hidePopover(shownPopoverElements);

    // 正しい値はspan.best_in_place > spanが持っている(display_withの中)
    var updatedValue = $(this).children('span').first().data('content');
    // 表示用の値を変更後のものにする
    $(this).parents('.record').children('.habit-data')[0].dataset.content = nl2br(updatedValue);
    // data-bip-original-contentを書き換えると、遷移後も値が正しいままとなる
    this.dataset.bipOriginalContent = updatedValue;
  });
})

hidePopover = function(elements, $withoutEle = null) {
  elements.forEach(function($popEle) {
    if ($withoutEle == null || !$popEle.is($withoutEle)) {
      $popEle.popover('hide');
    }
  });
}

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

showCurrentSenses = function() {
  $.ajax({
    type: 'GET',
    url: '/senses/current',
    success: function(html) {
      $('#current-senses.modal').remove();
      $('body').append(html);
      $('#current-senses.modal').modal('show');
    }
  });
}

nl2br = function(str) {
  str = str.replace(/\r\n/g, "<br />");
  str = str.replace(/(\n|\r)/g, "<br />");
  return str;
}

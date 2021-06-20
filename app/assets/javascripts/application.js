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
// used by tempusdominus-bootstrap-4.js
//= require moment.js
//= require moment-ja.js
// timepicker for bootstrap
//= require tempusdominus-bootstrap-4.js
//= require jquery.selection
//= require jquery.markdown-easily
//= require_tree .

// for lazy_high_charts
// NOTE: highchartsはhighstock内でincludeされてるから不要。-moreの方はわからないが動作に異常はないので無効にしとく
// require highcharts/highcharts
// require highcharts/highcharts-more
//= require highcharts/highstock

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover({
    html: true,
  });
  $("a[rel=tooltip]").tooltip();
  $('.toast').toast({});
  $('.modal').on('shown.bs.modal', () => {
    $(this).find('input.first-focus').focus();
  });
  $('.timepicker').datetimepicker({
    format: 'LT'
  });

  var shownPopoverElements = [];
  // セルをクリック時、recordのメモをポップアップ表示する
  $('table.hm_top .js-habit-data').on('click', function(e) {
    var $ele = $(this).find('.popover-content');
    hidePopover(shownPopoverElements, $ele);
    $ele.popover('toggle');
    shownPopoverElements.push($ele);
  });
})

hidePopover = function(elements, $withoutEle = null) {
  elements.forEach(function($popEle) {
    if ($withoutEle == null || !$popEle.is($withoutEle)) {
      $popEle.popover('hide');
    }
  });
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

const getTimestamp = function() {
  return new Date().getTime();
}


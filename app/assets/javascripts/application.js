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
//= require jquery.selection
//= require jquery.markdown-easily
//= require_tree .
// for lazy_high_charts
// NOTE: highchartsはhighstock内でincludeされてるから不要。-moreの方はわからないが動作に異常はないので無効にしとく
// require highcharts/highcharts
// require highcharts/highcharts-more
//= require highcharts/highstock

$(document).on('turbolinks:load', function() {
  $('[data-navigation-toggle]').off('click.navigation').on('click.navigation', function() {
    const target = document.querySelector(this.dataset.navigationToggle);
    if (!target) return;
    const open = !target.classList.contains('show');
    target.classList.toggle('show', open);
    this.setAttribute('aria-expanded', String(open));
  });

  $('[data-navigation-dropdown]').off('click.navigation').on('click.navigation', function(e) {
    e.preventDefault();
    const menu = this.nextElementSibling;
    if (!menu?.classList.contains('dropdown-menu')) return;
    const open = !menu.classList.contains('show');
    document.querySelectorAll('.navbar .dropdown-menu.show').forEach(function(otherMenu) {
      if (otherMenu !== menu) otherMenu.classList.remove('show');
    });
    document.querySelectorAll('[data-navigation-dropdown][aria-expanded="true"]').forEach(function(toggle) {
      if (toggle !== e.currentTarget) toggle.setAttribute('aria-expanded', 'false');
    });
    menu.classList.toggle('show', open);
    this.setAttribute('aria-expanded', String(open));
  });

  $(document).off('click.navigationOutside').on('click.navigationOutside', function(e) {
    if (e.target.closest('.navbar .dropdown')) return;
    document.querySelectorAll('.navbar .dropdown-menu.show').forEach(function(menu) {
      menu.classList.remove('show');
    });
    document.querySelectorAll('[data-navigation-dropdown][aria-expanded="true"]').forEach(function(toggle) {
      toggle.setAttribute('aria-expanded', 'false');
    });
  });

  // セルをクリック時、recordのメモをポップアップ表示する
  $('table.records-table .js-habit-data').off('click.recordMemo').on('click.recordMemo', function(e) {
    const currentPopover = this.querySelector('.record-memo-popover');
    if (!currentPopover) return;

    document.querySelectorAll('.record-memo-popover:not([hidden])').forEach(function(popover) {
      if (popover !== currentPopover) popover.hidden = true;
    });
    currentPopover.hidden = !currentPopover.hidden;
  });
  $(document).off('click.recordMemoOutside').on('click.recordMemoOutside', function(e) {
    if (e.target.closest('.js-habit-data')) return;
    document.querySelectorAll('.record-memo-popover:not([hidden])').forEach(function(popover) {
      popover.hidden = true;
    });
  });

  $('#globalSearchWord').on('click', () => {
    location.href = '/search';
  })
})

const getTimestamp = function() {
  return new Date().getTime();
}

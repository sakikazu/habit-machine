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
//= require rails-ujs
//= require turbolinks
//= require markdown-easily
//= require_tree .
// for lazy_high_charts
// NOTE: highchartsはhighstock内でincludeされてるから不要。-moreの方はわからないが動作に異常はないので無効にしとく
// require highcharts/highcharts
// require highcharts/highcharts-more
//= require highcharts/highstock

let applicationEventController

document.addEventListener('turbolinks:load', function() {
  applicationEventController?.abort()
  applicationEventController = new AbortController()

  document.addEventListener('click', function(event) {
    const navigationToggle = event.target.closest('[data-navigation-toggle]')
    if (navigationToggle) {
      const target = document.querySelector(navigationToggle.dataset.navigationToggle)
      if (!target) return
      const open = !target.classList.contains('show')
      target.classList.toggle('show', open)
      navigationToggle.setAttribute('aria-expanded', String(open))
      return
    }

    const dropdownToggle = event.target.closest('[data-navigation-dropdown]')
    if (dropdownToggle) {
      event.preventDefault()
      const menu = dropdownToggle.nextElementSibling
      if (!menu?.classList.contains('dropdown-menu')) return
      const open = !menu.classList.contains('show')
      document.querySelectorAll('.navbar .dropdown-menu.show').forEach(function(otherMenu) {
        if (otherMenu !== menu) otherMenu.classList.remove('show')
      })
      document.querySelectorAll('[data-navigation-dropdown][aria-expanded="true"]').forEach(function(toggle) {
        if (toggle !== dropdownToggle) toggle.setAttribute('aria-expanded', 'false')
      })
      menu.classList.toggle('show', open)
      dropdownToggle.setAttribute('aria-expanded', String(open))
      return
    }

    const habitData = event.target.closest('table.records-table .js-habit-data')
    if (habitData) {
      const currentPopover = habitData.querySelector('.record-memo-popover')
      if (!currentPopover) return
      document.querySelectorAll('.record-memo-popover:not([hidden])').forEach(function(popover) {
        if (popover !== currentPopover) popover.hidden = true
      })
      currentPopover.hidden = !currentPopover.hidden
      return
    }

    if (!event.target.closest('.navbar .dropdown')) {
      document.querySelectorAll('.navbar .dropdown-menu.show').forEach(function(menu) {
        menu.classList.remove('show')
      })
      document.querySelectorAll('[data-navigation-dropdown][aria-expanded="true"]').forEach(function(toggle) {
        toggle.setAttribute('aria-expanded', 'false')
      })
    }
    if (!event.target.closest('.js-habit-data')) {
      document.querySelectorAll('.record-memo-popover:not([hidden])').forEach(function(popover) {
        popover.hidden = true
      })
    }
    if (event.target.closest('#globalSearchWord')) location.href = '/search'
  }, { signal: applicationEventController.signal })
})

const getTimestamp = function() {
  return new Date().getTime();
}

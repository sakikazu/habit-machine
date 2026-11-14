import { createApp, h } from 'vue'
import FamilyPage from '../components/families/FamilyPage.vue'
import { mountVueOnTurbolinks } from 'vue_turbolinks.js'

// turbolinksでの二重初期化を避けるため、マウント済み判定を入れて初期化する
mountVueOnTurbolinks('#family-page', (pageElement) => {
  const overview = JSON.parse(pageElement.dataset.overview || '{}')
  const currentYear = Number(pageElement.dataset.currentYear)
  const currentMonth = Number(pageElement.dataset.currentMonth)

  return createApp({
    render: () => h(FamilyPage, {
      overview,
      currentYear,
      currentMonth
    })
  })
})

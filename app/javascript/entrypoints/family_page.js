import Vue from 'vue/dist/vue.esm'
import { onPageLoad } from '../helper.js'
import FamilyPage from '../components/families/FamilyPage.vue'

// turbolinks:loadを取り逃がすケースがあるので即時マウントも試す
const mountFamilyPage = () => {
  const pageElement = document.getElementById('family-page')
  if (!pageElement || pageElement.dataset.vueMounted === 'true') return
  pageElement.dataset.vueMounted = 'true'

  const overview = JSON.parse(pageElement.dataset.overview || '{}')
  const currentYear = Number(pageElement.dataset.currentYear)
  const currentMonth = Number(pageElement.dataset.currentMonth)

  new Vue({
    render: (h) => h(FamilyPage, {
      props: {
        overview,
        currentYear,
        currentMonth
      }
    })
  }).$mount(pageElement)
}

onPageLoad(mountFamilyPage)
// turbolinks後にscriptが読み込まれた場合のフォールバック
if (document.readyState !== 'loading') {
  mountFamilyPage()
}

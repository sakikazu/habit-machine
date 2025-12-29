import Vue from 'vue/dist/vue.esm'
import FamilyPage from '../components/families/FamilyPage.vue'

// turbolinksでの二重初期化を避けるため、マウント済み判定を入れて初期化する
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

document.addEventListener('turbolinks:load', mountFamilyPage)
// turbolinks:load発火後にscriptが読み込まれた場合の保険
if (document.readyState !== 'loading') {
  mountFamilyPage()
}

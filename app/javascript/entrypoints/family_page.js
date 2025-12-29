import Vue from 'vue/dist/vue.esm'
import { onPageLoad } from '../helper.js'
import FamilyPage from '../components/families/FamilyPage.vue'

onPageLoad(() => {
  const pageElement = document.getElementById('family-page')
  if (!pageElement) return

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
})

import Vue from 'vue/dist/vue.esm'
import { onPageLoad } from '../helper.js'
import FamilyDashboard from '../components/families/FamilyDashboard.vue'

onPageLoad(() => {
  const element = document.getElementById('family-dashboard')
  if (!element) return

  const currentYear = Number(element.dataset.currentYear)
  const currentMonth = Number(element.dataset.currentMonth)

  new Vue({
    render: (h) => h(FamilyDashboard, {
      props: {
        currentYear,
        currentMonth
      }
    })
  }).$mount(element)
})

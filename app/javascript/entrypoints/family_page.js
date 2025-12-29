import Vue from 'vue/dist/vue.esm'
import { onPageLoad } from '../helper.js'
import FamilyOverview from '../components/families/FamilyOverview.vue'
import FamilyDashboard from '../components/families/FamilyDashboard.vue'

onPageLoad(() => {
  const overviewElement = document.getElementById('family-overview')
  if (overviewElement) {
    const overview = JSON.parse(overviewElement.dataset.overview || '{}')
    new Vue({
      render: (h) => h(FamilyOverview, {
        props: {
          overview
        }
      })
    }).$mount(overviewElement)
  }

  const dashboardElement = document.getElementById('family-dashboard')
  if (!dashboardElement) return

  const currentYear = Number(dashboardElement.dataset.currentYear)
  const currentMonth = Number(dashboardElement.dataset.currentMonth)

  new Vue({
    render: (h) => h(FamilyDashboard, {
      props: {
        currentYear,
        currentMonth
      }
    })
  }).$mount(dashboardElement)
})

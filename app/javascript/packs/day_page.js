import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { nl2br } from 'helper.js'

const components = {
  HabitRecord: () => import('components/habits/HabitRecord'),
}

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#dayPage',
    components,
    data: {
      targetDate: null,
      habit_records: [],
    },
    computed: {
    },
    mounted () {
      this.targetDate = this.$el.dataset.targetDate
      this.fetchData()
    },
    methods: {
      nl2br,
      fetchData () {
        HmAxios.get(`/day_data/${this.targetDate}.json`)
          .then(res => {
            this.habit_records = res.data.habit_records
          })
          .catch(error => {
            console.log(error)
          })
      },
    },
  })
})

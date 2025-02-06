import Vue from 'vue'
import HmAxios from 'hm_axios.js'

import CategorizedDiaries from 'components/diaries/CategorizedDiaries'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#categorizedDiaries',
    components: {
      CategorizedDiaries,
    },
    data: {
      categories: [],
    },
    mounted () {
      this.categories = [
      ];
    }
  })
})

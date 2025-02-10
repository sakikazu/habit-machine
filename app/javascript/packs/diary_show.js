import Vue from 'vue'
import HmAxios from 'hm_axios.js'

import Diary from 'components/diaries/Diary'
import UrlCopyButton from 'components/shared/UrlCopyButton'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#diaryShow',
    components: {
      Diary,
      UrlCopyButton,
    },
    data: {
      categories: [],
    },
    mounted () {
      this.fetchCategories()
    },
    methods: {
      fetchCategories () {
        HmAxios.get('/categories/selection.json')
          .then(res => {
            this.categories = res.data.categories
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
          })
      },
    }
  })
})

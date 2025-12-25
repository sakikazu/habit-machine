import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { onPageLoad } from 'helper'

import Diary from 'components/diaries/Diary'

onPageLoad(() => {
  const vm = new Vue({
    el: '#diaryShow',
    components: {
      Diary,
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

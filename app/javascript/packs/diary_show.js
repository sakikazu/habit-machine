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
      diaryId: null,
      diary: null
    },
    mounted () {
      this.diaryId = this.$el.dataset.diaryId
      this.fetchData()
    },
    methods: {
      fetchData () {
        HmAxios.get(`/diaries/${this.diaryId}.json`)
          .then(res => {
            this.diary = res.data.diary
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
          })
      },
    }
  })
})

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
  })
})

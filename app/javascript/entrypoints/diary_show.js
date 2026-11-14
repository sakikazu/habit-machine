import { createApp } from 'vue'
import Diary from 'components/diaries/Diary'

document.addEventListener('turbolinks:load', () => {
  createApp({
    components: {
      Diary,
    },
    data () {
      return { categories: [] }
    },
  }).mount('#diaryShow')
})

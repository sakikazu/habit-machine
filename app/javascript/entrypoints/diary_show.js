import { createApp } from 'vue'
import Diary from 'components/diaries/Diary'
import { mountVueOnTurbolinks } from 'vue_turbolinks.js'

mountVueOnTurbolinks('#diaryShow', (element) => createApp({
    components: {
      Diary,
    },
    data () {
      return { categories: [] }
    },
}))

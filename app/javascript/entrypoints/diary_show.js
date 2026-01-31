import Vue from 'vue'
import Diary from 'components/diaries/Diary'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#diaryShow',
    components: {
      Diary,
    },
    data: {
      categories: [],
    },
  })
})

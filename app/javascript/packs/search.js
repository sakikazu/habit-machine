import Vue from 'vue/dist/vue.esm'
import HmAxios from '../hm_axios.js'
import { nl2br } from '../helper.js'

import Diary from 'components/diaries/Diary'
import Modal from 'components/shared/Modal'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#searchResult',
    components: {
      Diary,
      Modal,
    },
    data: {
      resultChildHistories: [],
      resultHabitodos: [],
      resultDiaries: [],
      resultRecords: [],
      selectedDetailData: null,
      modalableDiaryId: null,
    },
    computed: {
    },
    mounted () {
      this.setStickyNav()
      this.setFocus()
    },
    methods: {
      nl2br,
      searchContent(contentType, searchWord) {
        HmAxios.get(`/search/${contentType}.json?q=${searchWord}`)
          .then(res => {
            // console.log(res)
            switch(contentType) {
              case 'child_history':
                this.resultChildHistories = res.data
                break
              case 'habitodo':
                this.resultHabitodos = res.data
                break
              case 'diary':
                this.resultDiaries = res.data
                break
              case 'record':
                this.resultRecords = res.data
                break
            }
          })
          .catch(error => {
            console.log(error)
          })
      },
      openDetail(data, event) {
        const targetElements = document.querySelectorAll('.result > ul > li')
        targetElements.forEach(elm => {
          elm.classList.remove('active')
        })
        event.target.closest('li').classList.add('active')

        // NOTE: ベストは、contentTypeに応じたComponentを表示するのがいいかな
        this.selectedDetailData = data
      },
      closeDetail() {
        // NOTE: articleをflex-grow:1したら、ここでwidthをいじる必要なくなった。でもopenの時は必要。なぜかはわからない
        this.selectedDetailData = null
      },
      // ページメニューを上部に固定（ある程度スクロールしたら、最上部に張り付く挙動）
      setStickyNav () {
        const resultHeader = document.querySelector('.searchResult-header')
        const globalHeaderHeight = document.querySelector('nav.navbar').clientHeight
        $(window).on('scroll', () => {
          if($(window).scrollTop() > globalHeaderHeight) {
            resultHeader.classList.add('fixed')
          } else {
            resultHeader.classList.remove('fixed')
          }
        })
        // 途中までスクロールしている状態でリロードされた時のために、スクロールイベントを発生させる
        // 当ページについてはリロードで検索結果が消えるので不要だが
        $(window).trigger('scroll')
      },
      showDiaryModal (diaryId) {
        this.modalableDiaryId = diaryId
      },
      closeDiaryModal () {
        this.modalableDiaryId = null
      },
      setFocus () {
        if (location.search === '') {
          this.$refs.searchField.focus()
        }
      },
      // TODO: 検索結果に反映するには、ハイライト処理した独自のデータを返す必要があったので、とりあえず後で
      reflectResultDiaries (_formKey, updatedDiary) {
        let foundIndex = this.resultDiaries.findIndex(diary => diary.id == updatedDiary.id)
        Vue.set(this.resultDiaries, foundIndex, updatedDiary)
      },
    }
  })
})

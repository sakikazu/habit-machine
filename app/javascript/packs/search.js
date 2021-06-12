import Vue from 'vue/dist/vue.esm'
import HmAxios from '../hm_axios.js'
import { nl2br } from '../helper.js'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#searchResult',
    components: {
    },
    data: {
      resultHabitodos: [],
      resultDiaries: [],
      resultRecords: [],
      initialArticleWidth: null,
      articleView: null,
      detailView: null,
      selectedDetailData: null,
    },
    computed: {
      detailWidth () {
        const minWidth = Number(this.detailView.dataset.minWidth)
        const maxWidth = Number(this.detailView.dataset.maxWidth)
        return window.innerWidth < 1400 ? minWidth : maxWidth
      },
    },
    mounted () {
      this.articleView = document.querySelector('#searchResult > article')
      this.initialArticleWidth = this.articleView.clientWidth
      this.detailView = document.querySelector('#detail')
      this.setDetailViewHeight()
    },
    methods: {
      nl2br,
      setDetailViewHeight () {
        const currentVisibleHeight = window.innerHeight - document.querySelector('nav.navbar').clientHeight
        document.querySelector('.detailInner').style.height = `${currentVisibleHeight}px`
        const detailInnerMargin = document.querySelector('.detailHeader').clientHeight + 65
        document.querySelector('.detailContent').style.height = `${currentVisibleHeight - detailInnerMargin}px`
      },
      searchContent(contentType, searchWord) {
        HmAxios.get(`/search/${contentType}.json?q=${searchWord}`)
          .then(res => {
            console.log(res)
            switch(contentType) {
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

        // TODO: detailの部分にwidth/flex-basisをつけておいて、表示されたらarticleが自動でその部分縮小して欲しかったが、JSでやるしかないんだったけ？
        if (!this.selectedDetailData) {
          // NOTE: ここ、一回設定すれば、サイドバーを閉じて開いてもwidthは失われないかも。良い判定が知りたい
          this.articleView.style.width = `${this.initialArticleWidth - this.detailWidth}px`
          this.detailView.style.width = `${this.detailWidth}px`
        }
        // NOTE: ベストは、contentTypeに応じたComponentを表示するのがいいかな
        this.selectedDetailData = data
      },
      closeDetail() {
        // NOTE: articleをflex-grow:1したら、ここでwidthをいじる必要なくなった。でもopenの時は必要。なぜかはわからない
        this.selectedDetailData = null
      },
    }
  })
})

import Vue from 'vue'
import { deleteKeysWithPrefix } from 'local_storage_manager.js'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#child-history-form',
    mounted () {
      $('#content-field').markdownEasily()
      this.setLocalStorage()
    },
    methods: {
      // TODO: slimで書いてたものを移行してきただけのものなので、Vue風に書き換える
      // LocalStorageを使って未保存データの消失防止。一度submitしたら、LSのChildHistory関連データは削除
      setLocalStorage() {
        const historyId = this.$el.dataset.historyId
        const lsTitleKey = historyId ? `child-history-title-${historyId}` : `child-history-title-new`
        const lsContentKey = historyId ? `child-history-content-${historyId}` : `child-history-content-new`
        const titleField = document.getElementById('title-field')
        const contentField = document.getElementById('content-field')
        const childHistoryForm = document.getElementById('child-history-form')

        titleField.addEventListener('input', (event) => {
          localStorage.setItem(lsTitleKey, event.target.value)
        })
        contentField.addEventListener('input', (event) => {
          localStorage.setItem(lsContentKey, event.target.value)
        })
        childHistoryForm.addEventListener('submit', (event) => {
          deleteKeysWithPrefix('child-history-')
        })

        const childHistoryTitle = localStorage.getItem(lsTitleKey)
        const childHistoryContent = localStorage.getItem(lsContentKey)

        // 編集時のみ、LSデータで上書きしていいか確認を表示
        // TODO: 現状、この確認メッセージが出るタイミングがおかしかったりするが、クリティカルではないので、一旦スルー
        if (historyId && (childHistoryTitle || childHistoryContent)) {
          if (!confirm('未保存のデータがあります。復元しますか？')) {
            return
          }
        }
        if (childHistoryTitle) {
          titleField.value = childHistoryTitle
        }
        if (childHistoryContent) {
          contentField.value = childHistoryContent
        }
      },
    },
  })
})


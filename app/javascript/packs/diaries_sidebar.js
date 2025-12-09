import Vue from 'vue'
import HmAxios from 'hm_axios.js'

import TaskDiary from 'components/diaries/TaskDiary'

document.addEventListener('turbolinks:load', () => {
  const el = document.getElementById('diariesSidebar')
  if (!el) return

  new Vue({
    el,
    template: `
      <div>
        <div class="page-header">
          <h4>
            <span class="mr-2">
              <i class="fa fa-thumb-tack"></i>
            </span>
            固定
            <small class="ml-3"><a href="/diaries/pinned">[管理]</a></small>
          </h4>
        </div>
        <div class="diaries">
          <div class="mb-1" v-for="diary in diaries" :key="diary.id">
            <task-diary :diary="diary" @updated="onUpdated" @show-diary-modal="showDiaryModal" />
          </div>
        </div>
      </div>
    `,
    components: {
      TaskDiary,
    },
    data: {
      diaries: [],
    },
    mounted () {
      this.fetchPinned()
      window.addEventListener('sidebar-refresh', this.fetchPinned)
    },
    methods: {
      fetchPinned () {
        HmAxios.get('/diaries/pinned.json')
          .then(res => {
            this.diaries = res.data.diaries || res.data
          })
          .catch(error => {
            alert(error.message || error?.response?.data?.message)
          })
      },
      onUpdated (_payload) {
        this.fetchPinned()
        if (_payload?.message) {
          window.dispatchEvent(new CustomEvent('sidebar-toast', { detail: { isError: false, message: _payload.message } }))
        }
      },
      showDiaryModal (diaryId) {
        window.dispatchEvent(new CustomEvent('open-diary-modal', { detail: { diaryId } }))
      }
    }
  })
})

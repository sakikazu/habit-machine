import Vue from 'vue'
import HmAxios from 'hm_axios.js'

import TaskDiary from 'components/diaries/TaskDiary'

document.addEventListener('turbolinks:load', () => {
  const el = document.getElementById('diariesSidebar')
  if (!el) return
  // NOTE: data-turbolinks-permanentで復元されたDOMには既にVueインスタンスがぶら下がっているので再マウントを避ける
  if (el.__vue__) return

  new Vue({
    el,
    template: `
      <div id="diariesSidebar">
        <div class="page-header">
          <h4>
            <span class="mr-2">
              <i class="fa fa-star"></i>
            </span>
            お気に入り
          </h4>
        </div>
        <div class="diaries mb-4 favorite-list">
          <div v-if="favorites.length === 0" class="text-muted small">まだお気に入りはありません</div>
          <div class="favorite-item mb-2 p-2" v-for="fav in favorites" :key="fav.type + '-' + fav.id">
            <a v-if="fav.type === 'History' && fav.path" :href="fav.path" class="d-flex align-items-center">
              <i class="mr-2" :class="iconClass(fav)"></i>
              <div>
                <div class="font-weight-bold">{{ fav.title }}</div>
                <div class="text-muted small">
                  <span v-if="fav.member" class="mr-1">({{ fav.member }})</span>{{ fav.date }}
                </div>
              </div>
            </a>
            <a v-else href="javascript:void(0)" @click.prevent="openFavorite(fav)" class="d-flex align-items-center">
              <i class="mr-2" :class="iconClass(fav)"></i>
              <div>
                <div class="font-weight-bold">{{ fav.title }}</div>
                <div class="text-muted small">{{ fav.date }}</div>
              </div>
            </a>
          </div>
        </div>
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
      favorites: [],
    },
    mounted () {
      this.fetchPinned()
      // main/day_page側へ依頼されたリフレッシュイベントを拾って最新の固定日記を取得
      window.addEventListener('sidebar-refresh', this.fetchPinned)
      this.fetchFavorites()
      window.addEventListener('favorites-refresh', this.fetchFavorites)
    },
    destroyed () {
      window.removeEventListener('sidebar-refresh', this.fetchPinned)
      window.removeEventListener('favorites-refresh', this.fetchFavorites)
    },
    methods: {
      // 固定日記一覧をサーバーから再取得してサイドバーを更新
      fetchPinned () {
        HmAxios.get('/diaries/pinned.json')
          .then(res => {
            this.diaries = res.data.diaries || res.data
          })
          .catch(error => {
            alert(error.message || error?.response?.data?.message)
          })
      },
      fetchFavorites () {
        HmAxios.get('/favorites.json')
          .then(res => {
            this.favorites = res.data.favorites || []
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
      },
      openFavorite (fav) {
        if (fav.type === 'Diary') {
          this.showDiaryModal(fav.id)
        } else if (fav.path) {
          window.location.href = fav.path
        }
      },
      iconClass (fav) {
        return fav.type === 'History' ? 'fa fa-history' : 'fa fa-book'
      }
    }
  })
})

// Scoped styles for favorites list
const style = document.createElement('style')
style.innerHTML = `
  .sectionPinnedDiaries .favorite-list .favorite-item {
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    background: #f9fafb;
    transition: background-color 0.15s ease, box-shadow 0.15s ease;
    display: block;
  }
  .sectionPinnedDiaries .favorite-list .favorite-item:hover {
    background: #fff;
    box-shadow: 0 4px 10px rgba(0,0,0,0.06);
  }
  .sectionPinnedDiaries .favorite-list .favorite-item a {
    color: inherit;
    text-decoration: none;
  }
  .sectionPinnedDiaries .favorite-list .favorite-item a:hover {
    text-decoration: none;
  }
`
document.head.appendChild(style)

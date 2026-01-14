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
          <div class="favorite-item mb-2 p-2 clickable" v-for="fav in favorites" :key="fav.type + '-' + fav.id" @click.prevent="openFavorite(fav)">
            <div class="d-flex align-items-start">
              <i class="mr-2 mt-1" :class="iconClass(fav)"></i>
              <div>
                <div class="font-weight-bold">{{ fav.title }}</div>
                <div class="text-muted small">
                  <span v-if="fav.member" class="mr-1">({{ fav.member }})</span>{{ fav.date }}
                </div>
              </div>
            </div>
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
      activeHistory: null,
      historyFavoriteUpdating: false,
    },
    mounted () {
      this.fetchPinned()
      // main/day_page側へ依頼されたリフレッシュイベントを拾って最新の固定日記を取得
      window.addEventListener('sidebar-refresh', this.fetchPinned)
      this.fetchFavorites()
      window.addEventListener('favorites-refresh', this.fetchFavorites)
      window.addEventListener('history-appended', this.onHistoryAppended)
    },
    destroyed () {
      window.removeEventListener('sidebar-refresh', this.fetchPinned)
      window.removeEventListener('favorites-refresh', this.fetchFavorites)
      window.removeEventListener('history-appended', this.onHistoryAppended)
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
        } else {
          this.showHistoryModal(fav)
        }
      },
      openHistoryEdit (fav) {
        if (fav.edit_path) {
          window.location.href = fav.edit_path
        }
      },
      iconClass (fav) {
        return fav.type === 'History' ? 'fa fa-history' : 'fa fa-book'
      },
      showHistoryModal (fav) {
        this.activeHistory = Object.assign({}, fav, { favorited: true })
        this.renderHistoryModal()
      },
      closeHistoryModal () {
        this.activeHistory = null
        $('#historyFavoriteModal').modal('hide')
      },
      renderHistoryModal () {
        if (!this.activeHistory) return
        const titleEl = document.getElementById('historyFavoriteTitle')
        const metaEl = document.getElementById('historyFavoriteMeta')
        const contentEl = document.getElementById('historyFavoriteContent')
        const anchorEl = document.getElementById('historyFavoriteAnchor')
        const editEl = document.getElementById('historyFavoriteEdit')
        const appendEl = document.getElementById('historyFavoriteAppend')
        const favoriteToggleEl = document.getElementById('historyFavoriteToggle')

        if (titleEl) titleEl.textContent = this.activeHistory.title
        if (metaEl) metaEl.textContent = `${this.activeHistory.member ? '(' + this.activeHistory.member + ') ' : ''}${this.activeHistory.date || ''}`
        this.updateHistoryContent(contentEl)
        if (anchorEl) {
          anchorEl.href = this.activeHistory.path || '#'
          anchorEl.classList.toggle('disabled', !this.activeHistory.path)
        }
        if (editEl) {
          editEl.href = this.activeHistory.edit_path || '#'
          editEl.classList.toggle('disabled', !this.activeHistory.edit_path)
        }
        if (appendEl) {
          appendEl.onclick = (e) => {
            e.preventDefault()
            window.dispatchEvent(new CustomEvent('open-history-append', { detail: { history: this.activeHistory } }))
          }
        }
        if (favoriteToggleEl) {
          favoriteToggleEl.onclick = (e) => {
            e.preventDefault()
            this.toggleHistoryFavorite()
          }
          this.updateHistoryFavoriteButton(favoriteToggleEl, this.activeHistory.favorited)
        }
        $('#historyFavoriteModal').modal('show')
      },
      // 履歴モーダルのお気に入り状態を反映する
      updateHistoryFavoriteButton (element, favorited) {
        if (!element) return
        element.classList.toggle('is-favorited', favorited)
        element.innerHTML = favorited ? '<i class="fa fa-star mr-1"></i>お気に入り解除' : '<i class="fa fa-star-o mr-1"></i>お気に入り'
      },
      // 履歴のお気に入りを切り替える
      toggleHistoryFavorite () {
        if (!this.activeHistory || this.historyFavoriteUpdating) return
        this.historyFavoriteUpdating = true
        const payload = {
          favoritable_type: 'History',
          favoritable_id: this.activeHistory.id
        }
        const request = this.activeHistory.favorited
          ? HmAxios.delete('/favorites', { data: payload })
          : HmAxios.post('/favorites', payload)

        request
          .then(res => {
            const favorited = !!res.data?.favorited
            this.activeHistory.favorited = favorited
            const favoriteToggleEl = document.getElementById('historyFavoriteToggle')
            this.updateHistoryFavoriteButton(favoriteToggleEl, favorited)
            window.dispatchEvent(new CustomEvent('favorites-refresh'))
          })
          .catch(error => {
            alert(error.message || error?.response?.data?.message)
          })
          .finally(() => {
            this.historyFavoriteUpdating = false
          })
      },
      // 履歴モーダル本文の描画を統一する
      updateHistoryContent (contentEl) {
        if (!contentEl) return
        const contentHtml = this.activeHistory?.content_html
        contentEl.classList.toggle('history-favorite-content--plain', !contentHtml)
        if (contentHtml) {
          contentEl.innerHTML = contentHtml
        } else {
          contentEl.textContent = this.activeHistory?.content || ''
        }
      },
      onHistoryAppended (event) {
        const updated = event?.detail
        if (!updated?.id || !this.activeHistory || this.activeHistory.id !== updated.id) return
        this.activeHistory.content = updated.content || ''
        this.activeHistory.content_html = updated.content_html || ''
        const contentEl = document.getElementById('historyFavoriteContent')
        this.updateHistoryContent(contentEl)
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
    cursor: pointer;
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
  /* お気に入り履歴モーダルの操作ボタンを整理 */
  .history-favorite-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }
  .history-favorite-actions__primary {
    background: #2563eb;
    border-color: #2563eb;
    color: #fff;
  }
  .history-favorite-actions__append {
    background: #0ea5e9;
    border-color: #0ea5e9;
    color: #fff;
  }
  .history-favorite-actions__append:hover {
    background: #0284c7;
    border-color: #0284c7;
    color: #fff;
  }
  .history-favorite-actions__secondary {
    background: #f3f4f6;
    border-color: #e5e7eb;
    color: #374151;
  }
  .history-favorite-actions__favorite {
    border-color: #f1e3cf;
    background: #fff;
    color: #c79a43;
  }
  .history-favorite-actions__favorite.is-favorited {
    background: #f7c062;
    border-color: #f7c062;
    color: #fff;
  }
  .history-favorite-content--plain {
    white-space: pre-line;
  }
`
document.head.appendChild(style)

// Append a simple modal container for history view
const modalTemplate = `
  <div class="modal fade" id="historyFavoriteModal" tabindex="-1" role="dialog" aria-hidden="true" style="display:none;">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            <i class="fa fa-history mr-2"></i>
            <span id="historyFavoriteTitle"></span>
          </h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="text-muted mb-2" id="historyFavoriteMeta"></div>
          <div id="historyFavoriteContent"></div>
        </div>
        <div class="modal-footer history-favorite-actions">
          <a id="historyFavoriteAppend" class="btn history-favorite-actions__append">追記</a>
          <a id="historyFavoriteToggle" class="btn history-favorite-actions__favorite">お気に入り解除</a>
          <a id="historyFavoriteAnchor" class="btn history-favorite-actions__secondary" target="_blank" rel="noopener">履歴ページへ</a>
          <a id="historyFavoriteEdit" class="btn history-favorite-actions__primary">編集</a>
        </div>
      </div>
    </div>
  </div>
`

document.addEventListener('turbolinks:load', () => {
  if (!document.getElementById('historyFavoriteModal')) {
    document.body.insertAdjacentHTML('beforeend', modalTemplate)
  }
})

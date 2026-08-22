<template>
  <section class="family-dashboard">
    <header class="family-dashboard__header">
      <div>
        <h3 class="family-dashboard__title">家族の記録</h3>
      </div>
      <button type="button" class="family-dashboard__add" @click="openFormModal">
        記録する
      </button>
    </header>

    <button type="button" class="family-dashboard__filter-toggle" @click="toggleFilters">
      {{ filtersOpen ? '条件を閉じる' : '条件で絞り込む' }}
    </button>

    <div class="family-dashboard__display-modes" aria-label="表示方法">
      <button
        type="button"
        class="family-dashboard__display-mode"
        :class="{ 'is-active': displayMode === 'card' }"
        :aria-pressed="(displayMode === 'card').toString()"
        @click="changeDisplayMode('card')"
      >
        通常表示
      </button>
      <button
        type="button"
        class="family-dashboard__display-mode"
        :class="{ 'is-active': displayMode === 'title' }"
        :aria-pressed="(displayMode === 'title').toString()"
        @click="changeDisplayMode('title')"
      >
        タイトル一覧
      </button>
    </div>

    <div class="family-dashboard__controls" :class="{ 'is-open': filtersOpen }">
      <div class="family-dashboard__control">
        <label class="family-dashboard__label">メンバー</label>
        <div class="family-dashboard__member-list">
          <label
            v-for="option in memberOptions"
            :key="optionKey(option)"
            class="family-dashboard__member-pill"
          >
            <input
              type="checkbox"
              class="family-dashboard__member-input"
              :value="optionKey(option)"
              v-model="selectedMemberKeys"
              @change="onMemberSelectionChange"
            >
            <span class="family-dashboard__member-label">{{ option.name }}</span>
          </label>
        </div>
      </div>

      <div class="family-dashboard__control family-dashboard__calendar">
        <label class="family-dashboard__label">年月</label>
        <div class="family-dashboard__years">
          <button
            v-for="year in visibleYears"
            :key="year"
            type="button"
            class="family-dashboard__year"
            :class="{ 'is-active': year === selectedYear }"
            @click="toggleYear(year)"
          >
            {{ year }}年
          </button>
          <button
            v-if="hasMoreYears"
            type="button"
            class="family-dashboard__year family-dashboard__year--more"
            @click="showAllYears = true"
          >
            もっと見る
          </button>
        </div>
        <div v-if="selectedYear" class="family-dashboard__months">
          <button
            v-for="month in months"
            :key="month"
            type="button"
            class="family-dashboard__month"
            :class="{ 'is-active': month === selectedMonth }"
            @click="toggleMonth(month)"
          >
            <span>{{ month }}月</span>
            <span class="family-dashboard__count">{{ monthCounts[month] || 0 }}</span>
          </button>
        </div>
      </div>
      <button type="button" class="family-dashboard__submit" @click="applyFilters">
        この条件で検索
      </button>
    </div>

    <div v-if="showMemberAges" class="family-dashboard__member-ages">
      <div class="family-dashboard__member-ages-header">
        <span class="family-dashboard__member-ages-date">
          {{ appliedYear }}年{{ appliedMonth }}月
        </span>
        <span class="family-dashboard__member-ages-suffix">時点の年齢</span>
      </div>
      <div class="family-dashboard__member-ages-list">
        <span
          v-for="age in memberAges"
          :key="`age-${age.type}-${age.id}`"
          class="family-dashboard__member-age"
        >
          <span class="family-dashboard__member-age-name">{{ age.name }}</span>
          <span class="family-dashboard__member-age-value">{{ age.age_label }}</span>
        </span>
      </div>
    </div>

    <div class="family-dashboard__list">
      <div v-if="loading" class="family-dashboard__loading">読み込み中...</div>
      <div v-else-if="histories.length === 0" class="family-dashboard__empty">記録はありません。</div>
      <div v-else-if="displayMode === 'card'" class="family-dashboard__cards">
        <article v-for="history in histories" :key="history.id" :id="historyCardId(history)" class="family-dashboard__card">
          <div class="family-dashboard__card-header">
            <div class="family-dashboard__date-group">
              <span v-if="history.about_date" class="family-dashboard__approx">(だいたい)</span>
              <span class="family-dashboard__date">{{ history.target_date_label || history.target_date }}</span>
              <span
                v-for="name in memberNamePills(history)"
                :key="`${history.id}-${name}`"
                class="family-dashboard__member"
              >
                {{ name }}
              </span>
              <span v-if="history.author_name" class="family-dashboard__author">by {{ history.author_name }}</span>
            </div>
            <div class="family-dashboard__card-actions">
              <button
                type="button"
                class="family-dashboard__favorite"
                :class="{ 'is-favorited': history.favorited }"
                @click="toggleFavorite(history)"
              >
                <i :class="history.favorited ? 'fa fa-star' : 'fa fa-star-o'"></i>
              </button>
              <button
                type="button"
                class="family-dashboard__edit"
                aria-label="編集"
                @click="openHistoryModal(history, 'edit')"
              >
                <i class="fa fa-pencil-square-o"></i>
              </button>
            </div>
          </div>
          <h4 class="family-dashboard__card-title">
            <button type="button" class="family-dashboard__title-button" @click="openHistoryModal(history)">{{ history.title }}</button>
          </h4>
          <p v-if="history.height || history.weight" class="family-dashboard__metrics">
            <span v-if="history.height">{{ history.height }}cm</span>
            <span v-if="history.weight" class="family-dashboard__metric-separator">{{ history.weight }}kg</span>
          </p>
          <p v-if="history.content_html || history.content" class="family-dashboard__card-body" v-html="history.content_html || nl2br(history.content)"></p>
          <img v-if="history.eyecatch_url" :src="history.eyecatch_url" alt="" class="family-dashboard__card-image">
        </article>
      </div>
      <div v-else class="family-dashboard__title-list">
        <article v-for="history in histories" :key="history.id" :id="historyCardId(history)" class="family-dashboard__title-row">
          <div class="family-dashboard__title-row-main">
            <button type="button" class="family-dashboard__title-link" @click="openHistoryModal(history)">{{ history.title }}</button>
            <div class="family-dashboard__title-meta">
              <span v-if="history.about_date" class="family-dashboard__approx">(だいたい)</span>
              <span class="family-dashboard__date">{{ history.target_date_label || history.target_date }}</span>
              <span
                v-for="name in memberNamePills(history)"
                :key="`${history.id}-${name}`"
                class="family-dashboard__member"
              >
                {{ name }}
              </span>
              <span v-if="history.author_name" class="family-dashboard__author">by {{ history.author_name }}</span>
            </div>
          </div>
          <button
            type="button"
            class="family-dashboard__favorite"
            :class="{ 'is-favorited': history.favorited }"
            :aria-label="history.favorited ? 'お気に入りを解除' : 'お気に入りに追加'"
            @click="toggleFavorite(history)"
          >
            <i :class="history.favorited ? 'fa fa-star' : 'fa fa-star-o'"></i>
          </button>
        </article>
      </div>

      <div v-if="showPagination" class="family-dashboard__pagination">
        <button
          type="button"
          class="family-dashboard__pager"
          :disabled="pagination.page <= 1"
          @click="changePage(pagination.page - 1)"
        >
          前へ
        </button>
        <span class="family-dashboard__page-info">
          {{ pagination.page }} / {{ pagination.total_pages }}
        </span>
        <button
          type="button"
          class="family-dashboard__pager"
          :disabled="pagination.page >= pagination.total_pages"
          @click="changePage(pagination.page + 1)"
        >
          次へ
        </button>
      </div>
    </div>

    <Modal v-if="showFormModal" :no-padding="true" @on-close="closeFormModal">
      <template #content>
        <div class="family-dashboard__modal-body family-dashboard__modal-body--create">
          <div v-if="formLoading" class="family-dashboard__loading">フォームを読み込み中...</div>
          <div v-else v-html="formHtml"></div>
        </div>
      </template>
    </Modal>

    <Modal v-if="showHistoryModal" :no-padding="true" @on-close="closeHistoryModal">
      <template #content>
        <div class="family-dashboard__modal-body family-dashboard__modal-body--history">
          <div v-if="historyModalLoading" class="family-dashboard__loading">記録を読み込み中...</div>
          <template v-else-if="historyModalMode === 'view' && selectedHistory">
            <div class="family-dashboard__detail-header">
              <div class="family-dashboard__detail-meta">
                <span v-if="selectedHistory.about_date" class="family-dashboard__approx">(だいたい)</span>
                <span class="family-dashboard__date">{{ selectedHistory.target_date_label || selectedHistory.target_date }}</span>
                <span
                  v-for="name in memberNamePills(selectedHistory)"
                  :key="`detail-${selectedHistory.id}-${name}`"
                  class="family-dashboard__member"
                >
                  {{ name }}
                </span>
                <span v-if="selectedHistory.author_name" class="family-dashboard__author">by {{ selectedHistory.author_name }}</span>
              </div>
              <button type="button" class="family-dashboard__detail-edit" @click="switchHistoryModalToEdit">
                編集
              </button>
            </div>
            <h3 class="family-dashboard__detail-title">{{ selectedHistory.title }}</h3>
            <p v-if="selectedHistory.height || selectedHistory.weight" class="family-dashboard__metrics">
              <span v-if="selectedHistory.height">{{ selectedHistory.height }}cm</span>
              <span v-if="selectedHistory.weight" class="family-dashboard__metric-separator">{{ selectedHistory.weight }}kg</span>
            </p>
            <img v-if="selectedHistory.eyecatch_url" :src="selectedHistory.eyecatch_url" alt="" class="family-dashboard__detail-image">
            <div v-if="selectedHistory.content_html" class="family-dashboard__detail-content markdown" v-html="selectedHistory.content_html"></div>
          </template>
          <template v-else-if="historyModalMode === 'edit'">
            <button type="button" class="family-dashboard__detail-back" @click="switchHistoryModalToView">
              ← 閲覧に戻る
            </button>
            <div v-if="editLoading" class="family-dashboard__loading">フォームを読み込み中...</div>
            <div v-else v-html="editHtml"></div>
            <div v-if="!editLoading" class="family-dashboard__danger-zone">
              <button
                type="button"
                class="family-dashboard__delete"
                :disabled="historyDeleting"
                @click="deleteHistory"
              >
                {{ historyDeleting ? '削除中...' : 'この記録を削除' }}
              </button>
            </div>
          </template>
        </div>
      </template>
    </Modal>
  </section>
</template>

<script>
import HmAxios from '../../hm_axios.js'
import { nl2br } from '../../helper.js'
import Modal from '../shared/Modal'

export default {
  components: {
    Modal
  },
  props: {
    currentYear: {
      type: Number,
      required: true
    },
    currentMonth: {
      type: Number,
      required: true
    }
  },
  data () {
    return {
      memberOptions: [],
      selectedMemberKeys: [],
      appliedMemberKeys: [],
      years: [],
      showAllYears: false,
      selectedYear: null,
      selectedMonth: null,
      appliedYear: null,
      appliedMonth: null,
      monthCounts: {},
      memberAges: [],
      histories: [],
      pagination: null,
      loading: false,
      showFormModal: false,
      formHtml: '',
      formLoading: false,
      showHistoryModal: false,
      historyModalMode: 'view',
      historyModalLoading: false,
      selectedHistory: null,
      editHtml: '',
      editLoading: false,
      historyDeleting: false,
      editingHistoryId: null,
      historyRequestId: 0,
      editRequestId: 0,
      filtersOpen: true,
      displayMode: 'card'
    }
  },
  computed: {
    months () {
      return Array.from({ length: 12 }, (_, index) => index + 1)
    },
    visibleYears () {
      if (this.showAllYears) return this.years
      return this.years.slice(0, 5)
    },
    hasMoreYears () {
      return !this.showAllYears && this.years.length > 5
    },
    hasMonthFilter () {
      return this.appliedYear && this.appliedMonth
    },
    showPagination () {
      return this.pagination && this.pagination.total_pages > 1
    },
    showMemberAges () {
      return this.appliedYear && this.appliedMonth && this.memberAges.length > 0
    }
  },
  mounted () {
    this.fetchMeta()
    this.filtersOpen = !this.isMobile()
  },
  methods: {
    nl2br,
    // モバイルかどうかを判定する。
    isMobile () {
      return window.matchMedia && window.matchMedia('(max-width: 768px)').matches
    },
    // 検索条件の表示/非表示を切り替える。
    toggleFilters () {
      this.filtersOpen = !this.filtersOpen
    },
    // 検索条件を維持したまま表示モードを切り替える。
    changeDisplayMode (mode) {
      if (this.displayMode === mode) return
      this.displayMode = mode
      this.fetchHistories(1)
    },
    // モーダルでフォームHTMLを読み込む。
    openFormModal () {
      this.showFormModal = true
      this.formLoading = true
      this.formHtml = ''
      HmAxios.get('/family/history_form', { responseType: 'text', headers: { Accept: 'text/html' } })
        .then((res) => {
          this.formHtml = res.data
        })
        .catch((error) => {
          console.log(error)
          alert('作成フォームの読み込みに失敗しました')
        })
        .finally(() => {
          this.formLoading = false
          this.$nextTick(() => {
            this.bindFormSubmit()
            if (window.$ && window.$('#content-field').length > 0) {
              window.$('#content-field').markdownEasily()
            }
          })
        })
    },
    // 記録詳細を取得して閲覧・編集共通モーダルを開く。
    openHistoryModal (history, mode = 'view') {
      if (!history?.id) return
      const historyId = history.id
      const requestId = ++this.historyRequestId
      this.editRequestId += 1
      this.showHistoryModal = true
      this.historyModalMode = 'view'
      this.historyModalLoading = true
      this.selectedHistory = null
      this.editingHistoryId = historyId
      HmAxios.get(`/histories/${historyId}.json`)
        .then((res) => {
          if (requestId !== this.historyRequestId || this.editingHistoryId !== historyId) return
          this.selectedHistory = res.data.history
          if (mode === 'edit') this.switchHistoryModalToEdit()
        })
        .catch((error) => {
          if (requestId !== this.historyRequestId || this.editingHistoryId !== historyId) return
          console.log(error)
          alert('記録の読み込みに失敗しました')
          this.closeHistoryModal()
        })
        .finally(() => {
          if (requestId !== this.historyRequestId || this.editingHistoryId !== historyId) return
          this.historyModalLoading = false
        })
    },
    // 同じモーダルを編集状態へ切り替えてフォームを読み込む。
    switchHistoryModalToEdit () {
      if (!this.editingHistoryId) return
      const historyId = this.editingHistoryId
      const requestId = ++this.editRequestId
      this.historyModalMode = 'edit'
      this.editLoading = true
      this.editHtml = ''
      HmAxios.get(`/histories/${historyId}/edit.json`)
        .then((res) => {
          if (requestId !== this.editRequestId || this.editingHistoryId !== historyId) return
          this.editHtml = res.data.form_html
        })
        .catch((error) => {
          if (requestId !== this.editRequestId || this.editingHistoryId !== historyId) return
          console.log(error)
          alert('編集フォームの読み込みに失敗しました')
          this.historyModalMode = 'view'
        })
        .finally(() => {
          if (requestId !== this.editRequestId || this.editingHistoryId !== historyId) return
          this.editLoading = false
          this.$nextTick(() => {
            if (requestId !== this.editRequestId || this.editingHistoryId !== historyId) return
            this.bindEditSubmit()
            if (window.$ && window.$('#content-field').length > 0) {
              window.$('#content-field').markdownEasily()
            }
          })
        })
    },
    // 編集状態から取得済みの閲覧状態へ戻る。
    switchHistoryModalToView () {
      this.editRequestId += 1
      this.editLoading = false
      this.historyModalMode = 'view'
    },
    // 閲覧・編集共通モーダルを閉じて状態を破棄する。
    closeHistoryModal () {
      this.historyRequestId += 1
      this.editRequestId += 1
      this.showHistoryModal = false
      this.historyModalMode = 'view'
      this.historyModalLoading = false
      this.selectedHistory = null
      this.editHtml = ''
      this.editingHistoryId = null
      this.historyDeleting = false
    },
    closeFormModal () {
      this.showFormModal = false
      this.formHtml = ''
    },
    optionKey (option) {
      return `${option.type}:${option.id || ''}`
    },
    // 一覧カードのスクロール位置を安定させるIDを返す。
    historyCardId (history) {
      return history.id ? `history-${history.id}` : null
    },
    formatDate (dateString) {
      return dateString || ''
    },
    memberNamePills (history) {
      if (history.member_names && history.member_names.length > 0) {
        return history.member_names
      }
      if (history.member_label) {
        return [history.member_label]
      }
      return []
    },
    // 初期データ（年/メンバー）を取得する。
    fetchMeta () {
      HmAxios.get('/family/history_meta.json')
        .then((res) => {
          this.memberOptions = res.data.member_options
          this.selectedMemberKeys = []
          this.selectedYear = null
          this.selectedMonth = null
          this.years = this.buildYears(res.data.current_year, res.data.min_year)
          this.showAllYears = false
          this.applyFilters()
        })
        .catch((error) => {
          console.log(error)
        })
    },
    buildYears (currentYear, minYear) {
      const result = []
      for (let year = currentYear; year >= minYear; year -= 1) {
        result.push(year)
      }
      return result
    },
    toggleYear (year) {
      if (this.selectedYear === year) {
        this.selectedYear = null
        this.selectedMonth = null
        return
      }
      this.selectedYear = year
      this.selectedMonth = null
      this.fetchMonthCounts(year)
    },
    toggleMonth (month) {
      this.selectedMonth = this.selectedMonth === month ? null : month
    },
    onMemberSelectionChange () {
      this.selectedYear = null
      this.selectedMonth = null
    },
    // 選択条件を適用して一覧を再取得する。
    applyFilters () {
      this.appliedMemberKeys = [...this.selectedMemberKeys]
      this.appliedYear = this.selectedYear
      this.appliedMonth = this.selectedMonth
      if (this.appliedYear) {
        this.fetchMonthCounts(this.appliedYear)
      }
      this.fetchHistories(1)
    },
    buildParams (page) {
      const params = new URLSearchParams()
      this.appliedMemberKeys.forEach((key) => {
        params.append('member_keys[]', key)
      })
      if (this.appliedYear) {
        params.append('year', this.appliedYear)
      }
      if (this.appliedMonth) {
        params.append('month', this.appliedMonth)
      }
      params.append('page', page)
      params.append('display_mode', this.displayMode)
      return params.toString()
    },
    // 一覧APIを呼び出す。
    fetchHistories (page, options = {}) {
      this.loading = true
      HmAxios.get(`/family/history_feed.json?${this.buildParams(page)}`)
        .then((res) => {
          this.histories = res.data.histories
          this.pagination = res.data.pagination
          this.memberAges = res.data.member_ages || []
          if (options.scrollId) {
            this.scrollToHistory(options.scrollId)
          }
        })
        .catch((error) => {
          console.log(error)
        })
        .finally(() => {
          this.loading = false
        })
    },
    fetchMonthCounts (year) {
      const params = new URLSearchParams()
      params.append('year', year)
      this.selectedMemberKeys.forEach((key) => {
        params.append('member_keys[]', key)
      })
      HmAxios.get(`/family/history_month_counts.json?${params.toString()}`)
        .then((res) => {
          this.monthCounts = res.data.counts || {}
        })
        .catch((error) => {
          console.log(error)
        })
    },
    changePage (page) {
      if (!this.pagination) return
      this.fetchHistories(page)
    },
    // 追加フォームのsubmitをフックする。
    bindFormSubmit () {
      const form = this.$el.querySelector('.family-dashboard__modal-body--create form')
      if (!form || form.dataset.bound) return

      form.dataset.bound = 'true'
      form.addEventListener('submit', (event) => {
        event.preventDefault()
        this.submitForm(form)
      })
      this.enableFormDraft(form, 'create')
    },
    // 編集フォームのsubmitをフックする。
    bindEditSubmit () {
      const form = this.$el.querySelector('.family-dashboard__modal-body--history form')
      if (!form || form.dataset.bound) return

      form.dataset.bound = 'true'
      form.addEventListener('submit', (event) => {
        event.preventDefault()
        this.submitEditForm(form)
      })
      this.enableFormDraft(form, 'edit')
    },
    // 追記に備えてフォーム入力をLocalStorageに保存・復元する。
    enableFormDraft (form, mode) {
      if (!form || form.dataset.draftBound) return

      const storageKey = this.formDraftKey(mode)
      if (mode === 'edit' && localStorage.getItem(storageKey)) {
        if (window.confirm('未保存の編集内容があります。復元しますか？')) {
          this.restoreFormDraft(form, storageKey)
        } else {
          localStorage.removeItem(storageKey)
        }
      } else {
        this.restoreFormDraft(form, storageKey)
      }

      form.dataset.draftBound = 'true'
      const handler = () => {
        this.saveFormDraft(form, storageKey)
      }
      form.addEventListener('input', handler)
      form.addEventListener('change', handler)
    },
    formDraftKey (mode) {
      if (mode === 'edit' && this.editingHistoryId) {
        return `history_form_draft_edit_${this.editingHistoryId}`
      }
      return 'history_form_draft_new'
    },
    saveFormDraft (form, storageKey) {
      if (!storageKey) return

      const data = {}
      const arrayValues = {}
      form.querySelectorAll('input, textarea, select').forEach((el) => {
        if (!el.name || el.type === 'file') return
        if (el.type === 'checkbox') {
          if (el.name.endsWith('[]')) {
            arrayValues[el.name] = arrayValues[el.name] || []
            if (el.checked) {
              arrayValues[el.name].push(el.value)
            }
          } else {
            data[el.name] = !!el.checked
          }
          return
        }
        if (el.type === 'radio') {
          if (el.checked) data[el.name] = el.value
          return
        }
        data[el.name] = el.value
      })

      Object.keys(arrayValues).forEach((key) => {
        data[key] = arrayValues[key]
      })

      localStorage.setItem(storageKey, JSON.stringify(data))
    },
    restoreFormDraft (form, storageKey) {
      if (!storageKey) return
      const raw = localStorage.getItem(storageKey)
      if (!raw) return

      let data = {}
      try {
        data = JSON.parse(raw)
      } catch (error) {
        return
      }

      form.querySelectorAll('input, textarea, select').forEach((el) => {
        if (!el.name || !(el.name in data)) return
        if (el.type === 'file') return
        if (el.type === 'checkbox') {
          if (el.name.endsWith('[]')) {
            const values = Array.isArray(data[el.name]) ? data[el.name] : []
            el.checked = values.includes(el.value)
          } else {
            el.checked = !!data[el.name]
          }
          return
        }
        if (el.type === 'radio') {
          el.checked = el.value === data[el.name]
          return
        }
        el.value = data[el.name]
      })
    },
    // 追加フォームのメンバー選択を解除する。
    // 画像読み込み後に対象カードへスクロールする。
    scrollToHistory (scrollId) {
      const tryScroll = (attemptsLeft) => {
        const target = document.getElementById(scrollId)
        if (!target) {
          if (attemptsLeft <= 0) return
          setTimeout(() => tryScroll(attemptsLeft - 1), 200)
          return
        }

        const images = Array.from(target.querySelectorAll('img'))
        if (images.length === 0) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' })
          return
        }

        const loaders = images.map((img) => {
          if (img.complete) return Promise.resolve()
          return new Promise((resolve) => {
            const onDone = () => {
              img.removeEventListener('load', onDone)
              img.removeEventListener('error', onDone)
              resolve()
            }
            img.addEventListener('load', onDone, { once: true })
            img.addEventListener('error', onDone, { once: true })
          })
        })

        Promise.all(loaders).then(() => {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' })
        })
      }

      this.$nextTick(() => {
        tryScroll(5)
      })
    },
    // 追加フォームをAPI経由で送信する。
    submitForm (form) {
      const formData = new FormData(form)
      this.formLoading = true
      HmAxios.post(form.action, formData, { headers: { Accept: 'application/json' } })
        .then((res) => {
          const history = res.data.history
          const targetDate = history?.target_date
          const match = this.shouldRefreshList(targetDate)

          localStorage.removeItem(this.formDraftKey('create'))
          this.closeFormModal()

          if (match) {
            const scrollId = history?.id ? `history-${history.id}` : null
            this.fetchHistories(1, { scrollId })
          } else if (history?.show_path) {
            window.location.href = history.show_path
          }
        })
        .catch((error) => {
          alert(error.response?.data?.errors?.join('\n') || '保存に失敗しました')
        })
        .finally(() => {
          this.formLoading = false
        })
    },
    // 編集フォームをAPI経由で送信する。
    submitEditForm (form) {
      const formData = new FormData(form)
      this.editLoading = true
      HmAxios.post(form.action, formData, { headers: { Accept: 'application/json' } })
        .then((res) => {
          const history = res.data.history
          const currentPage = this.pagination?.page || 1
          const matchesCurrentFilter = this.shouldRefreshList(history?.target_date)
          const scrollId = matchesCurrentFilter && history?.id ? `history-${history.id}` : null

          localStorage.removeItem(this.formDraftKey('edit'))
          this.closeHistoryModal()
          this.fetchHistories(currentPage, { scrollId })
        })
        .catch((error) => {
          alert(error.response?.data?.errors?.join('\n') || '保存に失敗しました')
        })
        .finally(() => {
          this.editLoading = false
        })
    },
    // 確認後に記録を削除し、表示中だったページを再取得する。
    deleteHistory () {
      if (!this.editingHistoryId || this.historyDeleting) return
      if (!window.confirm('この記録を削除しますか？この操作は取り消せません。')) return

      const deletedHistoryId = this.editingHistoryId
      const currentPage = this.pagination?.page || 1
      const targetPage = currentPage > 1 && this.histories.length <= 1 ? currentPage - 1 : currentPage
      this.historyDeleting = true

      HmAxios.delete(`/histories/${deletedHistoryId}.json`)
        .then(() => {
          this.closeHistoryModal()
          this.fetchHistories(targetPage)
        })
        .catch((error) => {
          console.log(error)
          alert(error.response?.data?.errors?.join('\n') || '削除に失敗しました')
        })
        .finally(() => {
          this.historyDeleting = false
        })
    },
    shouldRefreshList (targetDate) {
      if (!targetDate) return false
      const targetYear = Number(targetDate.slice(0, 4))
      const targetMonth = Number(targetDate.slice(5, 7))

      const matchYear = !this.appliedYear || targetYear === this.appliedYear
      const matchMonth = !this.appliedMonth || targetMonth === this.appliedMonth
      return matchYear && matchMonth
    },
    toggleFavorite (history) {
      if (!history) return
      const params = new URLSearchParams({
        favoritable_type: 'History',
        favoritable_id: history.id
      })
      const request = history.favorited
        ? HmAxios.delete(`/favorites?${params.toString()}`)
        : HmAxios.post(`/favorites?${params.toString()}`)
      request
        .then((res) => {
          history.favorited = res.data.favorited
        })
        .catch((error) => {
          console.log(error)
          alert('お気に入りの更新に失敗しました')
        })
    }
  }
}
</script>

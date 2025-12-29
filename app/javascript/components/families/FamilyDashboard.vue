<template>
  <section class="family-dashboard">
    <header class="family-dashboard__header">
      <div>
        <h3 class="family-dashboard__title">家族の記録</h3>
      </div>
      <button type="button" class="family-dashboard__add" @click="openFormModal">
        記録を追加
      </button>
    </header>

    <button type="button" class="family-dashboard__filter-toggle" @click="toggleFilters">
      {{ filtersOpen ? '条件を閉じる' : '条件で絞り込む' }}
    </button>

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
      <div v-else class="family-dashboard__cards">
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
                @click="openEditModal(history)"
              >
                <i class="fa fa-pencil-square-o"></i>
              </button>
            </div>
          </div>
          <h4 class="family-dashboard__card-title">
            <a :href="history.show_path">{{ history.title }}</a>
          </h4>
          <p v-if="history.height || history.weight" class="family-dashboard__metrics">
            <span v-if="history.height">{{ history.height }}cm</span>
            <span v-if="history.weight" class="family-dashboard__metric-separator">{{ history.weight }}kg</span>
          </p>
          <p v-if="history.content_html || history.content" class="family-dashboard__card-body" v-html="history.content_html || nl2br(history.content)"></p>
          <img v-if="history.eyecatch_url" :src="history.eyecatch_url" alt="" class="family-dashboard__card-image">
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

    <Modal v-if="showEditModal" :no-padding="true" @on-close="closeEditModal">
      <template #content>
        <div class="family-dashboard__modal-body family-dashboard__modal-body--edit">
          <div v-if="editLoading" class="family-dashboard__loading">フォームを読み込み中...</div>
          <div v-else v-html="editHtml"></div>
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
      showEditModal: false,
      editHtml: '',
      editLoading: false,
      editingHistoryId: null,
      filtersOpen: true
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
    // 編集フォームをモーダルで開く。
    openEditModal (history) {
      if (!history?.id) return
      this.showEditModal = true
      this.editLoading = true
      this.editHtml = ''
      this.editingHistoryId = history.id
      HmAxios.get(`/histories/${history.id}/edit.json`)
        .then((res) => {
          this.editHtml = res.data.form_html
        })
        .catch((error) => {
          console.log(error)
        })
        .finally(() => {
          this.editLoading = false
          this.$nextTick(() => {
            this.bindEditSubmit()
            if (window.$ && window.$('#content-field').length > 0) {
              window.$('#content-field').markdownEasily()
            }
          })
        })
    },
    // 編集モーダルを閉じる。
    closeEditModal () {
      this.showEditModal = false
      this.editHtml = ''
      this.editingHistoryId = null
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
          this.selectedYear = res.data.current_year
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
      params.append('per', 20)
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
    },
    // 編集フォームのsubmitをフックする。
    bindEditSubmit () {
      const form = this.$el.querySelector('.family-dashboard__modal-body--edit form')
      if (!form || form.dataset.bound) return

      form.dataset.bound = 'true'
      form.addEventListener('submit', (event) => {
        event.preventDefault()
        this.submitEditForm(form)
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
          this.closeEditModal()
          if (history?.target_date) {
            const scrollId = history?.id ? `history-${history.id}` : null
            this.fetchHistories(1, { scrollId })
          }
        })
        .catch((error) => {
          alert(error.response?.data?.errors?.join('\n') || '保存に失敗しました')
        })
        .finally(() => {
          this.editLoading = false
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

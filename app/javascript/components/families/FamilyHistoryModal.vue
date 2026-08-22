<template>
  <Modal :no-padding="true" @on-close="close">
    <template #content>
      <div class="family-dashboard__modal-body family-dashboard__modal-body--history">
        <div v-if="detailLoading" class="family-dashboard__loading">記録を読み込み中...</div>
        <template v-else-if="mode === 'view' && history">
          <div class="family-dashboard__detail-header">
            <div class="family-dashboard__detail-meta">
              <span v-if="history.about_date" class="family-dashboard__approx">(だいたい)</span>
              <span class="family-dashboard__date">{{ history.target_date_label || history.target_date }}</span>
              <span
                v-for="name in memberNamePills"
                :key="`detail-${history.id}-${name}`"
                class="family-dashboard__member"
              >
                {{ name }}
              </span>
              <span v-if="history.author_name" class="family-dashboard__author">by {{ history.author_name }}</span>
            </div>
            <button type="button" class="family-dashboard__detail-edit" @click="switchToEdit">
              編集
            </button>
          </div>
          <h3 class="family-dashboard__detail-title">{{ history.title }}</h3>
          <p v-if="history.height || history.weight" class="family-dashboard__metrics">
            <span v-if="history.height">{{ history.height }}cm</span>
            <span v-if="history.weight" class="family-dashboard__metric-separator">{{ history.weight }}kg</span>
          </p>
          <img v-if="history.eyecatch_url" :src="history.eyecatch_url" alt="" class="family-dashboard__detail-image">
          <div v-if="history.content_html" class="family-dashboard__detail-content markdown" v-html="history.content_html"></div>
        </template>
        <template v-else-if="mode === 'edit'">
          <button type="button" class="family-dashboard__detail-back" :disabled="saving || deleting" @click="switchToView">
            ← 閲覧に戻る
          </button>
          <div v-if="formLoading" class="family-dashboard__loading">フォームを読み込み中...</div>
          <template v-else>
            <div v-html="formHtml"></div>
            <div class="history-form__actions">
              <button type="button" class="btn btn-primary" :disabled="saving || deleting" @click="submitEdit">
                {{ saving ? '送信中...' : '送信' }}
              </button>
              <button
                type="button"
                class="family-dashboard__delete"
                :disabled="saving || deleting"
                @click="deleteHistory"
              >
                {{ deleting ? '削除中...' : 'この記録を削除' }}
              </button>
            </div>
          </template>
        </template>
      </div>
    </template>
  </Modal>
</template>

<script>
import HmAxios from '../../hm_axios.js'
import Modal from '../shared/Modal'

export default {
  name: 'FamilyHistoryModal',
  components: {
    Modal
  },
  props: {
    historyId: {
      type: Number,
      required: true
    },
    initialMode: {
      type: String,
      default: 'view'
    }
  },
  data () {
    return {
      mode: 'view',
      history: null,
      detailLoading: true,
      formHtml: '',
      formLoading: false,
      saving: false,
      deleting: false,
      detailRequestId: 0,
      formRequestId: 0,
      active: true
    }
  },
  computed: {
    memberNamePills () {
      if (this.history?.member_names?.length > 0) return this.history.member_names
      return this.history?.member_label ? [this.history.member_label] : []
    },
    draftStorageKey () {
      return `history_form_draft_edit_${this.historyId}`
    }
  },
  mounted () {
    this.fetchDetail()
  },
  beforeDestroy () {
    this.active = false
    this.detailRequestId += 1
    this.formRequestId += 1
  },
  methods: {
    // 閲覧用データを取得し、指定されていれば編集状態へ進む
    fetchDetail () {
      const requestId = ++this.detailRequestId
      this.detailLoading = true
      HmAxios.get(`/histories/${this.historyId}.json`)
        .then((res) => {
          if (!this.isCurrentDetailRequest(requestId)) return
          this.history = res.data.history
          if (this.initialMode === 'edit') this.switchToEdit()
        })
        .catch((error) => {
          if (!this.isCurrentDetailRequest(requestId)) return
          console.log(error)
          alert('記録の読み込みに失敗しました')
          this.close()
        })
        .finally(() => {
          if (!this.isCurrentDetailRequest(requestId)) return
          this.detailLoading = false
        })
    },
    isCurrentDetailRequest (requestId) {
      return this.active && requestId === this.detailRequestId
    },
    isCurrentFormRequest (requestId) {
      return this.active && requestId === this.formRequestId
    },
    // 編集フォームを取得して下書き保存を有効にする
    switchToEdit () {
      const requestId = ++this.formRequestId
      this.mode = 'edit'
      this.formLoading = true
      this.formHtml = ''
      HmAxios.get(`/histories/${this.historyId}/edit.json`)
        .then((res) => {
          if (!this.isCurrentFormRequest(requestId)) return
          this.formHtml = res.data.form_html
        })
        .catch((error) => {
          if (!this.isCurrentFormRequest(requestId)) return
          console.log(error)
          alert('編集フォームの読み込みに失敗しました')
          this.mode = 'view'
        })
        .finally(() => {
          if (!this.isCurrentFormRequest(requestId)) return
          this.formLoading = false
          this.$nextTick(() => this.prepareEditForm(requestId))
        })
    },
    switchToView () {
      this.formRequestId += 1
      this.formLoading = false
      this.mode = 'view'
    },
    prepareEditForm (requestId) {
      if (!this.isCurrentFormRequest(requestId) || this.mode !== 'edit') return
      const form = this.editForm()
      if (!form) return

      this.restoreEditDraft(form)
      const saveDraft = () => this.saveFormDraft(form)
      form.addEventListener('input', saveDraft)
      form.addEventListener('change', saveDraft)

      if (window.$ && window.$(form).find('#content-field').length > 0) {
        window.$(form).find('#content-field').markdownEasily()
      }
    },
    editForm () {
      return this.$el.querySelector('.family-dashboard__modal-body--history form')
    },
    // 未保存の編集内容がある場合は確認後に復元する
    restoreEditDraft (form) {
      const raw = localStorage.getItem(this.draftStorageKey)
      if (!raw) return
      if (!window.confirm('未保存の編集内容があります。復元しますか？')) {
        localStorage.removeItem(this.draftStorageKey)
        return
      }

      let data = {}
      try {
        data = JSON.parse(raw)
      } catch (error) {
        localStorage.removeItem(this.draftStorageKey)
        return
      }
      this.applyDraftToForm(form, data)
    },
    applyDraftToForm (form, data) {
      form.querySelectorAll('input, textarea, select').forEach((element) => {
        if (!element.name || !(element.name in data) || element.type === 'file') return
        if (element.type === 'checkbox') {
          const values = Array.isArray(data[element.name]) ? data[element.name] : []
          element.checked = element.name.endsWith('[]') ? values.includes(element.value) : !!data[element.name]
          return
        }
        if (element.type === 'radio') {
          element.checked = element.value === data[element.name]
          return
        }
        element.value = data[element.name]
      })
    },
    saveFormDraft (form) {
      const data = {}
      const arrayValues = {}
      form.querySelectorAll('input, textarea, select').forEach((element) => {
        if (!element.name || element.type === 'file') return
        if (element.type === 'checkbox') {
          if (element.name.endsWith('[]')) {
            arrayValues[element.name] = arrayValues[element.name] || []
            if (element.checked) arrayValues[element.name].push(element.value)
          } else {
            data[element.name] = !!element.checked
          }
          return
        }
        if (element.type === 'radio') {
          if (element.checked) data[element.name] = element.value
          return
        }
        data[element.name] = element.value
      })
      Object.assign(data, arrayValues)
      localStorage.setItem(this.draftStorageKey, JSON.stringify(data))
    },
    // フォームの検証後に更新APIへ送信する
    submitEdit () {
      const form = this.editForm()
      if (!form || this.saving || this.deleting) return
      if (form.reportValidity && !form.reportValidity()) return

      this.saving = true
      HmAxios.post(form.action, new FormData(form), { headers: { Accept: 'application/json' } })
        .then((res) => {
          localStorage.removeItem(this.draftStorageKey)
          this.$emit('updated', res.data.history)
        })
        .catch((error) => {
          alert(error.response?.data?.errors?.join('\n') || '保存に失敗しました')
        })
        .finally(() => {
          if (this.active) this.saving = false
        })
    },
    // 確認後に記録を削除する
    deleteHistory () {
      if (this.saving || this.deleting) return
      if (!window.confirm('この記録を削除しますか？この操作は取り消せません。')) return

      this.deleting = true
      HmAxios.delete(`/histories/${this.historyId}.json`)
        .then(() => {
          localStorage.removeItem(this.draftStorageKey)
          this.$emit('deleted', this.historyId)
        })
        .catch((error) => {
          console.log(error)
          alert(error.response?.data?.errors?.join('\n') || '削除に失敗しました')
        })
        .finally(() => {
          if (this.active) this.deleting = false
        })
    },
    close () {
      if (this.saving || this.deleting) return
      this.$emit('close')
    }
  }
}
</script>

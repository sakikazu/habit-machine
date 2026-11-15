<template lang="pug">
.habit-record-card
  h5.habit-record-header
    .habit-title
      a(:href="`/habits/${habit.id}`")
        | {{ habit.title }}
        pin-icon.pinned-icon(v-if="habit.pinned" :size="16" title="ピン留め中" aria-label="ピン留め中")
        family-badge(v-if="habit.for_family")
    button.button.saveButton(type="button" @click="save" v-if="dataChanged")
      save-icon(:size="17" aria-hidden="true")
      span 保存
    button.button.editButton(type="button" @click="toggleEdit" v-else)
      pencil-icon(:size="17" aria-hidden="true")
      span 編集
  .habit-record-body(v-if="editMode || persisted")
    template(v-if="editMode")
      .recordValueInput
        .recordValueInputLeft
          select.habit-record-input(v-model="recordValue" ref="inputValue" v-if="habit.value_type === 'collection'")
            option(v-for="opt in habit.value_collection" v-text="opt[0]" :value="opt[1]")
          input.habit-record-input(type="text" v-model="recordValue" ref="inputValue" v-else)
          span {{ habit.value_unit }}
        .recordValueInputRight
          circle-plus-icon.button.addTemplate(:size="24" @click="addTemplate" v-if="habit.template !== null" aria-label="テンプレートを追加")
      .habit-record-text
        textarea.habit-record-textarea(
          placeholder="メモ入力"
          v-model="recordMemo"
          @input="onInputRecordMemo($event)"
          @click="updateActiveInputHelper"
          @keydown="onMemoKeydown"
          @keyup="onMemoKeyup"
          @select="updateActiveInputHelper"
          @compositionstart="composing = true"
          @compositionend="onCompositionEnd"
          ref="markdownable_textarea"
          rows="5"
        )
        .template-input-helpers(v-if="templateInputHelperGroups.length > 0")
          .template-input-helpers-title
            span 入力補助
            span.template-input-helper-shortcut Alt+↑↓ / Alt+1〜9
          .template-input-helper-group(v-for="group in templateInputHelperGroups" :key="group.key")
            .template-input-helper-heading(v-if="group.heading") {{ group.heading }}
            .template-input-helper-item(
              v-for="entry in group.entries"
              :key="entry.id"
              :class="{ active: entry.id === activeInputHelperId }"
            )
              span.template-input-helper-label {{ entry.label }}：
              .template-input-helper-choices(v-if="entry.choices.length > 0")
                button.template-input-helper-choice(
                  v-for="choice in entry.choices"
                  :key="choice"
                  :class="{ selected: entry.id === activeInputHelperId && choice === activeInputHelperValue }"
                  :disabled="!canApplyInputHelper(entry)"
                  type="button"
                  @mousedown.prevent
                  @click="applyTemplateChoice(entry, choice)"
                ) {{ choice }}
              button.template-input-helper-value(
                v-else
                type="button"
                :disabled="!canApplyInputHelper(entry)"
                @mousedown.prevent
                @click="applyTemplateInputHelper(entry)"
              ) {{ entry.example }}
    template(v-else-if="persisted")
      span.habit-record-value
        // todo: valueないとき、（未入力）とか入れる？
        span.habit-record-value__number {{ initialRecord.value }}
        span {{ habit.value_unit }}
      .habit-record-text(v-if="initialRecord.memo && initialRecord.memo.trim()")
        .markdown.habit-record-content(v-html="initialRecord.markdowned_memo")
</template>

<script>
import { CirclePlus, Pencil, Pin, Save } from '@lucide/vue'
import { nextTick } from 'vue'
import HmAxios from 'hm_axios.js'
import FamilyBadge from 'components/shared/FamilyBadge'
import {
  choiceForShortcut,
  headingPathAtEnd,
  lineIndexAt,
  matchHabitTemplateEntries,
  parseHabitTemplate,
  replacementFor,
  replacementForChoice,
  restoreHabitTemplateEntries,
} from 'habit_template_examples.js'

export default {
  inheritAttrs: false, // 非prop属性をルート要素に適用したくない場合
  components: {
    CirclePlusIcon: CirclePlus,
    FamilyBadge,
    PencilIcon: Pencil,
    PinIcon: Pin,
    SaveIcon: Save,
  },
  props: {
    habit: {
      type: Object,
      required: true,
    },
    record: {
      type: Object,
      required: true,
    },
    targetDate: {
      type: String,
      required: true,
    },
  },
  data () {
    return {
      editMode: false,
      initialRecord: null,
      recordValue: null,
      recordMemo: null,
      templateInputHelpers: [],
      activeInputHelperId: null,
      activeInputHelperValue: null,
      composing: false,
    }
  },
  computed: {
    persisted () {
      return this.initialRecord?.id !== null
    },
    valueChanged () {
      return (!!this.initialRecord?.value || !!this.recordValue) && this.initialRecord?.value != this.recordValue
    },
    memoChanged () {
      return (!!this.initialRecord?.memo || !!this.recordMemo) && this.initialRecord?.memo != this.recordMemo
    },
    dataChanged () {
      return this.valueChanged  || this.memoChanged
    },
    templateInputHelperGroups () {
      const groups = []
      this.templateInputHelpers.forEach((entry) => {
        const key = entry.headingPath.join('\u001f')
        let group = groups[groups.length - 1]
        if (!group || group.key !== key) {
          group = { key, heading: entry.heading, entries: [] }
          groups.push(group)
        }
        group.entries.push(entry)
      })
      return groups
    },
  },
  created () {
    // NOTE: mountedではなくcreatedで実行することで、template内でinitialRecordがundefinedにならないようにしている
    // templateはcreatedとmountedの間に処理されるという感じかな
    this.resetRecordVals(this.record)
  },
  mounted () {
  },
  methods: {
    toggleEdit () {
      this.editMode = !this.editMode
      if (this.editMode) {
        const vm = this
        nextTick().then(function() {
          vm.$refs.inputValue.focus()
          window.markdownEasily(vm.$refs.markdownable_textarea)
          vm.resizeMemoTextarea()
        })
      }
    },
    addTemplate () {
      if (this.recordMemo === null) {
        this.recordMemo = ''
      }
      const initialHeadingPath = headingPathAtEnd(this.recordMemo)
      if (this.recordMemo !== '' && this.recordMemo.slice(-1) !== "\n") {
        this.recordMemo = this.recordMemo + "\n"
      }
      const parsedTemplate = parseHabitTemplate(this.habit.template, initialHeadingPath)
      this.recordMemo = this.recordMemo + parsedTemplate.text
      this.templateInputHelpers = parsedTemplate.entries
      this.activeInputHelperId = null
      this.activeInputHelperValue = null
      this.$nextTick(() => {
        this.updateActiveInputHelper()
        this.resizeMemoTextarea()
      })
    },
    // 本文量に応じて入力欄を拡張し、10行分の高さを上限にする
    resizeMemoTextarea () {
      const textarea = this.$refs.markdownable_textarea
      if (!textarea) return

      const defaultHeight = Number(textarea.dataset.defaultHeight) || textarea.offsetHeight
      if (!textarea.dataset.defaultHeight) textarea.dataset.defaultHeight = defaultHeight

      let maxHeight = Number(textarea.dataset.maxHeight)
      if (!maxHeight) {
        const defaultRows = textarea.rows
        textarea.rows = 10
        maxHeight = textarea.offsetHeight
        textarea.rows = defaultRows
        textarea.dataset.maxHeight = maxHeight
      }

      textarea.style.height = 'auto'
      const contentHeight = Math.max(textarea.scrollHeight, defaultHeight)
      textarea.style.height = `${Math.min(contentHeight, maxHeight)}px`
      textarea.style.maxHeight = `${maxHeight}px`
      textarea.style.overflowY = contentHeight > maxHeight ? 'auto' : 'hidden'
    },
    // TODO: JS的にリファクタリングしたいな
    onInputRecordMemo (event) {
      if (!this.composing) this.updateActiveInputHelper()
      if (this.habit.template === null) { return }
      // NOTE: Android Chrome の場合、数字を入力時でもこのreturnにひっかかってしまったのでコメントアウト
      // この処理を復活させるなら Backspace の時もreturnしないようにしないと
      // 数値以外の入力時はスルー
      // if (event.data === null || event.data.match(/\d/) === null) { return }

      // TODO: recordMemo から一発で値の配列を取り出せるリファクタリングをしたいが、JSで改行ごとに分割する正規表現できる？
      let summary = null
      const rows = this.recordMemo.split(/\r\n|\n/)
      rows.forEach(row => {
        // TODO: 円、のところを変数にする
        let val = row.match(/^- .*：(\d+)\s*円$/)
        if (val !== null) {
          summary += Number(val[1])
        }
      })
      if (summary !== null) {
        this.recordValue = summary
      }
    },
    // IME確定後にカーソル行との対応を更新する
    onCompositionEnd () {
      this.composing = false
      this.updateActiveInputHelper()
    },
    // カーソル行の選択肢をAlt+上下またはAlt+数字で切り替える
    onMemoKeydown (event) {
      if (this.composing || event.isComposing || event.ctrlKey || event.metaKey) return
      const textarea = this.$refs.markdownable_textarea
      if (!textarea) return

      const lineIndex = lineIndexAt(this.recordMemo, textarea.selectionStart)
      const match = matchHabitTemplateEntries(this.recordMemo, this.templateInputHelpers)[lineIndex]
      if (!match) return

      const choice = choiceForShortcut(match.entry.choices, match.value, event.key, event.altKey)
      const replacement = choice ? replacementForChoice(this.recordMemo, lineIndex, match, choice) : null
      if (!replacement) return

      event.preventDefault()
      this.replaceMemoSelection(replacement.start, replacement.end, replacement.replacement)
    },
    // カーソル移動キーの場合だけ入力補助との対応を更新する
    onMemoKeyup (event) {
      const navigationKeys = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']
      if (navigationKeys.includes(event.key)) this.updateActiveInputHelper()
    },
    // 現在の本文とテンプレートの対応が一意な場合だけ入力補助を選択する
    updateActiveInputHelper () {
      if (this.composing || this.templateInputHelpers.length === 0) return
      const textarea = this.$refs.markdownable_textarea
      if (!textarea) return

      const matches = matchHabitTemplateEntries(this.recordMemo, this.templateInputHelpers)
      const match = matches[lineIndexAt(this.recordMemo, textarea.selectionStart)]
      this.activeInputHelperId = match ? match.entry.id : null
      this.activeInputHelperValue = match ? match.value : null
    },
    // カーソル行の値を安全に置換できる入力補助か判定する
    canApplyInputHelper (entry) {
      if (entry.id !== this.activeInputHelperId) return false
      if (entry.choices.length > 0) {
        return this.activeInputHelperValue === '-' || entry.choices.includes(this.activeInputHelperValue)
      }
      return this.activeInputHelperValue === '-'
    },
    // カーソル行の未入力記号だけを入力補助の内容へ置換する
    applyTemplateInputHelper (entry) {
      const textarea = this.$refs.markdownable_textarea
      if (!textarea) return

      const lineIndex = lineIndexAt(this.recordMemo, textarea.selectionStart)
      const match = matchHabitTemplateEntries(this.recordMemo, this.templateInputHelpers)[lineIndex]
      if (!match || match.entry.id !== entry.id) return

      const replacement = replacementFor(this.recordMemo, lineIndex, match)
      if (!replacement) return

      this.replaceMemoSelection(replacement.start, replacement.end, replacement.replacement)
    },
    // カーソル行が未入力または選択肢の値である場合だけ候補へ置換する
    applyTemplateChoice (entry, choice) {
      const textarea = this.$refs.markdownable_textarea
      if (!textarea) return

      const lineIndex = lineIndexAt(this.recordMemo, textarea.selectionStart)
      const match = matchHabitTemplateEntries(this.recordMemo, this.templateInputHelpers)[lineIndex]
      if (!match || match.entry.id !== entry.id) return

      const replacement = replacementForChoice(this.recordMemo, lineIndex, match, choice)
      if (!replacement) return
      this.replaceMemoSelection(replacement.start, replacement.end, replacement.replacement)
    },
    // ブラウザの編集履歴を維持して文字列を置換し、置換内容を選択する
    replaceMemoSelection (start, end, replacement) {
      const textarea = this.$refs.markdownable_textarea
      textarea.focus()
      textarea.setSelectionRange(start, end)
      const inserted = document.execCommand('insertText', false, replacement)
      if (!inserted) {
        textarea.setRangeText(replacement, start, end, 'select')
        textarea.dispatchEvent(new Event('input', { bubbles: true }))
      }

      this.$nextTick(() => {
        textarea.focus()
        textarea.setSelectionRange(start, start + replacement.length)
        this.updateActiveInputHelper()
      })
    },
    // 値とメモがどちらも空か判定する
    recordIsEmpty () {
      return (this.recordValue === null || String(this.recordValue).trim() === '') &&
        (this.recordMemo === null || this.recordMemo.trim() === '')
    },
    // 保存済みの記録を削除して未登録状態へ戻す
    deleteRecord () {
      HmAxios.delete(`/records/${this.initialRecord.id}.json`)
        .then(() => {
          this.resetRecordVals({
            id: null,
            value: null,
            memo: null,
            markdowned_memo: '',
          })
          this.editMode = false
        })
        .catch(error => {
          alert(error.response.data.message)
        })
    },
    save () {
      if (this.persisted) {
        if (this.recordIsEmpty()) {
          this.deleteRecord()
          return
        }

        // TODO: Axiosの設定で、json形式のリクエストにすれば、拡張子不要な気がする
        HmAxios.patch(`/records/${this.initialRecord.id}.json`, {
          record: {
            value: this.recordValue,
            memo: this.recordMemo,
          }
        })
          .then(res => {
            this.resetRecordVals(res.data.record)
            this.editMode = false
          })
          .catch(error => {
            alert(error.response.data.message)
          })
      } else {
        HmAxios.post('/records.json', {
          record: {
            habit_id: this.habit.id,
            record_at: this.targetDate,
            value: this.recordValue,
            memo: this.recordMemo,
          }
        })
          .then(res => {
            this.resetRecordVals(res.data.record)
            this.editMode = false
          })
          .catch(error => {
            alert(error.response.data.message)
          })
      }
    },
    resetRecordVals (record) {
      this.initialRecord = record
      this.recordValue = record.value
      this.recordMemo = record.memo
      this.templateInputHelpers = restoreHabitTemplateEntries(this.recordMemo, this.habit.template)
      this.activeInputHelperId = null
      this.activeInputHelperValue = null
    }
  }
}
</script>

<style scoped lang="sass">
  .habit-record-card
    margin-bottom: 15px
    border: 1px solid #dee2e6
    border-radius: 4px
    background: #fff

  .habit-record-header
    display: flex
    align-items: center
    margin: 0
    padding: 8px
    border-bottom: 1px solid #dee2e6
    background: rgba(0, 0, 0, 0.03)

  .habit-record-body
    padding: 8px

  .button
    display: inline-flex
    align-items: center
    gap: 5px
    flex-shrink: 0
    cursor: pointer
    padding: 5px 12px
    background: transparent
    font-size: 0.875rem
    text-align: center
    border-radius: 5px

    &.editButton
      color: #17a2b8
      border: 1px solid #17a2b8
      &:hover
        color: white
        background-color: #17a2b8
    &.saveButton
      color: #dc3545
      border: 1px solid #dc3545
      &:hover
        color: white
        background-color: #dc3545
    &.addTemplate
      padding: 0

  .habit-record-header
    .habit-title
      flex-grow: 1
      a
        font-size: 1rem
        font-weight: bold

      .pinned-icon
        display: inline-block
        margin-left: 8px
        color: #f59e0b

  .recordValueInput
    display: flex
    justify-content: space-between
    align-items: center
    color: #212529
    background-color: #f8f9fa
    padding: 5px 7px
    border-radius: 5px

    .habit-record-input
      width: 100px
      margin-right: 8px
      padding: 6px 10px
      border: 1px solid #ced4da
      border-radius: 4px
      background: #fff

    .recordValueInputLeft
      display: flex
      align-items: center

  .habit-record-text
    margin-top: 10px

  .habit-record-textarea
    display: block
    width: 100%
    padding: 6px 10px
    border: 1px solid #ced4da
    border-radius: 4px
    background: #fff
    line-height: 1.5

  .habit-record-value
    display: inline-block
    padding: 2px 5px
    border-radius: 4px
    background: #f8f9fa

  .habit-record-value__number
    margin-right: 4px
    font-size: 1.25em
    font-weight: 700

  .template-input-helpers
    margin-top: 8px
    border: 1px solid #dee2e6
    border-radius: 5px
    background-color: #f8f9fa
    padding: 8px

  .template-input-helpers-title
    display: flex
    align-items: center
    justify-content: space-between
    gap: 8px
    color: #6c757d
    font-size: .8rem
    font-weight: bold
    margin-bottom: 4px

  .template-input-helper-shortcut
    font-size: .72rem
    font-weight: 500

  @media (hover: none), (pointer: coarse)
    .template-input-helper-shortcut
      display: none

  .template-input-helper-group + .template-input-helper-group
    margin-top: 6px

  .template-input-helper-heading
    color: #495057
    font-size: .85rem
    font-weight: bold

  .template-input-helper-item
    display: flex
    flex-wrap: wrap
    align-items: center
    gap: 4px
    width: 100%
    border-radius: 3px
    color: #495057
    padding: 3px 6px

    &.active
      background-color: #d9edf7

  .template-input-helper-label
    font-weight: bold

  .template-input-helper-choices
    display: flex
    flex-wrap: wrap
    gap: 4px

  .template-input-helper-choice, .template-input-helper-value
    border: 1px solid #adb5bd
    border-radius: 3px
    background-color: white
    color: #495057
    cursor: pointer
    padding: 2px 7px

    &:not(:disabled):hover, &.selected
      color: white
      background-color: #17a2b8
      border-color: #17a2b8

    &:disabled
      cursor: default
      opacity: .45
</style>

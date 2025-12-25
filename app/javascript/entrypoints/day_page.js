import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { onPageLoad } from 'helper'

import HabitRecord from 'components/habits/HabitRecord'
import Diary from 'components/diaries/Diary'
import Toast from 'components/shared/toast'
import Modal from 'components/shared/Modal'

onPageLoad(() => {
  console.log('day_page.js: turbolinks:load')
  const vm = new Vue({
    el: '#dayPage',
    components: {
      HabitRecord,
      Diary,
      Toast,
      Modal,
    },
    data: {
      targetDate: null,
      targetDateSettingTimeout: null,
      habit_records: [],
      diariesWithOpsions: [],
      // ページ内の日記たちの中で編集中のものを保持する
      editModeDiaryIds: [],
      diary_links_list: null,
      tabidx: 0,
      contentChanged: [],
      memoCategories: ['', '体調', '作業', 'メモ', '休息', 'TODO'],
      memoContent: '',
      memoTargetDiaryId: null,
      memoTargetDiaryTitle: '',
      memoTargetRecordAt: null,
      memoTargetType: 'Diary',
      memoTargetHistoryId: null,
      memoOverHistoryModal: false,
      toastShowable: false,
      toastError: false,
      toastMessage: '',
      modalableDiaryId: null,
      // mobileでは「本日の記録」の未記入のものはデフォルト非表示にしているので、それを表示するためのフラグ
      openRecordContents: false,
      categories: [],
    },
    computed: {
      // ページ内のすべてのフォームからデータ変更をチェック
      existsChangedForm () {
        return this.contentChanged.length > 0
      },
      hasMainDiary () {
        return this.diariesWithOpsions.some(obj => !!obj.diary?.main_in_day)
      },
      memoTargetDiaryLabel () {
        const title = this.memoTargetDiaryTitle || '(タイトルなし)'
        if (this.memoTargetType === 'History') {
          return this.memoTargetRecordAt ? `${title} (${this.memoTargetRecordAt}) [履歴]` : `${title} [履歴]`
        }
        if (!this.memoTargetDiaryId) return ''
        return this.memoTargetRecordAt ? `${title} (${this.memoTargetRecordAt})` : title
      },
      memoModalTitle () {
        const date = this.memoTargetRecordAt || this.targetDate
        return this.memoTargetType === 'History' ? `${date} の履歴に追記` : `${date} のメモ`
      }
    },
    mounted () {
      this.setup()
      this.setupGlobalListeners()
      this.targetDate = this.$el.dataset.targetDate
      this.fetchData()
      this.enablePopover()
      this.fetchCategories()
    },
    methods: {
      // Sidebar Vueインスタンスからのイベントでモーダル表示／トースト表示を橋渡しする
      setupGlobalListeners () {
        window.addEventListener('open-diary-modal', (event) => {
          if (event?.detail?.diaryId) this.showDiaryModal(event.detail.diaryId)
        })
        window.addEventListener('sidebar-toast', (event) => {
          if (event?.detail) this.showToast(event.detail)
        })
        window.addEventListener('open-history-append', (event) => {
          const history = event?.detail?.history
          if (history) this.showMemoFormForHistory(history)
        })
      },
      setup () {
        this.setupTimepicker()
        this.shortcutOfPagingLink('prev-day', 'next-day') // ショートカットで日にち移動
        this.setMovePageConfirm()
        this.setMemoForm()
      },
      moveSpecifiedDatePage (event) {
        event.preventDefault()

        const dayPageDateField = document.getElementById('day-page-date-field')
        location.href = `/day/${dayPageDateField.value}`
      },
      setMemoForm () {
        $('#memo-form.modal').on('shown.bs.modal', () => {
          if (this.memoOverHistoryModal) {
            this.stackMemoModalOverHistory()
          }
          $('#memo-form.modal').find('.first-focus').focus()
        })
        $('#memo-form.modal').on('hidden.bs.modal', () => {
          this.memoTargetDiaryId = null
          this.memoTargetDiaryTitle = ''
          this.memoTargetRecordAt = null
          this.memoTargetHistoryId = null
          this.memoTargetType = 'Diary'
          this.memoOverHistoryModal = false
          $('#memo-form').removeClass('modal-over-history')
          $('.modal-backdrop-over-history').removeClass('modal-backdrop-over-history')
          if ($('#historyFavoriteModal').hasClass('show')) {
            $('body').addClass('modal-open')
          }
        })
        this.$refs.memoContentField.addEventListener('input', (event) => {
          localStorage.setItem('inputting-memo-content', event.target.value)
        })
      },
      // 履歴モーダル上にメモモーダルを重ねるための調整
      stackMemoModalOverHistory () {
        const $memoModal = $('#memo-form')
        $memoModal.addClass('modal-over-history')
        const $backdrop = $('.modal-backdrop').last()
        if ($backdrop.length > 0) {
          $backdrop.addClass('modal-backdrop-over-history')
        }
        $('body').addClass('modal-open')
      },
      // LocalStorageによる一時保存があるので、下記対策の重要性は低くはなる
      setMovePageConfirm () {
        const formWarningMessage = "登録・保存していない入力内容は破棄されますがよろしいですか？"

        // リンク押下時、いずれかのフォームのデータが変更されていたら確認メッセージを表示する
        $('a').on('click', function(e) {
          let href = $(this).attr('href')
          if (
            typeof(href) === "undefined" ||
            href == '#' ||
            !vm.existsChangedForm ||
            $(this).hasClass('ignore-checking-changes')
          ) { return; }

          if(!confirm(formWarningMessage)) {
            e.preventDefault()
          }
        })

        // ブラウザのタブを閉じようとした時、またはturbolinks以外のリンクをクリックした時の警告
        $(window).on('beforeunload', function() {
          if (vm.existsChangedForm) {
            return formWarningMessage
          }
        })
      },
      showMemoForm (targetDiary = null) {
        this.memoTargetType = 'Diary'
        this.memoTargetHistoryId = null
        this.memoOverHistoryModal = false
        this.memoTargetDiaryId = targetDiary?.id || null
        this.memoTargetDiaryTitle = targetDiary ? (targetDiary.title_mod || targetDiary.title || '(タイトルなし)') : ''
        this.memoTargetRecordAt = targetDiary?.record_at || this.targetDate
        this.memoContent = this.memoContent || ''
        $('#memo-form').modal('show')
        const inputtingMemoContent = localStorage.getItem('inputting-memo-content')
        if (inputtingMemoContent) {
          this.memoContent = inputtingMemoContent
        }
      },
      showMemoFormForHistory (history) {
        this.memoTargetType = 'History'
        this.memoTargetHistoryId = history.id
        this.memoTargetDiaryId = null
        this.memoTargetDiaryTitle = history.title
        this.memoTargetRecordAt = history.date
        this.memoContent = ''
        this.memoOverHistoryModal = true
        $('#memo-form').modal('show')
      },
      setupTimepicker () {
        $('.timepicker').datetimepicker({
          format: 'LT'
        })
      },
      fetchData () {
        HmAxios.get(`/day_data/${this.targetDate}.json`)
          .then(res => {
            this.habit_records = res.data.habit_records
            const diaries = res.data.diaries
            this.diariesWithOpsions = diaries.map(diary => {
              return { diary: diary, targetDateForEditMode: null }
            })
            this.diary_links_list = res.data.diary_links_list
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
            console.error(error)
          })
      },
      enablePopover () {
        $('[data-toggle="popover"]').popover({ html: true });
      },
      // ショートカットキー
      // shift + < : 日戻し / shift + > : 日送り
      shortcutOfPagingLink (prev_class, next_class) {
        const PREV_KEY = 188;
        const NEXT_KEY = 190;

        // NOTE: イベントリスナの重複登録を防ぐためにoffしておく。他のkeydownイベントリスナを削除しないように名前をつけておく
        $(document).off('keydown.movePage')
        $(document).on('keydown.movePage', function(e) {
          if (!e.shiftKey) { return; }
          if (['INPUT', 'TEXTAREA', 'SELECT'].includes(e.target.tagName)) { return; }
          switch (e.which || e.keyCode) {
            case PREV_KEY:
              // NOTE: これが2019年版のクリックのさせ方らしい
              $('a.' + prev_class)[0].click();
              break;
            case NEXT_KEY:
              $('a.' + next_class)[0].click();
              break;
          }
        });
      },
      onContentChanged (formKey) {
        this.contentChanged.push(formKey)
      },
      onSubmitted (formKey, _updatedDiary) {
        this.contentChanged = this.contentChanged.filter(content => content !== formKey)
      },
      // this.diariesの方には反映する必要性はあまりない
      reflectPinnedDiaries (_formKey, updatedDiary) {
        window.dispatchEvent(new CustomEvent('sidebar-refresh', { detail: { diary: updatedDiary } }))
      },
      submitAppendingMemo (event) {
        event.preventDefault()

        if (this.memoTargetType === 'Diary' && this.existsEditModeDiaries()) {
          this.showToast({isError: true, message: '編集中の日記を閉じてください'})
          return
        } else if (!this.memoContent) {
          this.showToast({isError: true, message: 'メモの内容を入力してください'})
          return
        }

        if (this.memoTargetType === 'Diary') {
          if (!this.memoTargetDiaryId) {
            this.showToast({isError: true, message: 'メモを追加する日記を選択してください'})
            return
          }
          const formObject = new FormData(this.$refs.memoForm)
          HmAxios.post('/diaries/append_memo.json', formObject)
            .then(res => {
              this.showToast({isError: false, message: 'メモを追加しました'})
              if (!!res.data.after_created_by_memo) {
                this.diariesWithOpsions.push({ diary: res.data.diary, targetDateForEditMode: null, highlightForAMoment: true })
              } else {
                const foundIdx = this.diariesWithOpsions.findIndex(obj => obj.diary?.id === res.data.diary.id)
                if (foundIdx >= 0) {
                  const target = this.diariesWithOpsions[foundIdx]
                  target.diary = res.data.diary
                  target.highlightForAMoment = true
                  this.$set(this.diariesWithOpsions, foundIdx, target)
                }
              }
              if (this.modalableDiaryId && this.modalableDiaryId == res.data.diary.id) {
                this.$nextTick(() => {
                  this.$refs.modalDiary?.updateDiary?.(res.data.diary)
                })
              }
              $('.timepicker').datetimepicker('clear')
              $('#memo-form').find('select.form-control').val('')
              this.memoContent = ''
              localStorage.removeItem('inputting-memo-content')
              $('#memo-form').modal('hide')
            })
            .catch(error => {
              this.showToast({isError: true, message: (error?.response?.data?.message || `書いた内容をコピーしてから、リロードして、再度実行してください：${error.message}`)})
              console.error(error)
            })
        } else if (this.memoTargetType === 'History') {
          if (!this.memoTargetHistoryId) {
            this.showToast({isError: true, message: '追記する履歴を選択してください'})
            return
          }
          const memoText = this.buildMemoText()
          HmAxios.post('/favorites/append_history', { history_id: this.memoTargetHistoryId, content: memoText })
            .then(res => {
              this.showToast({isError: false, message: 'メモを追加しました'})
              const updatedContent = res.data?.history?.content
              window.dispatchEvent(new CustomEvent('history-appended', { detail: { id: this.memoTargetHistoryId, content: updatedContent } }))
              $('.timepicker').datetimepicker('clear')
              $('#memo-form').find('select.form-control').val('')
              this.memoContent = ''
              $('#memo-form').modal('hide')
              window.dispatchEvent(new CustomEvent('favorites-refresh'))
            })
            .catch(error => {
              this.showToast({isError: true, message: (error?.response?.data?.message || `書いた内容をコピーしてから、リロードして、再度実行してください：${error.message}`)})
              console.error(error)
            })
        }
      },
      buildMemoText () {
        const timeVal = this.$refs.memoForm.querySelector('input[name="[diary]time_memo"]').value
        const labelVal = this.$refs.memoForm.querySelector('select[name="[diary]label_memo"]').value
        let result = '- '
        if (timeVal) result += `[${timeVal}]`
        if (labelVal) result += `[${labelVal}] `
        result += this.memoContent
        return result
      },
      newDiary () {
        // NOTE: 新規作成なのにDiary経由でDiaryFormに渡していて冗長だが、Diaryコンポーネントのコメントに書いた通り、リファクタリングが微妙なので諦める
        this.diariesWithOpsions.push({ diary: {}, targetDateForEditMode: this.targetDate })
        this.editModeDiaryIds.push(null)
      },
      newMainDiary () {
        if (this.hasMainDiary) {
          this.showToast({isError: true, message: 'メイン日記は既に存在します'})
          return
        }
        const payload = { diary: { record_at: this.targetDate, main_in_day: true, title: '', content: '' } }
        HmAxios.post('/diaries.json', payload)
          .then(res => {
            this.fetchData()
            this.showToast({isError: false, message: 'メイン日記を作成しました'})
          })
          .catch(error => {
            this.showToast({isError: true, message: (error?.response?.data?.message || error.message)})
            console.error(error)
          })
      },
      existsEditModeDiaries () {
        return this.editModeDiaryIds.length > 0
      },
      onEditMode (targetDiaryId, isEdit) {
        const foundIndex = this.editModeDiaryIds.findIndex(id => id == targetDiaryId)
        // 編集開始かつ、editModeDiaryIdsに存在しなければ、そこに追加する
        if (isEdit && foundIndex == -1) {
          this.editModeDiaryIds.push(targetDiaryId)
        // 編集終了かつ、editModeDiaryIdsに存在すれば、そこから削除する
        } else if (!isEdit && foundIndex != -1) {
          this.editModeDiaryIds.splice(foundIndex, 1)
        }
      },
      showToast (options) {
        this.toastShowable = true
        this.toastError = options.isError
        this.toastMessage = options.message
      },
      showDiaryModal (diaryId) {
        this.modalableDiaryId = diaryId
      },
      closeDiaryModal () {
        this.modalableDiaryId = null
      },
      // TODO: 共通化したい
      fetchCategories () {
        HmAxios.get('/categories/selection.json')
          .then(res => {
            this.categories = res.data.categories
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
            console.error(error)
          })
      },
    },
  })
})

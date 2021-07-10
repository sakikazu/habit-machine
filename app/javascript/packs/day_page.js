import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { nl2br } from 'helper.js'

import HabitRecord from 'components/habits/HabitRecord'
import Diary from 'components/diaries/Diary'
import TaskDiary from 'components/diaries/TaskDiary'
import Toast from 'components/shared/toast'

console.log('day_page.js')
document.addEventListener('turbolinks:load', () => {
  console.log('day_page.js: turbolinks:load')
  const vm = new Vue({
    el: '#dayPage',
    components: {
      HabitRecord,
      Diary,
      TaskDiary,
      Toast,
    },
    data: {
      targetDate: null,
      habit_records: [],
      diariesWithOpsions: [],
      diary_links_list: null,
      tabidx: 0,
      contentChanged: [],
      memoCategories: ['', '体調', '作業', 'メモ', '休息', 'TODO'],
      memoContent: '',
      toastShowable: false,
      toastError: false,
      toastMessage: '',
      everydayDiaries: [],
    },
    computed: {
      // ページ内のすべてのフォームからデータ変更をチェック
      existsChangedForm () {
        return this.contentChanged.length > 0
      },
    },
    mounted () {
      this.setup()
      this.targetDate = this.$el.dataset.targetDate
      this.fetchData()
    },
    methods: {
      nl2br,
      setup () {
        this.setupTimepicker()
        this.shortcutOfPagingLink('prev-day', 'next-day') // ショートカットで日にち移動
        this.setMovePageConfirm()
        this.setMemoForm()
      },
      setMemoForm () {
        $('#memo-form.modal').on('shown.bs.modal', () => {
          $('#memo-form.modal').find('.first-focus').focus()
        })
      },
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
      showMemoForm () {
        $('#memo-form').show()
        $('#memo-form').modal('show')
      },
      expandWidth () {
        const DIARY_WIDTH = 700
        const width = $('.diary-wrapper').length * DIARY_WIDTH
        $('#diaries-wrapper').width(width)
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
              return { diary: diary, targetDateForEditMode: null, highlightForAMoment: false }
            })
            this.diary_links_list = res.data.diary_links_list
            this.everydayDiaries = res.data.everyday_diaries
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
          })
      },
      // ショートカットキー
      // shift + < : 日戻し / shift + > : 日送り
      shortcutOfPagingLink (prev_class, next_class) {
        const PREV_KEY = 188;
        const NEXT_KEY = 190;

        $(document).on('keydown', function(e) {
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
      onSubmitted (formKey) {
        this.contentChanged = this.contentChanged.filter(content => content !== formKey)
      },
      submitAppendingMemo (event) {
        event.preventDefault()

        if (!this.memoContent) {
          this.showToast({isError: true, message: 'メモの内容を入力してください'})
          return
        }

        const formObject = new FormData(this.$refs.memoForm)
        HmAxios.post('/diaries/append_memo.json', formObject)
          .then(res => {
            this.showToast({isError: false, message: 'メモを追加しました'})
            if (!!res.data.after_created_by_memo) {
              this.diariesWithOpsions.push({ diary: res.data.diary, targetDateForEditMode: null, highlightForAMoment: true })
            } else {
              const foundIdx = this.diariesWithOpsions.findIndex(obj => obj.diary.id === res.data.diary.id)
              this.diariesWithOpsions[foundIdx].diary = res.data.diary
              this.diariesWithOpsions[foundIdx].highlightForAMoment = true
            }
          })
          .catch(error => {
            this.showToast({isError: true, message: (error.message || error.response.data.message)})
          })
          .finally(() => {
            // NOTE: val('')で値クリアしてしまうと、次の入力時に現在時刻が出なくなる
            // ABOUT: https://tempusdominus.github.io/bootstrap-4/Functions/
            $('.timepicker').datetimepicker('clear')
            $('#memo-form').find('select.form-control').val('')
            this.memoContent = ''
          })
      },
      newDiary () {
        this.diariesWithOpsions.push({ diary: {}, targetDateForEditMode: this.targetDate, highlightForAMoment: false })
      },
      showToast (options) {
        this.toastShowable = true
        this.toastError = options.isError
        this.toastMessage = options.message
      },
    },
  })
})

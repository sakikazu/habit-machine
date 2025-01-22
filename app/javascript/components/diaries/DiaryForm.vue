<comment>
  フォームのデータは、propsだと古いデータを渡す可能性があるので、フォームを開いた時に毎回取得する。
  値が変更されている場合、ページ遷移で変更を破棄する確認を出したいため、フォームごとにランダムなキーを設けて、それを親で管理しているのが少し複雑
</comment>

<template lang="pug">
.card.border-secondary.mb-5
  h5.card-header(v-if="diary")
    .d-flex.justify-content-end
      .flex-grow-1 {{ `日記の${persisted ?  '編集' : '作成'}` }}
      a.btn.btn-light.ignore-checking-changes(@click="cancelEdit") キャンセル

  form.diary-form(ref="form" @submit="submit")
    .card-body
      .date-field
        .edit-date(v-if="persisted")
          label.mr-2 日付
          input.form-control.mb-3(type="date" name="[diary]record_at" :value="targetDate" v-if="persisted")
        input(type="hidden" name="[diary]record_at" :value="targetDate" v-else)

      .form-group
        input.form-control(type="text" name="[diary]title" placeholder="タイトル（未入力可）" ref="diaryTitle" v-model="diary.title" :tabindex="tabidxBase + 1")

      a(href="https://qiita.com/tbpgr/items/989c6badefff69377da7" target="_blank") markdown記法
      .form-group
        textarea.form-control(name="[diary]content" ref="markdownable_textarea" rows="20" placeholder="日記の内容" v-model="diary.content" :tabindex="tabidxBase + 2")
      .form-group
        label
          span.mr-1 タグ
          small.desc カンマ区切りで複数指定可能 ／ 使用するタグはタグ一覧から事前作成が必要
        input.form-control(type="text" name="[diary]tag_list" ref="taglist" placeholder="矢印キーを押下すれば既存のタグリストが表示されます" v-model="diary.tag_list" :tabindex="tabidxBase + 3")
      .form-group
        | ピン留めタグ 
        span.badge.mr5.cursor-pointer(v-for="tag in pinned_tags" @click="toggleTag(tag.name)" :style="tag.color_style")
          i.fa.fa-thumb-tack
          | &nbsp;
          | {{ tag.name }}
      .form-group
        | 最近使ったタグ 
        span.badge.mr5.cursor-pointer(v-for="tag in latest_tags" @click="toggleTag(tag.name)" :style="tag.color_style")
          | {{ tag.name }}
      .form-group
        p 画像
        .mb-3(v-if="persisted")
          div(v-if="diary.image_path")
            .image
              img.img-thumbnail(:src="diary.image_path")
              a(href='javascript:void(0)' @click="deleteImage") 画像削除する
          p(v-else) 画像は未添付
        input(type="file" name="[diary]eyecatch_image" id="diary_image")

      .form-group.form-check
        input(type="hidden" name="[diary]main_in_day" value="0")
        input.form-check-input(type="checkbox" id="mainInDay" name="[diary]main_in_day" value="1" :checked="diary.main_in_day")
        label.form-check-label(for="mainInDay") 1日のメイン日記
      .form-group.form-check
        input(type="hidden" name="[diary]pinned" value="0")
        input.form-check-input(type="checkbox" id="makePinned" name="[diary]pinned" value="1" :checked="diary.pinned")
        label.form-check-label(for="makePinned") 固定表示にする
      // TODO: とりあえずDiary.id降順のままでいいのでコメントアウト。やるならD&Dで順序変更できるUIかなぁ
      // .form-group
        // input.form-control(type="number" name="[diary]pin_priority" :value="diary.pin_priority")
        // label 固定表示の順（降順）
      .form-group.form-check
        input(type="hidden" name="[diary]is_hilight" value="0")
        input.form-check-input(type="checkbox" id="makeHighlight" name="[diary]is_hilight" value="1" :checked="diary.is_hilight")
        label.form-check-label(for="makeHighlight") 人生ハイライトにする
      .form-group.form-check
        input(type="hidden" name="[diary]is_about_date" value="0")
        input.form-check-input(type="checkbox" id="makeAmbiguousDate" name="[diary]is_about_date" value="1" :checked="diary.is_about_date")
        label.form-check-label(for="makeAmbiguousDate") 日付を曖昧にする

    .card-footer
      .form-actions.d-flex.justify-content-between
        button.btn.btn-primary(type="submit" :tabindex="tabidxBase + 4") 保存する
        a.btn.btn-danger(@click="deleteDiary" v-if="persisted") 削除
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { deleteKeysWithPrefix } from 'local_storage_manager.js'

export default {
  inheritAttrs: false,
  props: {
    diaryId: {
      type: Number,
      default: null,
    },
    targetDate: {
      type: String,
      required: true,
    },
  },
  data () {
    return {
      diary: {},  // こうすればデータ取得前にtemplate内で参照してもエラーにならないんだな
      pinned_tags: [],
      latest_tags: [],
      tagnames: [],
      formKey: null,
      unsaved: false,
      // フォームが複数表示している場合でもtabindexがかぶらないように、フォームごとのベース値を設ける
      tabidxBase: Math.floor(Math.random() * 1000),
    }
  },
  watch: {
    'diary.title': function(newVal, oldVal) {
      // APIレスポンスからtitleに値がセットされた時もwatchが検知するため、ユーザーが入力時のみsetItemを行うように、oldValによって初回セット時を除外するようにしている
      if (oldVal !== undefined) {
        localStorage.setItem(this.lsTitleKey, newVal)
      }
    },
    'diary.content': function(newVal, oldVal) {
      if (oldVal !== undefined) {
        localStorage.setItem(this.lsContentKey, newVal)
      }
    },
  },
  computed: {
    persisted () {
      return !!this.diary?.id
    },
    lsTitleKey () {
      return this.persisted ? `diary-title-${this.diary.id}` : 'diary-title-new'
    },
    lsContentKey () {
      return this.persisted ? `diary-content-${this.diary.id}` : 'diary-content-new'
    },
  },
  // NOTE: 親でv-ifで表示可否を切り替えているからか、編集キャンセルして再編集時もcreatedが走る。この表示切り替え時に何かpropsで渡してwatchしても発動しないので、フォーム表示時の処理はcreated, mountedに書くべき
  created () {
    this.fetchFormData()
  },
  mounted () {
    $(this.$refs.markdownable_textarea).markdownEasily()
    this.setCheckUnsavedEvent()
    this.formKey = this.generateKey()
    this.$refs.diaryTitle.focus()
  },
  methods: {
    generateKey () {
      // わかってないが10桁～11桁？で作られるな ref. https://qiita.com/fukasawah/items/db7f0405564bdc37820e
      return Math.random().toString(32).substring(2)
    },
    fetchFormData () {
      if (!!this.diaryId) {
        HmAxios.get(`/diaries/${this.diaryId}/edit.json`)
          .then(res => {
            this.diary = res.data.diary
            this.setFormData(res.data)
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
          })
      } else {
        HmAxios.get(`/diaries/new.json?record_at=${this.targetDate}`)
          .then(res => {
            this.diary = res.data.diary
            this.setFormData(res.data)
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
          })
      }
    },
    setFormData (resData) {
      this.pinned_tags = resData.pinned_tags
      this.latest_tags = resData.latest_tags
      this.tagnames = resData.tagnames
      $(this.$refs.taglist).autocompleteMultiple(this.tagnames, this.setTagList);
      this.setFromLocalStorage()
    },
    setTagList (val) {
      this.diary.tag_list = val
    },
    setFromLocalStorage () {
      const lsTitle = localStorage.getItem(this.lsTitleKey)
      const lsContent = localStorage.getItem(this.lsContentKey)

      if (this.persisted && (lsTitle || lsContent)) {
        if (!confirm('未保存のデータがあります。復元しますか？')) {
          return
        }
      }

      if (lsTitle) {
        this.diary.title = lsTitle
      }
      if (lsContent) {
        this.diary.content = lsContent
      }
    },
    setCheckUnsavedEvent () {
      $(this.$refs.form).find('input, textarea, select').on('change', () => {
        this.unsaved = true
        this.$emit('content-changed', this.formKey)
      })
    },
    submit (event) {
      event.preventDefault()
      // TODO: FormDataかv-modelか検討中。前者だとvalueは自分で設定しなきゃいけないしcheckboxのとことか面倒。後者は画像アップロードとか別処理がいらないかが懸念
      const formObject = new FormData(this.$refs.form)
      if (this.persisted) {
        HmAxios.patch(`/diaries/${this.diaryId}.json`, formObject)
          .then(res => {
            this.$emit('submitted', this.formKey, res.data.diary)
            deleteKeysWithPrefix('diary-')
            if (res.data.changed_record_at) {
              this.$emit('changed_record_at', res.data.changed_record_at)
            }
          })
          .catch(error => {
            alert(error?.response?.data?.message || error.message)
          })
      } else {
        HmAxios.post(`/diaries.json`, formObject)
          .then(res => {
            this.$emit('submitted', this.formKey, res.data)
            deleteKeysWithPrefix('diary-')
          })
          .catch(error => {
            alert(error?.response?.data?.message || error.message)
          })
      }
    },
    deleteDiary () {
      if (!confirm("本当に日記を削除してもいいですか?")) {
        return
      }
      HmAxios.delete(`/diaries/${this.diaryId}.json`)
        .then(res => {
          this.$el.remove()
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },
    // Diaryのフォームのタグフィールドに、選択したタグ名をトグルで追加/削除する
    toggleTag (tagname) {
      if (this.diary.tag_list.length == 0) {
        this.diary.tag_list = tagname;
        return
      }
      let inputted_tags = this.diary.tag_list.split(/\s*,\s*/);
      let find_idx = inputted_tags.indexOf(tagname);
      if (find_idx > -1) {
        inputted_tags.splice(find_idx, 1);
      } else {
        inputted_tags.push(tagname);
      }
      this.diary.tag_list = inputted_tags.join(', ');
    },
    cancelEdit () {
      // todo メッセージ、共通化する？
      const formWarningMessage = "登録・保存していない入力内容は破棄されますがよろしいですか？"
      if (this.unsaved) {
        if(!confirm(formWarningMessage)) return
      }
      this.$emit('cancel-edit')
    },
    deleteImage () {
      if (!confirm("本当に画像を削除してもいいですか？")) { return }
      HmAxios.put(`/diaries/${this.diary.id}/delete_image.json`)
        .then((res) => {
          this.diary.image_path = null
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    }
  }
}
</script>

<style scoped lang="sass">
</style>

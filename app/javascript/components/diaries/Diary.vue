<template lang="pug">
.diaryWrapper
  .well(v-if="!editMode" :class="{'highlight-border': highlight}")
    .page-header.mt0
      .d-flex.justify-content-end
        .flex-grow-1
          h5.diary-title
            //- unless is_day_page TODO: dayページ以外でも使うようになったらこの処理復活
              // span.date.mr10 = link_to fa_icon('calendar', text: dispdate(localDiary.record_at, true)), day_path(localDiary.record_at)
            span.title
              a(:href="`/diaries/${localDiary.id}`") {{ localDiary.title_mod }}
        .tags.ml-3(v-html="localDiary.tag_links")
    .diary-body(v-if="!changed_record_at")
      p(v-if="localDiary.is_secret" class='btn btn-block btn-danger disabled mb5') シークレット日記
      p(v-if="localDiary.is_hilight" class='btn btn-block btn-warning disabled mb5') ハイライト日記
      .text-center.mt20(v-if="!!localDiary.image_path")
        img.w-50.img-thumbnail(:src="localDiary.image_path")
      .markdown(v-html="localDiary.markdowned_content")
      .buttons
        a.btn.btn-light.ignore-checking-changes(@click="edit") 編集
    .diary-recordat-changed(v-else)
      a(:href="`/day/${changed_record_at}`" v-text="`この日記の日付が変更されました(${changed_record_at})`")
  diary-form(v-else :on-fetch-data="editMode" :diary-id="localDiary.id" :target-date="targetDate" @cancel-edit="onCancelEdit" @content-changed="onContentChanged" @submitted="onSubmitted" @changed_record_at="onChangedRecordAt")
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import DiaryForm from 'components/diaries/DiaryForm'

export default {
  inheritAttrs: false,
  components: {
    DiaryForm,
  },
  props: {
    diary: {
      type: Object,
      required: true,
    },
    targetDateForEditMode: {
      type: String,
      required: false,
    },
    highlightForAMoment: {
      type: Boolean,
      default: false,
    },
  },
  data () {
    return {
      localDiary: this.diary,
      editMode: (!!this.targetDateForEditMode ? true : false),
      highlight: this.highlightForAMoment,
      changed_record_at: null,
    }
  },
  watch: {
    diary(newVal) {
      this.localDiary = newVal
    },
  },
  computed: {
    targetDate () {
      return !!this.diary.id ? this.diary.record_at : this.targetDateForEditMode
    },
  },
  created () {
  },
  mounted () {
  },
  methods: {
    edit () {
      this.editMode = true
    },
    onCancelEdit () {
      this.editMode = false
      if (!this.localDiary.id) {
        // 本当は親の配列の中から削除すれば表示が自然になるんだけど、現状だとポッカリ枠が開いてしまう
        this.$el.remove()
      }
    },
    onContentChanged (formKey) {
      this.$emit('content-changed', formKey)
    },
    onSubmitted (formKey, updatedDiary) {
      this.$emit('submitted', formKey)
      this.editMode = false
      this.highlight = true
      this.localDiary = updatedDiary
    },
    onChangedRecordAt (changed_record_at) {
      this.changed_record_at = changed_record_at
    },
  }
}
</script>

<style scoped lang="sass">
.highlight-border
  border: 1px solid #e3e3e3
  animation: BlinkBorder 1s 10
  animation-timing-function: linear

@keyframes BlinkBorder
  0%
    border: 3px solid red
  50%
    border: 3px solid pink
  100%
    border: 3px solid red
</style>

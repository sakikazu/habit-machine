<template lang="pug">
.diaryWrapper(v-if="localDiary")
  .well(v-if="!editMode" :class="{'highlight-border': highlight}")
    .page-header.mt0
      .d-flex.justify-content-end
        .flex-grow-1
          h5.diary-title
            .noLinkTitle.text-secondary(v-if="modalMode")
              a.date.mr10(:href="`/day/${localDiary.record_at}`") {{ localDiary.disp_record_at }}
              span.text-danger.mr-1(v-if="localDiary.main_in_day")
                i.fa.fa-star
              span.title {{ localDiary.title_mod }}
            span.title(v-else :class="{'no-title-yet': !localDiary.title}")
              span.text-danger.mr-1(v-if="localDiary.main_in_day")
                i.fa.fa-star
              a(@click="showModal" href="javascript:void(0)") {{ localDiary.title_mod }}
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
  diary-form(v-else :diary-id="localDiary.id" :target-date="targetDate" @cancel-edit="onCancelEdit" @content-changed="onContentChanged" @submitted="onSubmitted" @changed_record_at="onChangedRecordAt")
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
      default: null,
    },
    diaryId: {
      type: Number,
      default: null,
    },
    targetDateForEditMode: {
      type: String,
      required: false,
    },
    highlightForAMoment: {
      type: Boolean,
      default: false,
    },
    modalMode: {
      type: Boolean,
      default: false
    },
  },
  data () {
    return {
      localDiary: null,
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
      return !!this.localDiary.id ? this.localDiary.record_at : this.targetDateForEditMode
    },
  },
  created () {
    if (!this.diary && !this.diaryId) throw new Error('diary or diaryId props is required')
    if (this.diary) {
      this.localDiary = this.diary
    } else {
      // TODO: Diaryの取得を待つようにすれば(await)、templateで `v-if="localDiary"` する必要ないかも？
      this.fetchDiary(this.diaryId)
    }
  },
  mounted () {
  },
  methods: {
    fetchDiary (diaryId) {
      HmAxios.get(`/diaries/${diaryId}.json`)
        .then(res => {
          this.localDiary = res.data.diary
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },
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
      this.$emit('submitted', formKey, updatedDiary)
      this.editMode = false
      this.highlight = true
      this.localDiary = updatedDiary
    },
    onChangedRecordAt (changed_record_at) {
      this.changed_record_at = changed_record_at
    },
    showModal () {
      this.$emit('show-diary-modal', this.localDiary.id)
    },
  }
}
</script>

<style scoped lang="sass">
.no-title-yet
  background-color: yellow

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

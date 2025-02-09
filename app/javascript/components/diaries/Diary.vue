<template lang="pug">
.diaryWrapper(v-if="localDiary")
  .well(v-if="!editMode" :class="{'highlight-border': highlight}")
    .page-header.mt0
      .d-flex.justify-content-end
        .flex-grow-1
          h5.diary-title
            .noLinkTitle.text-secondary(v-if="modalMode")
              a.date.mr10(:href="`/day/${localDiary.record_at}`" :target="linkWithTargetBlankValue")
                i.fa.fa-window-restore.mr-1(v-if="linkWithTargetBlank")
                | {{ localDiary.disp_record_at }}
              span.text-danger.mr-1(v-if="localDiary.main_in_day")
                i.fa.fa-star
              span.title {{ localDiary.title_mod }}
            span.title(v-else :class="{'no-title-yet': !localDiary.title}")
              span.text-danger.mr-1(v-if="localDiary.main_in_day")
                i.fa.fa-star
              a(:href="`/day/${localDiary.record_at}/diaries/${localDiary.id}`") {{ localDiary.title_mod }}
        .tags.ml-3(v-html="localDiary.tag_links")
        .categories(v-for="(category, idx) in localDiary.categories" :key="idx")
          .link(v-html="category.path")
        button.btn.btn-light(@click="showModal = true") 編集
    .diary-body(v-if="!changed_record_at")
      p(v-if="localDiary.is_secret" class='btn btn-block btn-danger disabled mb5') シークレット日記
      p(v-if="localDiary.is_hilight" class='btn btn-block btn-warning disabled mb5') ハイライト日記
      .text-center.mt20(v-if="!!localDiary.image_path")
        // TODO: !modalMode の時は、divで囲んで中の画像がはみ出した分はhiddenにするやつにする？縦が一覧できなくなるが
        img.img-thumbnail(:src="localDiary.image_path" :class="{ 'w-50': !modalMode }")
      .markdown.mb-4(v-html="markdownedContent")
      .buttons
        a.btn.btn-light.ignore-checking-changes(@click="edit") 編集
    .diary-recordat-changed(v-else)
      a(:href="`/day/${changed_record_at}`" v-text="`この日記の日付が変更されました(${changed_record_at})`")
  diary-form(v-else :diary-id="localDiary.id" :target-date="targetDate" @cancel-edit="onCancelEdit" @content-changed="onContentChanged" @submitted="onSubmitted" @changed_record_at="onChangedRecordAt")
  selectable-modal(v-if="showModal" :categories="categories" @close="showModal = false; selectedCategoryIds = []" @save="saveCategories" @toggle="toggleCategory")
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
// TODO: DiaryFormはDiaryを経由する必要が？
import DiaryForm from 'components/diaries/DiaryForm'
import SelectableModal from "components/categories/SelectableModal"

export default {
  inheritAttrs: false,
  components: {
    DiaryForm,
    SelectableModal,
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
    // 2025/01/11: 用途がよくわからなくなっている。効率化できない？
    targetDateForEditMode: {
      type: String,
      required: false,
    },
    highlightForAMoment: {
      type: Boolean,
      default: false,
    },
    // TODO: モーダルではないdiary showページでもtrueにしていて、props名が不適切
    modalMode: {
      type: Boolean,
      default: false
    },
    highlightWord: {
      type: String,
      default: null,
    },
    linkWithTargetBlank: {
      type: Boolean,
      default: false,
    },
  },
  data () {
    return {
      // TODO: propsのdiaryではなく、localDiaryを使う必要性を忘れてしまったので、わかったらコメント書いておく
      localDiary: null,
      editMode: (!!this.targetDateForEditMode ? true : false),
      highlight: this.highlightForAMoment,
      changed_record_at: null,
      showModal: false,
      categories: [],
      selectedCategoryIds: [],
    }
  },
  watch: {
    diary(newVal) {
      this.localDiary = newVal
    },
    editMode(newVal) {
      this.$emit('on-edit-mode', this.localDiary.id, newVal)
    }
  },
  computed: {
    targetDate () {
      return !!this.localDiary.id ? this.localDiary.record_at : this.targetDateForEditMode
    },
    markdownedContent () {
      if (this.highlightWord && this.highlightWord.length > 0) {
        const pattern = new RegExp(this.highlightWord, 'gi') // 大文字小文字を区別しない
        return this.localDiary.markdowned_content.replaceAll(pattern, "<span class='highlight-word'>" + this.highlightWord + "</span>")
      } else {
        return this.localDiary.markdowned_content
      }
    },
    linkWithTargetBlankValue () {
      return this.linkWithTargetBlank ? '_blank' : '_self'
    }
  },
  created () {
    if (!this.diary && !this.diaryId) throw new Error('diary or diaryId props is required')
    if (this.diary) {
      this.localDiary = this.diary
      this.fetchCategories()
    } else {
      // TODO: Diaryの取得を待つようにすれば(await)、templateで `v-if="localDiary"` する必要ないかも？
      this.fetchDiary(this.diaryId)
    }
  },
  mounted () {
  },
  methods: {
    fetchCategories () {
      // todo: どこで塞ぐべき？
      if (!this.localDiary.id) { return }
      HmAxios.get(`/categories/selection.json?diary_id=${this.localDiary.id}`)
        .then(res => {
          console.log(res)
          this.categories = res.data.categories
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },
    toggleCategory (category_id) {
      console.log(category_id)
      console.log(this.selectedCategoryIds)
      const index = this.selectedCategoryIds.indexOf(category_id);
      if (index !== -1) {
        this.selectedCategoryIds.splice(index, 1); // 値が存在する場合は削除
      } else {
        this.selectedCategoryIds.push(category_id); // 存在しない場合は追加
      }
    },
    saveCategories () {
      // TODO: 成功時は、diary.categoriesを更新したいので、今はdiaryの中に混在させてるけど、別APIにしようかな？
      HmAxios.post(`/diaries/${this.localDiary.id}/update_categories.json`, { category_ids: this.selectedCategoryIds })
        .then(res => {
          this.localDiary = res.data.diary
          this.fetchCategories()
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })

    },
    fetchDiary (diaryId) {
      HmAxios.get(`/diaries/${diaryId}.json`)
        .then(res => {
          this.localDiary = res.data.diary
          this.selectedCategoryIds = res.data.diary.categories.map(cate => cate.id)
          this.fetchCategories()
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
  }
}
</script>

<style scoped lang="sass">
.no-title-yet
  background-color: greenyellow

.highlight-border
  border: 1px solid #bbdfff
  animation: BlinkBorder 1s 10
  animation-timing-function: linear

::v-deep
  .highlight-word
    background-color: orangered

@keyframes BlinkBorder
  0%
    border: 3px solid red
  50%
    border: 3px solid pink
  100%
    border: 3px solid red
</style>

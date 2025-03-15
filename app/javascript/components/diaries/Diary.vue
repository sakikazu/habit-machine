<comment>
### Diary -> DiaryForm 構成のリファクタリングについて
- 大きな問題点は、新規作成時に、Diaryを介する必要はないため、propsが冗長になっていること
- しかし、下記の現状のemitを調査したところ、DiaryFormは上位コンポーネントが必要と判断でき、リファクタリングしても特に変わらなそうなので中止
- DiaryFormは上位コンポーネントは必須。現状はDiaryが担ってるだけ
- Diaryの方ではイベントバケツリレーしてるだけのemitが多いが、他のComponentを上位にしても、これは結局変わらない
- リファクタリングする場合は、Diaryの下に、DiaryShow（現Diary）とDiaryFormか

DiaryForm
  - cancel-edit
    - DiaryのeditModeをやめる
  - content-changed
    - day_page.jsのcontentChangedにformKeyを追加する→
  - submitted
    - day_page.jsにsubmittedをemitする
    - DiaryでeditMode=false, highlight=true, localDiaryを更新
  - changed_record_at
    - Diaryで日付変更の表示を行う

Diary
  - on-edit-mode
    - day_page.jsで編集中日記配列に追加
    - ※現在はDiaryFormからのemmiをリレーしてるだけだが、上位コンポーネントを作った場合は、これが編集の契機になる
  - content-changed
    - day_page.jsで、編集中日記がある場合にリンククリックするとアラートを出すための変数を制御
    - 中からDiaryFormを取り除けば、不要になるemit
  - submitted
    - day_page.jsで、編集中日記からremove
    - 中からDiaryFormを取り除けば、不要になるemit

</comment>

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
      category-links(v-if="categories.length > 0" :categories="categories" :savedCategoryIds="localDiary.category_ids" @edit-category="showCategoryModal = true")
    .diary-body(v-if="!changed_record_at")
      p(v-if="localDiary.is_secret" class='btn btn-block btn-danger disabled mb5') シークレット日記
      p(v-if="localDiary.is_hilight" class='btn btn-block btn-warning disabled mb5') ハイライト日記
      .text-center.mt20(v-if="!!localDiary.image_path")
        // TODO: !modalMode の時は、divで囲んで中の画像がはみ出した分はhiddenにするやつにする？縦が一覧できなくなるが
        img.img-thumbnail(:src="localDiary.image_path" :class="{ 'w-50': !modalMode }")
      .markdown.mb-4(v-html="organizedContent")
      .buttons.d-flex.justify-content-between
        a.btn.btn-light.ignore-checking-changes(@click="edit") 編集
        a.btn.btn-light(v-if="localDiary.history_count > 0" :href="`/diaries/${localDiary.id}/histories`" v-text="`🕜履歴 (${localDiary.history_count})`")
    .diary-recordat-changed(v-else)
      a(:href="`/day/${changed_record_at}`" v-text="`この日記の日付が変更されました(${changed_record_at})`")
  diary-form(v-else :diary-id="localDiary.id" :target-date="targetDate" @cancel-edit="onCancelEdit" @content-changed="onContentChanged" @submitted="onSubmitted" @changed_record_at="onChangedRecordAt")
  selectable-modal(v-if="showCategoryModal" :categories="localCategories" @close="showCategoryModal = false" @save="saveCategories" @toggle="toggleCategory")
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
// Diary内にDiaryFormを含んでいたほうが、diaryコンポーネントを記載しておくだけでその編集も可能なので手軽になる。が、無駄に依存が増えて複雑になってる方が良くないかも
import DiaryForm from 'components/diaries/DiaryForm'
import SelectableModal from "components/categories/SelectableModal"
import CategoryLinks from "components/categories/CategoryLinks"

export default {
  inheritAttrs: false,
  components: {
    DiaryForm,
    SelectableModal,
    CategoryLinks,
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
    categories: {
      type: Array,
      default: [],
    },
  },
  data () {
    return {
      // TODO: propsのdiaryではなく、localDiaryを使う必要性を忘れてしまったので、わかったらコメント書いておく
      localDiary: null,
      editMode: (!!this.targetDateForEditMode ? true : false),
      highlight: this.highlightForAMoment,
      changed_record_at: null,
      // 直接categoriesにカテゴリの選択状態を反映してしまうと他のDiary Componentにも影響してしまうので、Componentごとに持つ（選択モーダル用）
      localCategories: [],
      showCategoryModal: false,
      selectedCategoryIds: [],
    }
  },
  watch: {
    diary(newVal) {
      this.localDiary = newVal
    },
    editMode(newVal) {
      this.$emit('on-edit-mode', this.localDiary.id, newVal)
    },
    // categoriesはpropsで渡されるため、categoriesとselectedCategoryIdsが揃った状態で、localCategoriesの更新を行う
    categories: {
      handler(newVal) {
        this.localCategories = JSON.parse(JSON.stringify(newVal))
        if (newVal.length > 0 && this.selectedCategoryIds.length > 0) {
          this.setSelectedToCategories(this.localCategories, this.selectedCategoryIds);
        }
      },
      deep: true,
      immediate: true // propsで渡されたものだからか、これをつけないと検知されなかった
    },
    selectedCategoryIds(newVal) {
      if (this.localCategories.length > 0 && newVal.length > 0) {
        this.setSelectedToCategories(this.localCategories, newVal);
      }
    },
    "localDiary.category_ids": {
      handler(newVal) {
        // selectedCategoryIds の変更をlocalDiary.category_ids に同期させたくないので、値渡しにする
        this.selectedCategoryIds = [...newVal]
      }
    },
  },
  computed: {
    targetDate () {
      return !!this.localDiary.id ? this.localDiary.record_at : this.targetDateForEditMode
    },
    organizedContent () {
      return this.localDiary.content_is_html ? this.localDiary.html_content : this.markdownedContent
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
    } else {
      // TODO: Diaryの取得を待つようにすれば(await)、templateで `v-if="localDiary"` する必要ないかも？
      this.fetchDiary(this.diaryId)
    }
  },
  mounted () {
  },
  methods: {
    setSelectedToCategories (categories, selected_ids) {
      categories.forEach(category => {
        category.selected = selected_ids.includes(category.id)

        if (category.children && category.children.length > 0) {
          this.setSelectedToCategories(category.children, selected_ids);
        }
      });
    },
    toggleCategory (category_id) {
      const index = this.selectedCategoryIds.indexOf(category_id);
      if (index !== -1) {
        this.selectedCategoryIds.splice(index, 1)
      } else {
        this.selectedCategoryIds.push(category_id)
      }
    },
    saveCategories () {
      HmAxios.post(`/diaries/${this.localDiary.id}/update_categories.json`, { category_ids: this.selectedCategoryIds })
        .then(res => {
          this.localDiary = res.data.diary
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },
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

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
  .well.diary-card(v-if="!editMode" :class="{'highlight-border': highlight}")
    .memo-fab(v-if="localDiary.id")
      button.memo-fab__button(@click.prevent="$emit('append-memo', localDiary)")
        i.fa.fa-sticky-note-o.mr-1
        | 追記
    .page-header.mt0
      .d-flex.justify-content-end
        .flex-grow-1
          h5.diary-title
            .noLinkTitle.text-secondary(v-if="modalMode")
              a.date.mr10(:href="`/day/${localDiary.record_at}`" :target="linkWithTargetBlankValue")
                i.fa.fa-window-restore.mr-1(v-if="linkWithTargetBlank")
                | {{ localDiary.disp_record_at }}
              span.main-badge.ml-2(v-if="localDiary.main_in_day")
                span.main-dot
                | メイン
              span.title(v-if="localDiary.title") {{ localDiary.title }}
              span.no-title-yet(v-else)
                i.fa.fa-exclamation-triangle.mr-1
                | タイトル未設定
            span.title(v-else)
              span.main-badge.mr-2(v-if="localDiary.main_in_day")
                span.main-dot
                | メイン
              a(v-if="localDiary.title" :href="`/day/${localDiary.record_at}/diaries/${localDiary.id}`" :aria-label="localDiary.title || 'タイトル未設定の日記'") {{ localDiary.title }}
              span.no-title-yet(v-else)
                i.fa.fa-exclamation-triangle.mr-1
                | タイトル未設定
      .meta-bar.mt-2(v-if="showMetaBar")
        .meta-block(v-if="hasTags")
          .meta-label
            i.fa.fa-tag.mr-1
            | タグ
          .tag-list(v-html="localDiary.tag_links")
        .meta-block(v-if="hasCategories")
          .meta-head
            .meta-label
              i.fa.fa-folder-open.mr-1
              | カテゴリ
          category-links.mt-1(v-if="categories.length > 0" :categories="categories" :savedCategoryIds="localDiary.category_ids" :show-edit-button="false" @edit-category="showCategoryModal = true")
      .backlinks.mt-2.mb-2(v-if="hasBacklinks")
        .d-flex.align-items-center.mb-1
          i.fa.fa-share-square-o.mr-2
          span.font-weight-bold バックリンク
        ul.pl-3.mb-0
          li(v-for="link in localDiary.backlinks" :key="link.id")
            a(:href="link.path")
              | 🔗 {{ backlinkLabel(link) }} 🔗
    .diary-body(v-if="!changed_record_at")
      p(v-if="localDiary.is_secret" class='btn btn-block btn-danger disabled mb5') シークレット日記
      p(v-if="localDiary.is_hilight" class='btn btn-block btn-warning disabled mb5') ハイライト日記
      .text-center.mt20(v-if="!!localDiary.image_path")
        // TODO: !modalMode の時は、divで囲んで中の画像がはみ出した分はhiddenにするやつにする？縦が一覧できなくなるが
        img.img-thumbnail(:src="localDiary.image_path" :class="{ 'w-50': !modalMode }")
      .markdown.mb-4(v-if="hasContent" v-html="organizedContent")
      .markdown-placeholder.mb-4(v-else)
        | (日記の内容)
      .utility-bar
        button.utility-pill(
          type="button"
          :class="isFavorited ? 'favorite-active' : 'favorite-inactive'"
          :disabled="favoriting"
          @click.prevent="toggleFavorite"
        )
          i.mr-1(:class="isFavorited ? 'fa fa-star' : 'fa fa-star-o'")
          | お気に入り
        .utility-group
          button.utility-pill(v-if="!modalMode" @click.prevent="showCategoryModal = true")
            i.fa.fa-folder-open.mr-1
            | カテゴリ編集
          button.utility-pill(@click.prevent="edit")
            i.fa.fa-pencil.mr-1
            | 編集
          a.utility-pill.subtle(v-if="localDiary.history_count > 0" :href="`/diaries/${localDiary.id}/histories`")
            i.fa.fa-clock-o.mr-1
            | 履歴 ({{ localDiary.history_count }})
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
      default: () => [],
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
      favoriting: false,
    }
  },
  watch: {
    diary(newVal) {
      if (this.hasFullData(newVal)) {
        this.localDiary = newVal
      } else if (newVal?.id) {
        this.fetchDiary(newVal.id)
      }
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
    isFavorited () {
      return !!this.localDiary?.favorited
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
    },
    hasBacklinks () {
      return Array.isArray(this.localDiary.backlinks) && this.localDiary.backlinks.length > 0
    },
    hasTags () {
      return !!(this.localDiary?.tag_links && this.localDiary.tag_links.length > 0)
    },
    hasCategories () {
      return Array.isArray(this.localDiary?.category_ids) && this.localDiary.category_ids.length > 0
    },
    showMetaBar () {
      return this.hasTags || this.hasCategories
    },
    hasContent () {
      const content = this.localDiary?.content_is_html ? this.localDiary?.html_content : this.localDiary?.markdowned_content
      return !!(content && content.trim().length > 0)
    }
  },
  created () {
    if (!this.diary && !this.diaryId) throw new Error('diary or diaryId props is required')
    if (this.diary && this.hasFullData(this.diary)) {
      this.localDiary = this.diary
    } else if (this.diaryId) {
      // TODO: Diaryの取得を待つようにすれば(await)、templateで `v-if="localDiary"` する必要ないかも？
      this.fetchDiary(this.diaryId)
    } else {
      // 日記IDが無い場合（新規作成時など）は取得せず、そのままフォームを表示する
      this.localDiary = this.diary || {}
    }
  },
  mounted () {
  },
  methods: {
    backlinkLabel (link) {
      const title = link.title_mod || '(タイトルなし)'
      return `${link.record_at} ${title}`
    },
    updateDiary (diary) {
      // 外部から日記データを更新するとき用
      if (this.hasFullData(diary)) {
        this.localDiary = diary
      } else if (diary?.id) {
        this.fetchDiary(diary.id)
      }
    },
    hasFullData (diary) {
      return !!diary && !!diary.markdowned_content
    },
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
      if (!diaryId) return
      HmAxios.get(`/diaries/${diaryId}.json`)
        .then(res => {
          this.localDiary = res.data.diary
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },
    toggleFavorite () {
      if (!this.localDiary?.id || this.favoriting) return

      this.favoriting = true
      const payload = { favoritable_type: 'Diary', favoritable_id: this.localDiary.id }
      const request = this.isFavorited
        ? HmAxios.delete('/favorites', { data: payload })
        : HmAxios.post('/favorites', payload)

      request
        .then(res => {
          const favorited = !!res.data.favorited
          this.$set(this.localDiary, 'favorited', favorited)
          window.dispatchEvent(new CustomEvent('favorites-refresh'))
        })
        .catch(error => {
          alert(error?.response?.data?.message || error.message)
        })
        .finally(() => {
          this.favoriting = false
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
  display: inline-flex
  align-items: center
  gap: 6px
  padding: 6px 10px
  border-radius: 999px
  background: linear-gradient(90deg, #fff5f5 0%, #ffecec 100%)
  border: 1px dashed #fb7185
  color: #b91c1c
  font-weight: 800
  font-size: 13px

.highlight-border
  border: 1px solid #bbdfff
  animation: BlinkBorder 1s 10
  animation-timing-function: linear

.diary-card
  position: relative
  border: 1px solid #e2e8f0
  border-radius: 12px
  padding: 16px 16px 12px
  background: #ffffff
  box-shadow: 0 8px 18px rgba(15, 23, 42, 0.05)
  overflow: visible

.diary-card::before
  content: ""
  position: absolute
  top: 0
  left: 0
  width: 100%
  height: 3px
  background: linear-gradient(90deg, #e2e8f0 0%, #e2e8f0 100%)

.diary-card .page-header
  border-bottom: none
  margin-bottom: 10px
  padding-bottom: 6px
  position: relative

.diary-card .diary-title
  padding-right: 70px

.diary-card .diary-title .title
  font-size: 22px
  font-weight: 800
  letter-spacing: 0.01em
  color: #0f172a

.main-badge
  display: inline-flex
  align-items: center
  gap: 6px
  padding: 4px 9px
  border-radius: 999px
  background: #eef2ff
  color: #1d4ed8
  font-weight: 700
  font-size: 12px

.main-dot
  width: 8px
  height: 8px
  border-radius: 999px
  background: linear-gradient(135deg, #1d4ed8 0%, #60a5fa 100%)
  box-shadow: 0 0 0 3px rgba(226, 232, 240, 0.8)

.diary-card .diary-title .title.no-title-yet
  color: #b91c1c
  font-weight: 800

.diary-card .diary-title .title a
  color: inherit
  text-decoration: none
  border-bottom: 2px solid transparent
  padding-bottom: 2px
  transition: border-color 0.12s ease

.diary-card .diary-title .title a:hover
  border-color: #2563eb

.diary-card .tags
  margin-top: 4px
  display: flex
  flex-wrap: wrap
  gap: 6px

::v-deep .diary-card .tags a,
::v-deep .diary-card .tags span
  display: inline-flex
  align-items: center
  padding: 4px 10px
  border-radius: 999px
  background: #eef2ff
  color: #4338ca
  font-weight: 600
  text-decoration: none
  border: 1px solid #e0e7ff

.diary-card .backlinks
  background: #f8fafc
  border: 1px dashed #e2e8f0
  border-radius: 10px
  padding: 8px 10px
  margin-top: 6px
  margin-bottom: 8px

.meta-bar
  position: relative
  margin: 12px -16px 0 -16px
  display: grid
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr))
  gap: 10px 14px
  background: #f8fafc
  padding: 10px 16px 10px
  box-shadow: inset 0 1px 0 rgba(148, 163, 184, 0.15)

.meta-bar::before
  content: ""
  position: absolute
  top: 0
  left: 0
  right: 0
  height: 1px
  background: linear-gradient(90deg, rgba(148, 163, 184, 0.12), rgba(148, 163, 184, 0.5), rgba(148, 163, 184, 0.12))

.meta-bar::after
  content: ""
  position: absolute
  bottom: 0
  left: 0
  right: 0
  height: 1px
  background: linear-gradient(90deg, rgba(148, 163, 184, 0.12), rgba(148, 163, 184, 0.5), rgba(148, 163, 184, 0.12))

.meta-block
  display: flex
  flex-direction: column
  gap: 6px

.meta-head
  display: flex
  align-items: center

.meta-label
  font-weight: 700
  color: #475569
  display: inline-flex
  align-items: center

.tag-list
  display: flex
  flex-wrap: wrap
  gap: 8px

::v-deep .tag-list a
  display: inline-flex
  align-items: center
  padding: 4px 9px
  border-radius: 999px
  background: #f1f5f9
  color: #475569
  font-weight: 600
  border: 1px solid #e2e8f0
  text-decoration: none

::v-deep .tag-list a:hover
  background: #e2e8f0

::v-deep .diary-categories
  margin-top: 2px
  padding: 0
  gap: 6px
  align-items: flex-start

::v-deep .diary-categories .category-list
  gap: 6px

::v-deep .diary-categories .category-link
  font-size: 12px
  padding: 3px 9px
  background: #f1f5f9
  color: #334155
  border: 1px solid #e2e8f0
  font-weight: 700
  border-radius: 999px

::v-deep .diary-categories .category-link:hover
  background: #e2e8f0

.category-edit
  border: 1px solid #c7d2fe
  background: #eef2ff
  color: #4338ca
  border-radius: 10px
  padding: 7px 12px
  font-weight: 700
  cursor: pointer
  display: inline-flex
  align-items: center
  transition: transform 0.12s ease, box-shadow 0.12s ease, background-color 0.12s ease

.category-edit:hover
  transform: translateY(-1px)
  box-shadow: 0 6px 14px rgba(67, 56, 202, 0.2)
  background: #e0e7ff

.category-edit:active
  transform: translateY(0)

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

.memo-fab
  position: absolute
  top: -6px
  right: -6px
  z-index: 2

.memo-fab__button
  border: 1px solid #e2e8f0
  padding: 9px 12px
  border-radius: 12px
  background: rgba(241, 245, 249, 0.9)
  color: #475569
  font-weight: 600
  letter-spacing: 0
  display: inline-flex
  align-items: center
  justify-content: center
  min-width: 86px
  min-height: 36px
  box-shadow: 0 6px 12px rgba(15, 23, 42, 0.06)
  cursor: pointer
  transition: transform 0.12s ease, box-shadow 0.12s ease

.memo-fab__button:hover
  transform: translateY(-1px)
  box-shadow: 0 10px 18px rgba(15, 23, 42, 0.08)

.memo-fab__button:active
  transform: translateY(0)

.utility-bar
  display: flex
  flex-wrap: wrap
  gap: 8px
  padding: 8px 0
  border-top: 1px solid #e5e7eb
  margin-top: 8px

.utility-group
  display: flex
  flex-wrap: wrap
  gap: 8px
  margin-left: auto

.utility-pill
  display: inline-flex
  align-items: center
  border: 1px solid #e2e8f0
  padding: 6px 10px
  border-radius: 10px
  background: #ffffff
  color: #475569
  font-weight: 600
  cursor: pointer
  transition: transform 0.12s ease, box-shadow 0.12s ease, background-color 0.12s ease
  text-decoration: none

.utility-pill.favorite-inactive
  background: #f8fafc
  color: #475569
  border-color: #e2e8f0

.utility-pill.favorite-active
  background: #1d4ed8
  color: #fff
  border-color: #1d4ed8

.utility-pill.favorite-inactive:hover
  background: #f1f5f9
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05)

.utility-pill:hover
  transform: translateY(-1px)
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05)
  background: #f8fafc

.utility-pill:active
  transform: translateY(0)

.utility-pill.subtle
  background: #fff
  color: #475569

.markdown-placeholder
  color: #94a3b8
  font-style: italic
</style>

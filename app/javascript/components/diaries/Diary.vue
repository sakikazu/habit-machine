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
    .page-header.mt0
      .diary-header
        .diary-heading
          h5.diary-title
            .noLinkTitle.text-secondary(v-if="modalMode")
              a.date.mr10(:href="`/day/${localDiary.record_at}`" :target="linkWithTargetBlankValue")
                i.fa.fa-window-restore.mr-1(v-if="linkWithTargetBlank")
                | {{ localDiary.disp_record_at }}
              span.title(v-if="localDiary.title") {{ localDiary.title }}
              span.no-title-yet(v-else) タイトル未設定
              span.main-badge.ml-2(v-if="localDiary.main_in_day")
                span.main-dot
                | メイン
            template(v-else)
              a.diary-title-link(
                :href="`/day/${localDiary.record_at}/diaries/${localDiary.id}`"
                :class="{ 'is-untitled': !localDiary.title }"
                :aria-label="localDiary.title || 'タイトル未設定の日記の詳細を開く'"
              )
                span.title {{ localDiary.title || 'タイトル未設定' }}
                i.fa.fa-angle-right.diary-title-link__icon(aria-hidden="true")
              span.main-badge.ml-2(v-if="localDiary.main_in_day")
                span.main-dot
                | メイン
        .diary-controls
          .diary-actions
            button.action-pill.primary(v-if="localDiary.id && hasAppendMemo" @click.prevent="$emit('append-memo', localDiary)")
              i.fa.fa-sticky-note-o.mr-1
              | 追記
            button.action-pill(@click.prevent="edit")
              i.fa.fa-pencil.mr-1
              | 編集
          .action-menu-wrapper(ref="actionMenuWrapper")
            button.action-pill(@click.prevent="toggleActionMenu")
              i.fa.fa-ellipsis-h.mr-1
              | その他
            .action-menu(v-if="showActionMenu")
              button.action-menu__item(
                type="button"
                :class="isFavorited ? 'favorite-active' : 'favorite-inactive'"
                :disabled="favoriting"
                @click.prevent="toggleFavoriteFromMenu"
              )
                i.mr-1(:class="isFavorited ? 'fa fa-star' : 'fa fa-star-o'")
                | {{ favoriteLabel }}
              url-copy-button.action-menu__item(v-if="diaryDetailUrl" :url="diaryDetailUrl")
              button.action-menu__item(@click.prevent="openCategoryModalFromMenu")
                i.fa.fa-folder-open.mr-1
                | カテゴリ編集
              a.action-menu__item(v-if="localDiary.history_count > 0" :href="`/diaries/${localDiary.id}/histories`")
                i.fa.fa-clock-o.mr-1
                | 履歴 ({{ localDiary.history_count }})
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
          category-links.mt-1(v-if="displayCategories.length > 0" :categories="displayCategories" :savedCategoryIds="localDiary.category_ids" :show-edit-button="false" @edit-category="openCategoryModal")
      .diary-collapse-actions.mt-2(v-if="collapsibleBody")
        button.btn.btn-sm.btn-outline-primary(@click.prevent="toggleDiaryBody")
          | {{ bodyCollapsed ? '続きを表示' : '折りたたむ' }}
    template(v-if="!bodyCollapsed")
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
import UrlCopyButton from "components/shared/UrlCopyButton"

export default {
  inheritAttrs: false,
  components: {
    DiaryForm,
    SelectableModal,
    CategoryLinks,
    UrlCopyButton,
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
    collapsibleBody: {
      type: Boolean,
      default: false,
    },
    collapseByDefault: {
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
      // 直接categoriesにカテゴリの選択状態を反映してしまうと他のDiary Componentにも影響してしまうので、Componentごとに持つ（選択モーダル用）
      localCategories: [],
      fetchedCategories: [],
      categoriesLoading: false,
      categoriesLoadingPromise: null,
      showCategoryModal: false,
      selectedCategoryIds: [],
      favoriting: false,
      showActionMenu: false,
      bodyCollapsed: this.collapseByDefault,
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
    // displayCategoriesはpropsまたは取得結果のどちらかなので、displayCategoriesとselectedCategoryIdsが揃った状態でlocalCategoriesを更新する
    displayCategories: {
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
        this.selectedCategoryIds = Array.isArray(newVal) ? [...newVal] : []
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
    hasAppendMemo () {
      // 親側にappend-memoが実装されている場合のみ追記を出す
      return !!this.$listeners['append-memo']
    },
    favoriteLabel () {
      return this.isFavorited ? 'お気に入り解除' : 'お気に入り'
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
    diaryDetailUrl () {
      // APIで返された絶対URLを優先して利用する
      return this.localDiary?.diary_url || null
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
    displayCategories () {
      return this.categories.length > 0 ? this.categories : this.fetchedCategories
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
    document.addEventListener('click', this.onClickOutside)
  },
  beforeDestroy () {
    document.removeEventListener('click', this.onClickOutside)
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
          if (res.data.categories) {
            this.fetchedCategories = res.data.categories
          }
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
    toggleActionMenu () {
      this.showActionMenu = !this.showActionMenu
    },
    closeActionMenu () {
      this.showActionMenu = false
    },
    onClickOutside (event) {
      if (!this.showActionMenu) return
      const menuWrapper = this.$refs.actionMenuWrapper
      if (menuWrapper && !menuWrapper.contains(event.target)) {
        this.showActionMenu = false
      }
    },
    toggleFavoriteFromMenu () {
      this.toggleFavorite()
    },
    async openCategoryModalFromMenu () {
      await this.openCategoryModal()
      this.closeActionMenu()
    },
    // カテゴリ編集用の一覧が未取得なら取得する
    async ensureCategoriesLoaded () {
      if (this.displayCategories.length > 0) return true
      if (this.categoriesLoadingPromise) return this.categoriesLoadingPromise

      this.categoriesLoading = true
      this.categoriesLoadingPromise = HmAxios.get('/categories/selection.json')
        .then(res => {
          this.fetchedCategories = res.data.categories || []
          return true
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
          return false
        })
        .finally(() => {
          this.categoriesLoading = false
          this.categoriesLoadingPromise = null
        })

      return this.categoriesLoadingPromise
    },
    // カテゴリ編集モーダルを開く前に必要データを揃える
    async openCategoryModal () {
      const loaded = await this.ensureCategoriesLoaded()
      if (!loaded) return
      this.showCategoryModal = true
    },
    // 日記本文の開閉を切り替える
    toggleDiaryBody () {
      if (!this.collapsibleBody) return
      this.bodyCollapsed = !this.bodyCollapsed
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
  color: #64748b
  font-weight: 600
  font-style: italic

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

.diary-header
  display: flex
  align-items: flex-start
  justify-content: space-between
  gap: 16px

.diary-heading
  min-width: 0
  padding-top: 4px

.diary-controls
  display: flex
  align-items: center
  gap: 8px
  flex-shrink: 0

.diary-actions
  display: flex
  flex-wrap: wrap
  gap: 8px

.action-pill
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

.action-pill.primary
  background: #0ea5e9
  color: #fff
  border-color: #0ea5e9

.action-pill:hover
  transform: translateY(-1px)
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05)
  background: #f8fafc

.action-pill.primary:hover
  background: #0284c7

.action-menu-wrapper
  position: relative

.action-menu
  position: absolute
  top: calc(100% + 6px)
  right: 0
  min-width: 180px
  background: #ffffff
  border: 1px solid #e2e8f0
  border-radius: 12px
  box-shadow: 0 10px 18px rgba(15, 23, 42, 0.12)
  padding: 6px
  z-index: 4
  display: grid
  gap: 4px

.action-menu__item
  display: inline-flex
  align-items: center
  gap: 6px
  width: 100%
  padding: 8px 10px
  border-radius: 10px
  border: none
  background: transparent
  color: #475569
  font-weight: 600
  text-decoration: none
  cursor: pointer
  transition: background-color 0.12s ease, box-shadow 0.12s ease

.action-menu__item:hover
  background: #f1f5f9

.action-menu__item:disabled
  cursor: not-allowed
  opacity: 0.6
  box-shadow: none

.action-menu__item.favorite-active
  background: #1d4ed8
  color: #fff

.action-menu__item.favorite-active:hover
  background: #1e40af

::v-deep .action-menu .copy-button
  width: 100%
  justify-content: flex-start
  background: transparent
  border: none
  padding: 8px 10px
  border-radius: 10px
  font-weight: 600

::v-deep .action-menu .copy-button:hover
  background: #f1f5f9

::v-deep .action-menu .copy-button.copied
  background: #dcfce7
  color: #059669

.diary-card .diary-title
  padding-right: 0
  margin: 0
  line-height: 1.5

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

.diary-title-link
  display: inline-flex
  align-items: center
  gap: 8px
  color: #0f172a
  text-decoration: none
  border-radius: 6px
  transition: color 0.12s ease, background-color 0.12s ease

.diary-title-link:hover
  color: #2563eb
  text-decoration: none

.diary-title-link:focus
  outline: none
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18)

.diary-title-link.is-untitled
  padding: 3px 8px
  border: 1px dashed #cbd5e1
  background: #f8fafc
  color: #64748b

.diary-title-link.is-untitled .title
  font-size: 15px
  font-weight: 600
  font-style: italic
  color: inherit

.diary-title-link:hover .title
  color: inherit

.diary-title-link__icon
  color: #94a3b8
  font-size: 16px

.diary-title-link:hover .diary-title-link__icon
  color: #2563eb

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


.markdown-placeholder
  color: #94a3b8
  font-style: italic

@media (max-width: 640px)
  .diary-header
    flex-direction: column
    gap: 12px

  .diary-controls
    width: 100%
    justify-content: space-between

  .diary-actions
    gap: 6px

  .action-pill
    padding: 6px 9px
</style>

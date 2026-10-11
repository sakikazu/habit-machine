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
          input.form-control.mb-3(type="date" name="diary[record_at]" :value="targetDate" v-if="persisted")
        input(type="hidden" name="diary[record_at]" :value="targetDate" v-else)

      .form-group
        input.form-control(type="text" name="diary[title]" placeholder="タイトル（未入力可）" ref="diaryTitle" v-model="diary.title" :tabindex="tabidxBase + 1")

      .tab-container
        .tab(v-if="!persisted || !contentEditableMode" @click="switchNormal" :class="{'active': !contentEditableMode, 'unclickable': persisted}")
          | 通常モード
        .tab(v-if="!persisted || contentEditableMode" @click="switchContentEditable" :class="{'active': contentEditableMode, 'unclickable': persisted}")
          | webページコピペモード
      .form-group
        content-editable(v-if="contentEditableMode" :content="diary.content" :tabindex="tabidxBase + 2" @content-updated="updateContent")
        div(v-else)
          a(href="https://qiita.com/tbpgr/items/989c6badefff69377da7" target="_blank") markdown記法
          textarea.form-control.diary-content-textarea(
            name="diary[content]"
            ref="markdownable_textarea"
            rows="12"
            :placeholder="persisted ? '' : '日記の内容です。編集時に画像を貼り付けることができます'"
            v-model="diary.content"
            :tabindex="tabidxBase + 2"
            @input="resizeContentTextarea"
            @paste="handlePaste"
          )
      section.form-section
        h5.form-section-title タグ
        p.form-section-description カンマ区切りで複数指定できます。使用するタグはタグ一覧から事前に作成してください
        input.form-control(type="text" name="diary[tag_list]" ref="taglist" placeholder="矢印キーで既存のタグを表示" v-model="diary.tag_list" :tabindex="tabidxBase + 3")

        .tag-suggestions(v-if="pinned_tags.length > 0")
          .tag-suggestion-title
            i.fa.fa-thumb-tack.mr-1
            | ピン留め
          .tag-list
            button.tag-button(
              v-for="tag in pinned_tags"
              :key="`pinned-${tag.name}`"
              type="button"
              :class="{ selected: isTagSelected(tag.name) }"
              :style="tag.color_style"
              @click="toggleTag(tag.name)"
            )
              i.fa.fa-check.mr-1(v-if="isTagSelected(tag.name)")
              | {{ tag.name }}
        .tag-suggestions(v-if="latestTagsExcludingPinned.length > 0")
          .tag-suggestion-title 最近使ったタグ
          .tag-list
            button.tag-button(
              v-for="tag in latestTagsExcludingPinned"
              :key="`latest-${tag.name}`"
              type="button"
              :class="{ selected: isTagSelected(tag.name) }"
              :style="tag.color_style"
              @click="toggleTag(tag.name)"
            )
              i.fa.fa-check.mr-1(v-if="isTagSelected(tag.name)")
              | {{ tag.name }}

      section.form-section
        h5.form-section-title 画像
        .main-image-card
          h6.mb-1 メイン画像
          p.form-section-description 一覧や日記の先頭に表示する画像です
          .main-image-preview(v-if="mainImageDisplayUrl")
            img(:src="mainImageDisplayUrl" alt="メイン画像のプレビュー")
          .main-image-empty(v-else) メイン画像は設定されていません
          .main-image-filename(v-if="mainImageFilename" :title="mainImageFilename") {{ mainImageFilename }}
          .main-image-actions
            button.btn.btn-sm.btn-outline-primary(type="button" @click="triggerMainImageInput") {{ mainImageDisplayUrl ? '画像を変更' : '画像を選択' }}
            button.btn.btn-sm.btn-outline-secondary(type="button" v-if="mainImagePreviewUrl" @click="clearSelectedMainImage") 選択を取り消す
            button.btn.btn-sm.btn-outline-danger(type="button" v-else-if="diary.image_path" @click="deleteImage") 削除
          input.visually-hidden-file(
            ref="mainImageInput"
            type="file"
            accept="image/*"
            name="diary[eyecatch_image]"
            id="diary_image"
            @change="handleMainImageSelect"
          )

        //- 画像選択時にアップロードするため、日記を特定できる編集時のみ表示する
        .image-manager-card(v-if="persisted")
          h5.mb-1 サブ画像
          p.image-manager-description 画像を追加すると、本文のカーソル位置に自動で挿入されます

          button.image-upload-button(
            type="button"
            @click="triggerFileInput"
            :disabled="uploading"
          )
            span.upload-icon(aria-hidden="true") 📁
            span
              strong {{ uploadButtonText }}
              small JPG・PNG・GIFなど／1枚最大20MB／複数選択可
          input.hidden(
            ref="fileInput"
            type="file"
            accept="image/*"
            multiple
            @change="handleFileSelect"
          )

          div.no-images(v-if="images.length === 0") 画像はまだありません。上のボタンから追加できます
          .image-grid(v-else)
            .image-item(v-for="image in images" :key="image.id")
              .image-container
                button.image-preview-button(type="button" @click="openImagePreview(image)" :aria-label="`${image.filename}を拡大表示`")
                  img(:src="image.url" :alt="image.filename")
                span.image-usage-badge.in-use(v-if="!contentEditableMode && isImageUsed(image.id)") 本文内
                span.image-usage-badge.not-in-use(v-else-if="!contentEditableMode") 未挿入
              .image-filename(:title="image.filename") {{ image.filename }}
              .image-actions
                button.btn.btn-sm.btn-primary(type="button" @click="handleImageInsert(image)") 本文に挿入
                button.btn.btn-sm.btn-outline-danger(type="button" @click="handleImageDelete(image.id)") 削除

          .image-preview-modal(
            v-if="previewImage"
            ref="imagePreviewModal"
            role="dialog"
            aria-modal="true"
            :aria-label="`${previewImage.filename}の拡大表示`"
            tabindex="-1"
            @click.self="closeImagePreview"
            @keydown.esc="closeImagePreview"
          )
            .image-preview-content
              button.image-preview-close(type="button" @click="closeImagePreview" aria-label="拡大表示を閉じる") ×
              img(:src="previewImage.orgUrl || previewImage.url" :alt="previewImage.filename")
              .image-preview-filename {{ previewImage.filename }}

      section.form-section
        h5.form-section-title 表示設定
        .setting-grid
          label.setting-option
            input(type="hidden" name="diary[main_in_day]" value="0")
            input.setting-checkbox(type="checkbox" id="mainInDay" name="diary[main_in_day]" value="1" :checked="diary.main_in_day")
            span.setting-text
              strong 1日のメイン日記
              small その日の代表として表示します
          label.setting-option
            input(type="hidden" name="diary[pinned]" value="0")
            input.setting-checkbox(type="checkbox" id="makePinned" name="diary[pinned]" value="1" :checked="diary.pinned")
            span.setting-text
              strong 固定表示にする
              small よく見返す日記として固定します
          label.setting-option
            input(type="hidden" name="diary[is_hilight]" value="0")
            input.setting-checkbox(type="checkbox" id="makeHighlight" name="diary[is_hilight]" value="1" :checked="diary.is_hilight")
            span.setting-text
              strong 人生ハイライトにする
              small ハイライト一覧の対象にします
          label.setting-option
            input(type="hidden" name="diary[is_about_date]" value="0")
            input.setting-checkbox(type="checkbox" id="makeAmbiguousDate" name="diary[is_about_date]" value="1" :checked="diary.is_about_date")
            span.setting-text
              strong 日付を曖昧にする
              small 正確な日付ではない記録として扱います

    .card-footer
      .form-actions.d-flex.justify-content-between
        button.btn.btn-primary(type="submit" :tabindex="tabidxBase + 4" :disabled="uploading")
          | {{ uploading ? '画像アップロード中...' : '保存する' }}
        a.btn.btn-danger(@click="deleteDiary" v-if="persisted") 削除
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { deleteKeysWithPrefix } from 'local_storage_manager.js'
import ContentEditable from 'components/diaries/ContentEditable'

export default {
  inheritAttrs: false,
  components: {
    ContentEditable,
  },
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
      // サブ画像用
      images: [],
      uploading: false,
      uploadCurrent: 0,
      uploadTotal: 0,
      previewImage: null,
      mainImagePreviewUrl: null,
      mainImageFilename: null,
      // NOTE: 通常/CEモードの切り替えについてはしっかり考慮はしていない段階
      contentEditableMode: false,
      htmlContent: "",
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
      this.$nextTick(this.resizeContentTextarea)
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
    uploadButtonText () {
      if (!this.uploading) return '画像を追加する'

      return `画像をアップロード中... (${this.uploadCurrent}/${this.uploadTotal})`
    },
    mainImageDisplayUrl () {
      return this.mainImagePreviewUrl || this.diary.image_path
    },
    latestTagsExcludingPinned () {
      const pinnedTagNames = this.pinned_tags.map(tag => tag.name)
      return this.latest_tags.filter(tag => !pinnedTagNames.includes(tag.name))
    },
  },
  // NOTE: 親でv-ifで表示可否を切り替えているからか、編集キャンセルして再編集時もcreatedが走る。この表示切り替え時に何かpropsで渡してwatchしても発動しないので、フォーム表示時の処理はcreated, mountedに書くべき
  created () {
    this.fetchFormData()
  },
  mounted () {
    this.setNormalContentElement()
    this.resizeContentTextarea()
    this.setCheckUnsavedEvent()
    this.formKey = this.generateKey()
    this.$refs.diaryTitle.focus()
    window.addEventListener('resize', this.resizeContentTextarea)
  },
  beforeDestroy () {
    this.revokeMainImagePreview()
    window.removeEventListener('resize', this.resizeContentTextarea)
  },
  methods: {
    // Diary::ACTIVE_STORAGE_URL_PLACEHOLDER と合わせる
    activeStorageUrlPlaceholder () {
      return 'ACTIVE_STORAGE_URL'
    },
    setNormalContentElement () {
      $(this.$refs.markdownable_textarea).markdownEasily()
    },
    // 本文量に合わせて入力欄を画面高の70%まで自動拡張する
    resizeContentTextarea () {
      const textarea = this.$refs.markdownable_textarea
      if (!textarea) return

      const minHeight = Number(textarea.dataset.minHeight) || textarea.offsetHeight
      if (!textarea.dataset.minHeight) textarea.dataset.minHeight = minHeight

      textarea.style.height = 'auto'
      const maxHeight = window.innerHeight * 0.7
      const contentHeight = Math.max(textarea.scrollHeight, minHeight)
      textarea.style.height = `${Math.min(contentHeight, maxHeight)}px`
      textarea.style.overflowY = contentHeight > maxHeight ? 'auto' : 'hidden'
    },
    generateKey () {
      // わかってないが10桁～11桁？で作られるな ref. https://qiita.com/fukasawah/items/db7f0405564bdc37820e
      return Math.random().toString(32).substring(2)
    },
    fetchFormData () {
      if (!!this.diaryId) {
        HmAxios.get(`/diaries/${this.diaryId}/edit.json`)
          .then(res => {
            this.diary = res.data.diary
            this.images = res.data.diary.images
            this.contentEditableMode = res.data.diary.content_is_html
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
    // 現在のタグ入力に指定したタグが含まれるかを返す
    isTagSelected(tagname) {
      const inputtedTags = (this.diary.tag_list || '').split(/\s*,\s*/).filter(tag => tag)
      return inputtedTags.includes(tagname)
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
    updateContent (val) {
      this.htmlContent = val
    },
    submit (event) {
      event.preventDefault()
      // TODO: FormDataかv-modelか検討中。前者だとvalueは自分で設定しなきゃいけないしcheckboxのとことか面倒。後者は画像アップロードとか別処理がいらないかが懸念
      const formObject = new FormData(this.$refs.form)
      if (this.contentEditableMode) {
        formObject.set("[diary]content", this.htmlContent)
        formObject.set("[diary]content_is_html", true)
      }
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
            this.$emit('submitted', this.formKey, res.data.diary)
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
        this.markFormChanged()
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
      this.markFormChanged()
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
          this.mainImageFilename = null
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },

    triggerMainImageInput() {
      this.$refs.mainImageInput.click()
    },

    // 保存前に選択したメイン画像をプレビューする
    handleMainImageSelect(e) {
      const file = e.target.files[0]
      if (!file) return

      this.revokeMainImagePreview()
      this.mainImagePreviewUrl = URL.createObjectURL(file)
      this.mainImageFilename = file.name
    },

    clearSelectedMainImage() {
      this.revokeMainImagePreview()
      this.mainImageFilename = null
      this.$refs.mainImageInput.value = ''
    },

    revokeMainImagePreview() {
      if (!this.mainImagePreviewUrl) return

      URL.revokeObjectURL(this.mainImagePreviewUrl)
      this.mainImagePreviewUrl = null
    },

    // サブ画像用
    insertTextAtCursor(text) {
      const textarea = this.$refs.markdownable_textarea
      const startPos = textarea.selectionStart
      const endPos = textarea.selectionEnd

      const beforeText = this.diary.content.substring(0, startPos)
      const afterText = this.diary.content.substring(endPos)

      this.diary.content = beforeText + text + afterText
      this.markContentChanged()

      this.$nextTick(() => {
        textarea.focus()
        const newCursorPos = startPos + text.length
        textarea.setSelectionRange(newCursorPos, newCursorPos)
      })
    },

    // 現在編集中のMarkdown本文に指定画像が含まれるかを返す
    isImageUsed(imageId) {
      return (this.diary.content || '').includes(`![image-${imageId}](`)
    },

    // プログラムから本文を変更した場合も未保存状態として通知する
    markContentChanged() {
      this.markFormChanged()
    },

    // DOMのchangeイベントを介さない変更を未保存状態として通知する
    markFormChanged() {
      this.unsaved = true
      this.$emit('content-changed', this.formKey)
    },

    // サブ画像をオーバーレイで拡大表示する
    openImagePreview(image) {
      this.previewImage = image
      this.$nextTick(() => this.$refs.imagePreviewModal.focus())
    },

    closeImagePreview() {
      this.previewImage = null
    },

    // 指定画像のリンク付き画像タグと画像タグを本文からすべて削除する
    removeImageReferences(imageId) {
      const placeholder = this.activeStorageUrlPlaceholder()
      const linkedPattern = new RegExp(`\\[!\\[image-${imageId}\\]\\(${placeholder}\\)\\]\\(${placeholder}\\)(?:\\r?\\n)?`, 'g')
      const imagePattern = new RegExp(`!\\[image-${imageId}\\]\\(${placeholder}\\)(?:\\r?\\n)?`, 'g')
      const content = this.diary.content || ''

      this.diary.content = content
        .replace(linkedPattern, '')
        .replace(imagePattern, '')
    },

    async handlePaste(e) {
      const imageFiles = Array.from(e.clipboardData.items)
        .filter(item => item.type.includes('image'))
        .map(item => item.getAsFile())
        .filter(file => file)

      if (imageFiles.length === 0) return

      e.preventDefault()
      await this.handleImageUploads(imageFiles)
    },

    // 複数画像を選択順にアップロードして本文へ挿入する
    async handleImageUploads(files) {
      if (this.uploading) {
        alert('画像のアップロード完了後に再度お試しください')
        return
      }
      if (!this.persisted) {
        alert('画像の貼り付けは、編集時のみ可能です。')
        return
      }

      const oversizedFiles = files.filter(file => file.size > 20 * 1024 * 1024)
      const uploadFiles = files.filter(file => file.size <= 20 * 1024 * 1024)
      if (oversizedFiles.length > 0) {
        const filenames = oversizedFiles.map(file => file.name).join('\n')
        alert(`次の画像は20MB以下にしてください\n${filenames}`)
      }
      if (uploadFiles.length === 0) return

      this.uploading = true
      this.uploadCurrent = 0
      this.uploadTotal = uploadFiles.length

      try {
        for (const [index, file] of uploadFiles.entries()) {
          this.uploadCurrent = index + 1
          try {
            await this.uploadImage(file)
          } catch (error) {
            const message = error?.response?.data?.message || error.message
            alert(`${file.name}のアップロードに失敗しました\n${message}`)
          }
        }
      } finally {
        this.uploading = false
        this.uploadCurrent = 0
        this.uploadTotal = 0
      }
    },

    // 1枚の画像をアップロードして一覧と本文に追加する
    async uploadImage(file) {
      const formData = new FormData()
      formData.append('image', file)

      const res = await HmAxios.post(`/diaries/${this.diary.id}/create_image`, formData)
      const { imageUrl, imageOrgUrl, imageId } = res.data
      const image = {
        id: imageId,
        url: imageUrl,
        orgUrl: imageOrgUrl,
        filename: file.name,
        uploadedAt: new Date().toISOString()
      }
      this.images.push(image)
      this.handleImageInsert(image)
    },
    async handleImageDelete(imageId) {
      const usedInContent = !this.contentEditableMode && this.isImageUsed(imageId)
      const confirmMessage = usedInContent
        ? 'この画像は本文内で使用されています。画像と本文中の記述を削除しますか？'
        : '本当に画像を削除してもいいですか？'
      if (!confirm(confirmMessage)) { return }

      HmAxios.put(`/diaries/${this.diary.id}/delete_sub_image/${imageId}.json`)
        .then((res) => {
          if (usedInContent) {
            this.removeImageReferences(imageId)
            this.markContentChanged()
          }
          this.images = this.images.filter(img => img.id !== imageId)
        })
        .catch(error => {
          alert(error.message || error.response.data.message)
        })
    },
    handleImageInsert(image) {
      // ファイル名に半角カッコが含まれている場合、ActiveStorageの画像パスにそれが含まれるため、現状、markdown用に生成する画像タグが意図せぬカッコで区切られてしまう不具合がある
      // TODO: ここで半角カッコ部分を変換すれば問題はなくなる。全角カッコにするだけでいいかも
      const placeholder = this.activeStorageUrlPlaceholder()
      const imageTag = `![image-${image.id}](${placeholder})`
      // サムネイル画像を、オリジナルサイズ画像へのリンクにする
      const imageLinkTag = `[${imageTag}](${placeholder})\n`
      this.insertTextAtCursor(imageLinkTag)
    },

    triggerFileInput() {
      this.$refs.fileInput.click()
    },

    async handleFileSelect(e) {
      const files = Array.from(e.target.files)
      if (files.length > 0) await this.handleImageUploads(files)

      // 同じ画像を続けて選択できるように選択状態をリセットする
      e.target.value = ''
    },
    switchNormal() {
      if (this.htmlContent) {
        if (confirm('通常モードに切り替えるとwebページ入力データが削除されますがよろしいですか？')) {
          this.htmlContent = ''
        } else {
          return
        }
      }
      this.contentEditableMode = false
      this.$nextTick(() => {
        this.setNormalContentElement()
        this.resizeContentTextarea()
      })
    },
    switchContentEditable () {
      this.contentEditableMode = true
    },
  }
}
</script>

<style scoped lang="sass">
.tab-container
  display: flex
  border-bottom: 2px solid #ddd
  margin-bottom: 8px

  .tab
    padding: 8px 16px
    cursor: pointer
    border: 2px solid transparent
    border-bottom: none
    background: #f8f8f8
    transition: background 0.2s, border-color 0.2s

    &.active
      background: #fff
      border-color: #ddd #ddd #fff
      font-weight: bold
    &.unclickable
      cursor: default

.form-section
  margin-top: 24px
  padding-top: 20px
  border-top: 1px solid #dee2e6

  .form-section-title
    margin-bottom: 4px

  .form-section-description
    margin-bottom: 12px
    color: #6c757d
    font-size: 0.875rem

.diary-content-textarea
  max-height: 70vh
  overflow-y: hidden
  resize: vertical

.tag-suggestions
  margin-top: 14px

  .tag-suggestion-title
    margin-bottom: 6px
    color: #6c757d
    font-size: 0.875rem
    font-weight: bold

  .tag-list
    display: flex
    flex-wrap: wrap
    gap: 8px

  .tag-button
    padding: 5px 10px
    border: 1px solid transparent
    border-radius: 14px
    cursor: pointer
    font-size: 0.875rem
    line-height: 1.2

    &:hover, &:focus
      filter: brightness(0.95)
      outline: none

    &.selected
      box-shadow: 0 0 0 2px #007bff

.main-image-card
  margin-bottom: 16px
  padding: 16px
  background: #f8f9fa
  border: 1px solid #dee2e6
  border-radius: 5px

  .main-image-preview
    display: flex
    min-height: 180px
    max-height: 320px
    margin-bottom: 10px
    padding: 8px
    align-items: center
    justify-content: center
    background: #fff
    border: 1px solid #dee2e6
    border-radius: 4px

    img
      max-width: 100%
      max-height: 300px
      object-fit: contain

  .main-image-empty
    margin-bottom: 10px
    padding: 24px 16px
    color: #6c757d
    background: #fff
    border: 2px dashed #ced4da
    border-radius: 4px
    text-align: center

  .main-image-filename
    margin-bottom: 10px
    overflow: hidden
    color: #495057
    font-size: 0.875rem
    text-overflow: ellipsis
    white-space: nowrap

  .main-image-actions
    display: flex
    flex-wrap: wrap
    gap: 8px

.visually-hidden-file
  display: none

.setting-grid
  display: grid
  grid-template-columns: repeat(2, minmax(0, 1fr))
  gap: 12px

  .setting-option
    display: flex
    min-width: 0
    margin: 0
    padding: 14px
    align-items: flex-start
    gap: 10px
    background: #f8f9fa
    border: 1px solid #dee2e6
    border-radius: 5px
    cursor: pointer

    &:hover
      background: #f1f3f5
      border-color: #adb5bd

  .setting-checkbox
    width: 18px
    height: 18px
    margin-top: 2px
    flex: 0 0 auto

  .setting-text
    min-width: 0

    strong, small
      display: block

    small
      margin-top: 3px
      color: #6c757d

.image-manager-card
  padding: 16px
  background: #FFF8E1
  border-radius: 5px
  overflow: hidden

  .image-manager-description
    margin-bottom: 12px
    color: #6c757d
    font-size: 0.875rem

  .image-upload-button
    display: flex
    width: 100%
    min-height: 72px
    margin-bottom: 16px
    padding: 12px 16px
    align-items: center
    justify-content: center
    gap: 12px
    color: #495057
    background: #fff
    border: 2px dashed #adb5bd
    border-radius: 5px
    cursor: pointer
    text-align: left

    &:hover, &:focus
      background: #f8f9fa
      border-color: #6c757d

    &:disabled
      cursor: wait
      opacity: 0.65

    .upload-icon
      font-size: 1.5rem

    strong, small
      display: block

    small
      margin-top: 2px
      color: #6c757d

  .no-images
    padding: 16px
    color: #6c757d
    background: rgba(255, 255, 255, 0.6)
    border-radius: 4px
    text-align: center

  .image-grid
    display: grid
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr))
    gap: 1rem

  .image-item
    min-width: 0
    padding: 8px
    background: #fff
    border: 1px solid #dee2e6
    border-radius: 5px

  .image-container
    position: relative
    padding-top: 100%

  .image-preview-button
    position: absolute
    top: 0
    left: 0
    width: 100%
    height: 100%
    padding: 0
    overflow: hidden
    background: transparent
    border: 0
    border-radius: 4px
    cursor: zoom-in

    &:focus
      outline: 3px solid rgba(0, 123, 255, 0.5)
      outline-offset: 2px

  .image-preview-button img
    width: 100%
    height: 100%
    object-fit: cover

  .image-usage-badge
    position: absolute
    top: 6px
    right: 6px
    padding: 3px 7px
    border-radius: 10px
    font-size: 0.75rem
    font-weight: bold

    &.in-use
      color: #fff
      background: rgba(40, 167, 69, 0.9)

    &.not-in-use
      color: #495057
      background: rgba(255, 255, 255, 0.9)

  .image-filename
    margin: 8px 0
    overflow: hidden
    font-size: 0.875rem
    text-overflow: ellipsis
    white-space: nowrap

  .image-actions
    display: flex
    gap: 8px

    .btn
      flex: 1

  .hidden
    display: none

  .image-preview-modal
    position: fixed
    z-index: 1050
    top: 0
    right: 0
    bottom: 0
    left: 0
    display: flex
    padding: 24px
    align-items: center
    justify-content: center
    background: rgba(0, 0, 0, 0.8)

  .image-preview-content
    position: relative
    display: flex
    max-width: 100%
    max-height: 100%
    padding: 40px 16px 12px
    flex-direction: column
    background: #fff
    border-radius: 5px

    img
      max-width: 90vw
      max-height: calc(90vh - 80px)
      object-fit: contain

  .image-preview-close
    position: absolute
    top: 2px
    right: 8px
    padding: 0 8px
    color: #495057
    background: transparent
    border: 0
    font-size: 2rem
    line-height: 1
    cursor: pointer

  .image-preview-filename
    max-width: 90vw
    margin-top: 8px
    overflow: hidden
    color: #495057
    font-size: 0.875rem
    text-align: center
    text-overflow: ellipsis
    white-space: nowrap

@media (max-width: 575.98px)
  .setting-grid
    grid-template-columns: 1fr

  .main-image-card
    padding: 12px

    .main-image-actions
      flex-direction: column

      .btn
        width: 100%

  .image-manager-card
    padding: 12px

    .image-grid
      grid-template-columns: repeat(2, minmax(0, 1fr))
      gap: 8px

    .image-item
      padding: 6px

    .image-actions
      flex-direction: column

      .btn
        width: 100%

    .image-preview-modal
      padding: 12px

</style>

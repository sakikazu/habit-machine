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

      .tab-container
        .tab(v-if="!persisted || !contentEditableMode" @click="switchNormal" :class="{'active': !contentEditableMode, 'unclickable': persisted}")
          | 通常モード
        .tab(v-if="!persisted || contentEditableMode" @click="switchContentEditable" :class="{'active': contentEditableMode, 'unclickable': persisted}")
          | webページコピペモード
      .form-group
        content-editable(v-if="contentEditableMode" :content="diary.content" :tabindex="tabidxBase + 2" @content-updated="updateContent")
        div(v-else)
          a(href="https://qiita.com/tbpgr/items/989c6badefff69377da7" target="_blank") markdown記法
          textarea.form-control(
            name="[diary]content"
            ref="markdownable_textarea"
            rows="20"
            :placeholder="persisted ? '' : '日記の内容です。編集時に画像を貼り付けることができます'"
            v-model="diary.content"
            :tabindex="tabidxBase + 2"
            @paste="handlePaste"
          )
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
        p メイン画像
        .mb-3(v-if="persisted")
          div(v-if="diary.image_path")
            .image
              img.img-thumbnail(:src="diary.image_path")
              a(href='javascript:void(0)' @click="deleteImage") 画像削除する
          p(v-else) メイン画像はありません
        input(type="file" accept="image/*" name="[diary]eyecatch_image" id="diary_image")

      //- 画像管理エリア（画像選択時にアップロードを行うため、Diaryが特定できる必要があるので、編集時のみ）
      .image-manager-card.mb-4(v-if="persisted")
        h5 サブ画像（日記中に配置できます）
        div.no-images(v-if="images.length === 0") アップロードされた画像はありません
        .image-grid(v-else)
          .image-item(v-for="image in images" :key="image.id")
            .image-container
              img(:src="image.url" :alt="image.filename")
              .image-actions
                span.action-button.insert(@click="handleImageInsert(image)")
                  i.icon 📥
                span.action-button.delete(@click="handleImageDelete(image.id)")
                  i.icon 🗑️
            .image-filename {{ image.filename }}

        .mt-3.btn.btn-light(
          @click="triggerFileInput"
        )
          p.upload-text
            | 📁
            | 画像を追加する
        input.hidden(
          ref="fileInput"
          type="file"
          accept="image/*"
          @change="handleFileSelect"
        )

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
    this.setNormalContentElement()
    this.setCheckUnsavedEvent()
    this.formKey = this.generateKey()
    this.$refs.diaryTitle.focus()
  },
  methods: {
    setNormalContentElement () {
      $(this.$refs.markdownable_textarea).markdownEasily()
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
    },

    // サブ画像用
    insertTextAtCursor(text) {
      const textarea = this.$refs.markdownable_textarea
      const startPos = textarea.selectionStart
      const endPos = textarea.selectionEnd

      const beforeText = this.diary.content.substring(0, startPos)
      const afterText = this.diary.content.substring(endPos)

      this.diary.content = beforeText + text + afterText

      this.$nextTick(() => {
        textarea.focus()
        const newCursorPos = startPos + text.length
        textarea.setSelectionRange(newCursorPos, newCursorPos)
      })
    },

    async handlePaste(e) {
      const items = e.clipboardData.items

      for (const item of items) {
        if (item.type.includes('image')) {
          e.preventDefault()
          const file = item.getAsFile()
          await this.handleImageUpload(file)
        }
      }
    },

    async handleImageUpload(file) {
      if (!this.persisted) {
        alert('画像の貼り付けは、編集時のみ可能です。')
        return
      }
      if (file.size > 5 * 1024 * 1024) {
        alert('画像サイズは5MB以下にしてください')
        return
      }

      this.uploading = true

      const formData = new FormData()
      formData.append('image', file)

      HmAxios.post(`/diaries/${this.diary.id}/create_image`, formData)
        .then(res => {
          const { imageUrl, imageOrgUrl, imageId } = res.data
          this.images.push({
            id: imageId,
            url: imageUrl,
            filename: file.name,
            uploadedAt: new Date().toISOString()
          })

          this.handleImageInsert({ id: imageId, url: imageUrl, orgUrl: imageOrgUrl })
        })
        .catch(error => {
          alert(error?.response?.data?.message || error.message)
        })

      this.uploading = false
    },
    async handleImageDelete(imageId) {
      if (!confirm("本当に画像を削除してもいいですか？")) { return }
      HmAxios.put(`/diaries/${this.diary.id}/delete_sub_image/${imageId}.json`)
        .then((res) => {
          // テキストエリア内の画像参照も削除
          // TODO: これは削除できてない
          const image = this.images.find(img => img.id === imageId)
          if (image) {
            const imageTag = `![image-${imageId}](${image.url})\n`
            this.diary.content = this.diary.content.replace(imageTag, '')
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
      const imageTag = `![image-${image.id}](${image.url})`
      // サムネイル画像を、オリジナルサイズ画像へのリンクにする
      const imageLinkTag = `[${imageTag}](${image.orgUrl})\n`
      this.insertTextAtCursor(imageLinkTag)
    },

    triggerFileInput() {
      this.$refs.fileInput.click()
    },

    handleFileSelect(e) {
      const file = e.target.files[0]
      if (file) {
        this.handleImageUpload(file)
      }
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
      // TODO: 効いてない。CEモードから帰って来るとMarkdown入力補助が効かない。この場合、v-showで切り替えるべきかなぁ
      this.setNormalContentElement()
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

.image-manager-card
  padding: 12px
  background: #FFF8E1
  border-radius: 5px
  overflow: hidden

  .image-grid
    display: grid
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
    gap: 1rem

  .image-item
    position: relative

  .image-container
    position: relative
    padding-top: 100%

  .image-container img
    position: absolute
    top: 0
    left: 0
    width: 100%
    height: 100%
    object-fit: cover
    border-radius: 4px

  .image-actions
    position: absolute
    top: 0
    left: 0
    right: 0
    bottom: 0
    background: rgba(0, 0, 0, 0.5)
    display: flex
    align-items: center
    justify-content: center
    gap: 0.5rem
    opacity: 0
    transition: opacity 0.2s

  .image-container:hover .image-actions
    opacity: 1

  .hidden
    display: none

</style>

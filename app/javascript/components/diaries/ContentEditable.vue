<template>
  <div class="content-editable-wrapper">
    <div
      class="content-editable"
      contenteditable="true"
      @input="updateContent"
      ref="editableDiv"
    ></div>
  </div>
</template>

<script>
export default {
  name: "ContentEditable",
  props: {
    content: {
      type: String,
      default: '',
    },
  },
  mounted () {
    this.setContent(this.content)
  },
  methods: {
    updateContent(event) {
      // contenteditable 内のHTMLを取得
      const html = event.target.innerHTML;
      this.$emit("content-updated", html);
    },
    setContent(newContent) {
      // 外部から内容を設定
      this.$refs.editableDiv.innerHTML = newContent;
    },
  },
};
</script>

<style scoped>
.content-editable-wrapper {
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 8px;
  overflow-y: auto;
}
.content-editable {
  outline: none;
  white-space: pre-wrap;
  word-wrap: break-word;
  min-height: 500px;
}
</style>

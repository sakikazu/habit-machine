<comment>
  生成AI（Claude）が出力したコード
</comment>

<template>
  <button
    class="copy-button"
    @click="handleCopy"
    :class="{ 'copied': copied }"
    :title="buttonTitle"
  >
    <!-- コピーアイコン -->
    <svg
      v-if="!copied"
      class="icon copy-icon"
      viewBox="0 0 24 24"
      width="14"
      height="14"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
      <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
    </svg>
    <!-- チェックアイコン -->
    <svg
      v-else
      class="icon check-icon"
      viewBox="0 0 24 24"
      width="14"
      height="14"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <polyline points="20 6 9 17 4 12"></polyline>
    </svg>
    <span>{{ buttonText }}</span>
  </button>
</template>

<script>
export default {
  name: 'UrlCopyButton',
  data() {
    return {
      copied: false
    }
  },
  computed: {
    buttonText() {
      return this.copied ? 'コピー完了' : 'URLコピー'
    },
    buttonTitle() {
      return this.copied ? 'コピーしました' : 'URLをコピー'
    }
  },

  methods: {
    async handleCopy() {
      const currentUrl = window.location.href;

      try {
        await navigator.clipboard.writeText(currentUrl)
        this.copied = true
        setTimeout(() => {
          this.copied = false
        }, 2000)
      } catch (err) {
        console.error('コピーに失敗しました:', err)
      }
    }
  }
}
</script>

<style scoped lang="sass">
.copy-button
  display: flex
  align-items: center
  gap: 6px
  padding: 4px 10px
  border: none
  border-radius: 4px
  background: #f3f4f6
  color: #4b5563
  font-size: 14px
  cursor: pointer
  transition: all 0.2s

.copy-button:hover
  background: #e5e7eb

.copy-button.copied
  background: #dcfce7
  color: #059669

.icon
  flex-shrink: 0
</style>

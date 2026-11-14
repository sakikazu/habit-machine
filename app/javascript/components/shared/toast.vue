<comment>
  親からpropsを通じて値を渡し、子から親に値の更新を指図もでき、親で更新された時も子で検知できる仕組みにしている
</comment>

<template lang="pug">
  .app-toast(v-if="showable" :class="{'app-toast--error': isError}" role="status" aria-live="polite")
    .app-toast__header
      strong 通知
      small たったいま
      button.app-toast__close(type="button" aria-label="閉じる" @click="hide") ×
    .app-toast__body {{ message }}
</template>

<script>
export default {
  inheritAttrs: false, // 非prop属性をルート要素に適用したくない場合
  props: {
    showable: {
      type: Boolean,
      default: false,
    },
    isError: {
      type: Boolean,
      default: false,
    },
    message: {
      type: String,
      required: '',
    },
  },
  watch: {
    showable(newVal) {
      if (newVal) {
        this.startTimer()
      } else {
        this.clearTimer()
      }
    },
  },
  data () {
    return {
      hideTimer: null,
    }
  },
  mounted () {
    if (this.showable) this.startTimer()
  },
  beforeUnmount () {
    this.clearTimer()
  },
  methods: {
    startTimer () {
      this.clearTimer()
      this.hideTimer = window.setTimeout(this.hide, 4000)
    },
    clearTimer () {
      if (this.hideTimer) window.clearTimeout(this.hideTimer)
      this.hideTimer = null
    },
    hide () {
      this.clearTimer()
      this.$emit('toast-hidden')
    },
  },
}
</script>

<style scoped lang="sass">
  .app-toast
    position: fixed
    z-index: 2000
    top: 30px
    right: 30px
    width: 300px
    max-width: calc(100vw - 30px)
    overflow: hidden
    border-radius: 6px
    background-color: #2563eb
    color: #fff

    &.app-toast--error
      background-color: #dc2626
      color: white

  .app-toast__header
    display: flex
    padding: 8px 12px
    align-items: center
    gap: 10px
    background: rgba(255, 255, 255, 0.12)

    strong
      flex-grow: 1

  .app-toast__close
    border: 0
    background: transparent
    color: inherit
    cursor: pointer
    font-size: 22px
    line-height: 1

  .app-toast__body
    padding: 12px
</style>

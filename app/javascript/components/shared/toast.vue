<comment>
  親からpropsを通じて値を渡し、子から親に値の更新を指図もでき、親で更新された時も子で検知できる仕組みにしている
</comment>

<template lang="pug">
  .toast(v-show="showable" :class="{'toast-error': isError}" data-autohide="true" :data-delay="delaySecond" style="width: 300px; z-index: 2000; position: fixed; top: 30px; right: 30px;")
    .toast-header
      strong.mr-auto 通知
      small たったいま
      button.ml-2.mb-1.close(type="button" data-dismiss="toast" aria-label="Close")
        span(aria-hidden="true") &times;
    .toast-body {{ message }}
</template>

<script>
import Vue from 'vue'

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
        $('.toast').toast('show')
      } else {
        $('.toast').toast('hide')
      }
    },
  },
  computed: {
    delaySecond () {
      // NOTE: エラー時だけ長い時間にしたかったが、多分toastの作りのせいで、初回表示時の設定が効いてしまって変わらないので、デフォルトで長い時間にしておく
      return 4000 // this.isError ? 4000 : 2000
    }
  },
  mounted () {
    $('.toast').on('hidden.bs.toast', () => {
      this.$emit('toast-hidden')
    })
  },
}
</script>

<style scoped lang="sass">
  .toast
    // NOTE: Bootstrapのcolorの使用方法
    background-color: var(--primary)
    color: #fff
    &.toast-error
      background-color: red
      color: white
</style>

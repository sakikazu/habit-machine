<comment>
  親からpropsを通じて値を渡し、子から親に値の更新を指図もでき、親で更新された時も子で検知できる仕組みにしている
</comment>

<template lang="pug">
  .toast(v-show="showable" :class="{'toast-error': isError}" data-autohide="true" :data-delay="delaySecond" style="width: 300px; z-index: 2000; position: absolute; top: 30px; right: 30px;")
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
    // TODO: 効いてない。data属性をv-bindするには？
    delaySecond () {
      return this.isError ? 3000 : 1500
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
</style>

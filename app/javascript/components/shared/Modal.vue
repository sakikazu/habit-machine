<template lang="pug">
.MemberModal
  .MemberModal_background(@click="closeModal")
  .MemberModal_wrapper(:style="{ 'width': wrapperWidth }")
    .MemberModal_controls
      a(href="javascript:void(0)" @click="expandWidth")
        i.fa.fa-expand
      // a(href="javascript:void(0)" @click="closeModal")
        // i.fa.fa-times
    .MemberModal_contentWrapper
      template(v-if="noPadding")
        slot(name="content")
      template(v-else)
        .MemberModal_content
          slot(name="content")

      .MemberModal_buttons(v-if="hasButtonsSlot")
        slot(name="buttons")
</template>

<script>
export default {
  name: "Modal",
  props: {
    noPadding: {
      type: Boolean,
      default: false
    },
  },
  data () {
    return {
      wrapperWidth: '800px',
    }
  },
  computed: {
    hasButtonsSlot () {
      return !!this.$slots.buttons
    }
  },
  methods: {
    expandWidth () {
      this.wrapperWidth = '90%'
    },
    closeModal () {
      this.$emit('on-close')
    },
  }
}
</script>

<style scoped lang="sass">
.MemberModal
  @at-root
    &
      display: flex
      align-items: center
      flex-direction: column
      justify-content: center
      overflow: hidden
      position: fixed
      z-index: 20000
      top: 0
      bottom: 0
      left: 0
      right: 0

    .MemberModal_background
      background-color: #5C5C5C
      opacity: 0.8
      position: fixed
      top: 0
      bottom: 0
      left: 0
      right: 0

    .MemberModal_wrapper
      position: relative
      max-width: 1400px

    .MemberModal_controls
      text-align: right

      a
        display: inline-block
        margin-left: 18px
        color: #fff
        font-size: 1.5rem

    .MemberModal_contentWrapper
      max-height: calc(100vh - 60px)
      margin: 0 auto
      overflow-y: scroll

    .MemberModal_content
      padding: 24px
      background-color: white
      border-radius: 4px
      box-sizing: border-box
      text-align: left

    .MemberModal_title
      font-size: 32px
      margin: 0
    .MemberModal_description
      font-size: 16px
      margin: 8px 0 0

    .MemberModal_buttons
      display: flex
      justify-content: space-between
      margin-top: 40px
    .MemberModal_button
      &.-back
      &.-accept
        margin-left: auto

    @media screen and (max-width:  640px)
      .MemberModal_contentWrapper
        overflow-y: auto
        width: calc( 100% - 40px)
      .MemberModal_buttons
        flex-direction: column
      .MemberModal_button
        &.-back
          order: 2
          margin-top: 40px
        &.-accept
          margin-left: 0
          order: 1
</style>

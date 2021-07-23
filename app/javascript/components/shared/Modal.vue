<template lang="pug">
.MemberModal
  .MemberModal_background(@click="closeModal")
  .MemberModal_contentWrapper(:class="{ '-expand': isExpand}")
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
    isExpand: {
      type: Boolean,
      default: false
    },
  },
  computed: {
    hasButtonsSlot () {
      return !!this.$slots.buttons
    }
  },
  methods: {
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

    .MemberModal_contentWrapper
      overflow-y: scroll
      max-height: calc(100vh - 80px)
      position: relative
      margin: auto
      width: 800px
      &.-expand
        width: 75%

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
        &.-expand
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

<template lang="pug">
.card.mb15
  h5.card-header.p-2
    .habit-title
      a(:href="`/habits/${habit.id}`") {{ habit.title }}
    i.saveButton.fa.fa-floppy-o(@click="save" v-if="dataChanged")
    i.editButton.fa.fa-pencil(@click="toggleEdit" v-else)
  .card-body.p-2(v-if="editMode || persisted")
    template(v-if="editMode")
      .recordValueInput
        select.form-control.mr-2(v-model="recordValue" ref="inputValue" v-if="habit.value_type === 'collection'")
          option(v-for="opt in habit.value_collection" v-text="opt[0]" :value="opt[1]")
        input.form-control.mr-2(type="text" v-model="recordValue" ref="inputValue" v-else)
        span {{ habit.value_unit }}
      .card-text.mt10
        textarea.form-control(placeholder="メモ入力" v-model="recordMemo")
    template(v-else-if="persisted")
      span.badge.badge-light
        // todo: valueないとき、（未入力）とか入れる？
        span.text-140.mr-1 {{ initialRecord.value }}
        span {{ habit.value_unit }}
      .card-text.mt10
        span.text-danger(v-html="nl2br(initialRecord.memo)")
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { nl2br } from 'helper.js'

export default {
  inheritAttrs: false, // 非prop属性をルート要素に適用したくない場合
  props: {
    habit: {
      type: Object,
      required: true,
    },
    record: {
      type: Object,
      required: true,
    },
    targetDate: {
      type: String,
      required: true,
    },
  },
  data () {
    return {
      editMode: false,
      initialRecord: null,
      recordValue: null,
      recordMemo: null,
    }
  },
  computed: {
    persisted () {
      return this.initialRecord?.id !== null
    },
    valueChanged () {
      return (!!this.initialRecord?.value || !!this.recordValue) && this.initialRecord?.value != this.recordValue
    },
    memoChanged () {
      return (!!this.initialRecord?.memo || !!this.recordMemo) && this.initialRecord?.memo != this.recordMemo
    },
    dataChanged () {
      return this.valueChanged  || this.memoChanged
    },
  },
  created () {
    // NOTE: mountedではなくcreatedで実行することで、template内でinitialRecordがundefinedにならないようにしている
    // templateはcreatedとmountedの間に処理されるという感じかな
    this.resetRecordVals(this.record)
  },
  mounted () {
  },
  methods: {
    nl2br,
    toggleEdit () {
      this.editMode = !this.editMode
      if (this.editMode) {
        const vm = this
        Vue.nextTick().then(function() {
          vm.$refs.inputValue.focus()
        })
      }
    },
    save () {
      if (this.persisted) {
        // TODO: Axiosの設定で、json形式のリクエストにすれば、拡張子不要な気がする
        HmAxios.patch(`/records/${this.initialRecord.id}.json`, {
          record: {
            value: this.recordValue,
            memo: this.recordMemo,
          }
        })
          .then(res => {
            this.resetRecordVals(res.data.record)
            this.editMode = false
          })
          .catch(error => {
            alert(error.response.data.message)
          })
      } else {
        HmAxios.post('/records.json', {
          record: {
            habit_id: this.habit.id,
            record_at: this.targetDate,
            value: this.recordValue,
            memo: this.recordMemo,
          }
        })
          .then(res => {
            this.resetRecordVals(res.data.record)
            this.editMode = false
          })
          .catch(error => {
            alert(error.response.data.message)
          })
      }
    },
    resetRecordVals (record) {
      this.initialRecord = record
      this.recordValue = record.value
      this.recordMemo = record.memo
    }
  }
}
</script>

<style scoped lang="sass">
  .card-header
    display: flex

    .habit-title
      flex-grow: 1
    i
      display: inline-block
      cursor: pointer
      padding: 5px 20px
      text-align: center
      border-radius: 5px

      &.editButton
        color: #17a2b8
        border: 1px solid #17a2b8
        &:hover
          color: white
          background-color: #17a2b8
      &.saveButton
        color: #dc3545
        border: 1px solid #dc3545
        &:hover
          color: white
          background-color: #dc3545

  .recordValueInput
    display: flex
    align-items: center
    color: #212529
    background-color: #f8f9fa
    padding: 5px 7px
    border-radius: 5px

    .form-control
      width: 100px
</style>

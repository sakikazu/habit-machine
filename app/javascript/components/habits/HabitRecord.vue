<template lang="pug">
.card.mb15
  h5.card-header.p-2(:class="{ 'text-dark bg-warning': habit.for_family }")
    .habit-title
      a(:href="`/habits/${habit.id}`")
        i.fa.fa-users.mr-1(v-if="habit.for_family")
        | {{ habit.title }}
    i.button.saveButton.fa.fa-floppy-o(@click="save" v-if="dataChanged")
    i.button.editButton.fa.fa-pencil(@click="toggleEdit" v-else)
  .card-body.p-2(v-if="editMode || persisted")
    template(v-if="editMode")
      .recordValueInput
        .recordValueInputLeft
          select.form-control.mr-2(v-model="recordValue" ref="inputValue" v-if="habit.value_type === 'collection'")
            option(v-for="opt in habit.value_collection" v-text="opt[0]" :value="opt[1]")
          input.form-control.mr-2(type="text" v-model="recordValue" ref="inputValue" v-else)
          span {{ habit.value_unit }}
        .recordValueInputRight
          i.button.addTemplate.fa.fa-plus-circle.fa-1_5x(@click="addTemplate" v-if="habit.template !== null")
      .card-text.mt10
        textarea.form-control(placeholder="メモ入力" v-model="recordMemo" @input="onInputRecordMemo($event)" ref="markdownable_textarea" rows="5")
    template(v-else-if="persisted")
      span.badge.badge-light
        // todo: valueないとき、（未入力）とか入れる？
        span.text-140.mr-1 {{ initialRecord.value }}
        span {{ habit.value_unit }}
      .card-text.mt10
        span.text-danger.markdown(v-html="initialRecord.markdowned_memo")
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'

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
    toggleEdit () {
      this.editMode = !this.editMode
      if (this.editMode) {
        const vm = this
        Vue.nextTick().then(function() {
          vm.$refs.inputValue.focus()
          $(vm.$refs.markdownable_textarea).markdownEasily()
        })
      }
    },
    addTemplate () {
      if (this.recordMemo === null) {
        this.recordMemo = ''
      }
      if (this.recordMemo !== '' && this.recordMemo.slice(-1) !== "\n") {
        this.recordMemo = this.recordMemo + "\n"
      }
      this.recordMemo = this.recordMemo + this.habit.template
    },
    // TODO: JS的にリファクタリングしたいな
    onInputRecordMemo (event) {
      if (this.habit.template === null) { return }
      // NOTE: Android Chrome の場合、数字を入力時でもこのreturnにひっかかってしまったのでコメントアウト
      // この処理を復活させるなら Backspace の時もreturnしないようにしないと
      // 数値以外の入力時はスルー
      // if (event.data === null || event.data.match(/\d/) === null) { return }

      // TODO: recordMemo から一発で値の配列を取り出せるリファクタリングをしたいが、JSで改行ごとに分割する正規表現できる？
      let summary = null
      const rows = this.recordMemo.split(/\r\n|\n/)
      rows.forEach(row => {
        // TODO: 円、のところを変数にする
        let val = row.match(/^- .*：(\d+)\s*円$/)
        if (val !== null) {
          summary += Number(val[1])
        }
      })
      if (summary !== null) {
        this.recordValue = summary
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
  i.button
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
    &.addTemplate
      padding: 0

  .card-header
    display: flex

    .habit-title
      flex-grow: 1
      a
        font-size: 1rem
        font-weight: bold

  .recordValueInput
    display: flex
    justify-content: space-between
    align-items: center
    color: #212529
    background-color: #f8f9fa
    padding: 5px 7px
    border-radius: 5px

    .form-control
      width: 100px

    .recordValueInputLeft
      display: flex
      align-items: center
</style>

<template lang="pug">
.TaskDiary
  a(@click="showModal" href="javascript:void(0)")
    i.fa.fa-window-maximize
    | &nbsp;
    | {{ diary.title }}
  .check-block(v-if="hasTask")
    .line(v-for="(task, idx) in tasks")
      h3(v-text="task.label" v-if="task.type === 'header'")
      .check-field.form-check(v-else-if="task.type === 'check'")
        input.form-check-input(type="checkbox" :id="`task-${diary.id}-${idx}`" v-model="tasks[idx].state")
        label.form-check-label(:for="`task-${diary.id}-${idx}`" v-text="task.label")
    .saveButton
      button.btn.btn-danger.btn-sm(@click="saveDiary" :disabled="!saveButtonEnabled") 更新
</template>

<script>
import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { truncate } from 'helper.js'

export default {
  inheritAttrs: false,
  components: {},
  props: {
    diary: {
      type: Object,
      required: true,
    },
  },
  data () {
    return {
      tasks: [],
      taskRegex: /\s*\-\s\[([ x])\]\s*(.*)/,
      headerRegex: /^#+\s*(.*)/,
    }
  },
  watch: {
    'diary.content': function(_newVal) {
      this.buildTasks()
    },
  },
  computed: {
    hasTask () {
      // 対象：`- [ ]` or `- [x]`
      return !!this.diary.content.match(this.taskRegex)
    },
    // TODO: save後にまたdisabledにしたいところだけど、後でやる
    saveButtonEnabled () {
      return this.tasks.some((task) => {
        return task.type === 'check' && task.state != task.orgState
      })
    },
  },
  mounted () {
    if (this.hasTask) { this.buildTasks() }
  },
  methods: {
    showModal () {
      this.$emit('show-diary-modal', this.diary.id)
    },
    buildTasks () {
      this.tasks = []
      const lines = this.diary.content.split(/\r\n|\n|\r/);
      lines.forEach((line) => {
        // ヘッダー行
        if (line.match(this.headerRegex)) {
          const result = line.match(this.headerRegex)
          this.tasks.push({ type: 'header', label: result[1], orgText: line })
        } else if (line.match(this.taskRegex)) {
          const result = line.match(this.taskRegex)
          const state = result[1] === 'x' ? true : false
          // truncate、thisをつけなくてもimportしたまんまで使えたのか
          const label = truncate(result[2], 25)
          this.tasks.push({ type: 'check', label: label, state, orgState: state, orgText: line })
        } else {
          this.tasks.push({ type: 'ignored', orgText: line })
        }
      })
    },
    buildUpdatingContent () {
      let lines = []
      this.tasks.forEach((line) => {
        let modifiedText = line.orgText
        if (line.type === 'check') {
          const replacedCheck = line.state ? '- [x]' : '- [ ]'
          modifiedText = line.orgText.replace(/- \[.\]/, replacedCheck)
        }
        lines.push(modifiedText)
      })
      return lines.join('\n')
    },
    saveDiary () {
      HmAxios.patch(`/diaries/${this.diary.id}.json`,
        { diary: { content: this.buildUpdatingContent() } }
      )
        .then(then => {
          this.$emit('updated', { message: '更新しました' })
        })
        .catch(error => {
          alert(error?.response?.data?.message || error.message)
        })
    },
  }
}
</script>

<style scoped lang="sass">
  .check-block
    padding: 7px 9px
    border: 1px solid gray
    border-radius: 5px

    h3
      font-size: 1.2rem
      font-weight: bold
      margin-top: 10px
    .saveButton
      margin-top: 15px
      button
        width: 100px
  .check-field
    font-size: 0.9rem
    margin-bottom: 7px
    input, label
      cursor: pointer
</style>

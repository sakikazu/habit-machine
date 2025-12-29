import Vue from 'vue'
import HmAxios from 'hm_axios.js'

import draggable from 'vuedraggable'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#todoPage',
    components: {
      'draggable': draggable,
    },
    data: {
      todos: [],
      todos_p0: [],
      todos_p1: [],
      todos_p2: [],
    },
    mounted () {
      this.fetchData()
    },
    methods: {
      fetchData () {
        HmAxios.get(`/todos.json`)
          .then(res => {
            this.todos = res.data
            this.todos_p0 = res.data.filter(todo => todo.priority == 0)
            this.todos_p1 = res.data.filter(todo => todo.priority == 1)
            this.todos_p2 = res.data.filter(todo => todo.priority == 2)
          })
          .catch(error => {
            alert(error.message || error.response.data.message)
          })
      },
      bulkUpdate () {
        const items = this.todos_p0.map((item, idx) => {
          return { id: item.id, priority: 0, sort_order: idx }
        })
        HmAxios.put(`/todos/bulk_update.json`, {
          items: items
        })
      },
      bulkUpdate1 () {
        const items = this.todos_p1.map((item, idx) => {
          return { id: item.id, priority: 1, sort_order: idx }
        })
        HmAxios.put(`/todos/bulk_update.json`, {
          items: items
        })
      },
      bulkUpdate2 () {
        const items = this.todos_p2.map((item, idx) => {
          return { id: item.id, priority: 2, sort_order: idx }
        })
        HmAxios.put(`/todos/bulk_update.json`, {
          items: items
        })
      },
      onEnd: function(customEvent) {
        console.log(customEvent);
      }
    }
  })
})

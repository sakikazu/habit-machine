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
      items: [
        { id: 1, name: 'aa', category: 1 },
        { id: 2, name: 'bb', category: 2 },
        { id: 3, name: 'cc', category: 3 },
      ],
      items2: [
        { id: 11, name: 'xx', category: 1 },
        { id: 12, name: 'yyy', category: 2 },
        { id: 13, name: 'zz', category: 3 },
      ],
    },
    methods: {
      onEnd: function(originalEvent) {
        console.log(originalEvent);
      }
    }
  })
})

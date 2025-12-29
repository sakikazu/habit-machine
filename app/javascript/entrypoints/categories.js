import Vue from 'vue'
import HmAxios from 'hm_axios.js'

import Categories from 'components/categories/Index'

document.addEventListener('turbolinks:load', () => {
  const vm = new Vue({
    el: '#categories',
    components: {
      Categories,
    },
  })
})

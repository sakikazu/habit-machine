import Vue from 'vue'
import HmAxios from 'hm_axios.js'
import { onPageLoad } from 'helper'

import Categories from 'components/categories/Index'

onPageLoad(() => {
  const vm = new Vue({
    el: '#categories',
    components: {
      Categories,
    },
  })
})

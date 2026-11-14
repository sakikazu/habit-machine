import { createApp } from 'vue'

import Categories from 'components/categories/Index'

document.addEventListener('turbolinks:load', () => {
  createApp({
    components: {
      Categories,
    },
  }).mount('#categories')
})

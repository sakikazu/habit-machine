import { createApp } from 'vue'

import Categories from 'components/categories/Index'
import { mountVueOnTurbolinks } from 'vue_turbolinks.js'

mountVueOnTurbolinks('#categories', (element) => createApp({
    components: {
      Categories,
    },
}))

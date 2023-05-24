import { createApp } from 'vue'
import * as common from 'common'

  createApp({
    name: "tranzactions",
    mounted() {
      debugger
    },
    data() {
      return {
        tranzaction: {
          entries_attributes: [{}]
        },
        companies: [{}]
      }
    },
    methods: {
    },
    computed: {
    }
  }).mount('#vue-tranzactions')

import { createApp } from 'vue'

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

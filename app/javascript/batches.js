import { createApp } from 'vue'


  createApp({
    mounted() {
      $.ajax({
        url: `/batches/${1}/edit`,
        type: "GET",
        dataType: 'json',
        success: e => {
          this.batch = e
        },
      });
    },
    data() {
      return {
        batch: undefined
      }
    },
    computed: {
      entries() {
        this.batch
      }
    }
  }).mount('#vue-batches')
import { createApp } from 'vue'


  createApp({
    name: "general_ledger",
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
        batch: {
          tranzactions: [
            {
              entries: [{}]
            }
          ]
        }
      }
    },
    methods: {
      getAmount(entry) {
        return entry.amount
      },
      setAmount(entry) {
        entry.amount = event.currentTarget.value
      }
    },
    computed: {
      entries() {
        return this.batch.tranzactions.map(tranzaction => tranzaction.entries).flat()
      }
    }
  }).mount('#vue-batches')
import { createApp } from 'vue'
import * as common from 'common'

  createApp({
    name: "tranzactions",
    mounted() {
      const tranzactionURL = railsParams.id ? `${railsParams.id}/edit` : 'new';
      $.ajax({
        url: `/tranzactions/${tranzactionURL}?batch_id=${railsParams.batch_id}`,
        type: "GET",
        dataType: 'json',
        success: resp => {
          this.batch = resp.batch;
          this.tranzaction = resp.tranzaction;
          this.companies = resp.companies;
        },
      });
    },
    data() {
      return {
        batch: {},
        tranzaction: {
          entries_attributes: [
            {
              designation: 'primary',
            },
            {
              designation: 'distribution',
            }
          ]
        },
        companies: [{}]
      }
    },
    methods: {
    },
    computed: {
    }
  }).mount('#vue-tranzactions')

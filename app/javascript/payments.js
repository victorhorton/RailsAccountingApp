import { createApp } from 'vue'
import * as common from 'common'

if ($('#vue-payments').length) {
  createApp({
    name: "payments",
    mounted() {

      window.print();
      window.addEventListener('afterprint', (event) => {
        this.submitForm()
      })

      $.ajax({
        url: `/tranzactions/${railsParams.id}/print`,
        type: "GET",
        dataType: 'json',
        success: resp => {
          this.tranzaction = resp.tranzaction;
          this.batch = resp.batch;
        },
      });
    },
    data() {
      return {
        tranzaction: {
          payments_attributes: [
            {
              tranzaction_attributes: {

              }
            }
          ]
        },
        batch: {}
      }
    },
    methods: {
      submitForm() {

        const completed_at = new Date().toISOString().slice(0, 19).replace('T', ' ');

        const payments_attributes = this.tranzaction.payments_attributes.map(payment => {
          return {
            id: payment.id,
            tranzaction_attributes: {
              id: payment.tranzaction_attributes.id,
              completed_at
            }
          }
        });

        const tranzaction = {
          id: this.tranzaction.id,
          payments_attributes
        };

        $.ajax({
          url: `/tranzactions/${this.tranzaction.id}`,
          type: 'PATCH',
          dataType: 'json',
          headers: {
            "X-CSRF-Token": $('[name=csrf-token]')[0].content,
          },
          data: {
            tranzaction
          },
          success:  e => {
            window.location = `/batches?purpose=${this.batch.purpose}`
          },
          error:  e => {
            location.reload()
          }
        });
      }
    },
  }).mount('#vue-payments')
}

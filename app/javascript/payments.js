// window.onload = function() {
//   window.print();
//   window.addEventListener('afterprint', (event) => {

//     const completed_at = new Date().toISOString().slice(0, 19).replace('T', ' ');

//     if (confirm('Check(s) print correctly?')) {
//       $.ajax({
//         url: `/payments/${railsParams.id}`,
//         method: 'PATCH',
//         dataType: 'json',
//         data: {
//           payment: {
//             id: railsParams.id,
//             tranzaction_attributes: {
//               id: <%= @payment.tranzaction.id %>,
//               completed_at,
//             }
//           }
//         },
//         headers: {
//           'X-CSRF-Token': '<%= form_authenticity_token.to_s %>'
//         },
//         success: resp => {
//           debugger
//           window.location = '/'
//         },
//         error: resp => {
//           console.log(`ERROR!!! ${resp}`)
//         }
//       });
//     } else {
//       window.close();
//     }
//   })
// }

import { createApp } from 'vue'
import * as common from 'common'

createApp({
  name: "payments",
  mounted() {

    window.print();
    window.addEventListener('afterprint', (event) => {
      this.submitForm()
    })

    $.ajax({
      url: `/payments/${railsParams.id}/print`,
      type: "GET",
      dataType: 'json',
      success: resp => {
        this.payment = resp.payment;
      },
    });
  },
  data() {
    return {
      payment: {
        tranzaction_attributes: {

        }
      }
    }
  },
  methods: {
    submitForm() {

      const completed_at = new Date().toISOString().slice(0, 19).replace('T', ' ');
      this.payment.tranzaction_attributes.completed_at = completed_at;

      $.ajax({
        url: `/payments/${this.payment.id}`,
        type: 'PATCH',
        dataType: 'json',
        headers: {
          "X-CSRF-Token": $('[name=csrf-token]')[0].content,
        },
        data: {
          payment: this.payment
        },
        success:  e => {
          debugger
          window.location = `/batches?purpose=${this.batch.purpose}`
        },
        error:  e => {
          location.reload()
        }
      });
    }
  },
}).mount('#vue-payments')

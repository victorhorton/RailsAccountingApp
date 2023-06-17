import { createApp } from 'vue'
import * as common from 'common'

if ($('#vue-batches').length) {
  createApp({
    name: "batches",
    mounted() {
      $.ajax({
        url: `/batches/${railsParams.id}/edit`,
        type: "GET",
        dataType: 'json',
        success: resp => {
          this.batch = resp.batch
          this.companies = resp.companies
        },
      });
    },
    data() {
      return {
        batch: {
          tranzactions_attributes: [
            {
              entries_attributes: [{}]
            }
          ]
        },
        companies: [{}]
      }
    },
    methods: {
      adjustTranzactions(entry, primaryKey, value) {
        const secondaryKey = primaryKey === 'date' ? 'company_id' : 'date';
        const tranzactions = this.batch.tranzactions_attributes;
        const currentTranzaction = tranzactions.find(t => {
          return t.entries_attributes.includes(entry)
        });
        const matchedTranzaction = tranzactions.find(t => {
          return t[primaryKey] === value && t[secondaryKey] === currentTranzaction[secondaryKey];
        });

        if (currentTranzaction[primaryKey] === value) {
          return
        }
        else if (entry.id !== undefined || currentTranzaction === matchedTranzaction) {
          currentTranzaction[primaryKey] = value
        } else if (matchedTranzaction !== undefined) {
          currentTranzaction.entries_attributes.splice(currentTranzaction.entries_attributes.indexOf(entry), 1);

          if (currentTranzaction.entries_attributes.length === 0) {
            tranzactions.splice(tranzactions.indexOf(currentTranzaction), 1)
          }

          matchedTranzaction.entries_attributes.push(entry)
        } else {

          currentTranzaction.entries_attributes.splice(currentTranzaction.entries_attributes.indexOf(entry), 1);

          if (currentTranzaction.entries_attributes.length === 0) {
            tranzactions.splice(tranzactions.indexOf(currentTranzaction), 1)
          }

          const company_id = primaryKey === 'company_id' ? value : currentTranzaction.company_id;
          const date = primaryKey === 'date' ? value : currentTranzaction.date;

          tranzactions.push({
            company_id,
            date,
            entries_attributes: [
              entry
            ]
          })
        }
      },
      addEntry() {
        const nextPosition = this.entries[this.entries.length - 1].position + 1
        const tranzactions = this.batch.tranzactions_attributes;
        const lastTranzactionIdx = tranzactions.length - 1;
        tranzactions[lastTranzactionIdx].entries_attributes.push({
          designation: 'distribution',
          position: nextPosition
        })
      },
      getAmount(entry, entryType) {
        if (entry.entry_type === entryType) {
          return common.parseAmount(entry.amount);
        } else {
          return
        }
      },
      setAmount(entry) {
        const entryType = event.currentTarget.name;
        const entryAmount = parseFloat(event.currentTarget.value);

        if (entryAmount || entryAmount == 0) {
          entry.entry_type = entryType;
          entry.amount = entryAmount;
        } else {
          return
        }

      },
      getDate(entry) {
        const date = this.batch.tranzactions_attributes.find(t => {
          return t.entries_attributes.includes(entry)
        }).date;
        return common.parseDate(date);
      },
      deleteEntry(entry) {
        const tranzactions = this.batch.tranzactions_attributes;
        const tranzaction = tranzactions.find(t => {
          return t.entries_attributes.includes(entry)
        });

        common.deleteEntry(entry, tranzaction);

        if (tranzaction.entries_attributes.filter(e => e.deleted_at == null).length === 0) {
          if (tranzaction.id != undefined) {
            $.ajax({
              url: `/tranzactions/${tranzaction.id}`,
              type: "DELETE",
              headers: {
                "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
              },
            });
          }
          tranzactions.splice(tranzactions.indexOf(tranzaction), 1);
        }

      },
      setDate(entry) {
        const date = event.currentTarget.value;
        const sqlDate = common.formatDate(date);
        this.adjustTranzactions(entry, 'date', sqlDate)
      },
      getCompany(entry) {
        const company_id = this.batch.tranzactions_attributes.find(t => {
          return t.entries_attributes.includes(entry)
        }).company_id;

        if (!company_id) {
          return
        }

        return this.companies.find(c => c.id === company_id).code;
      },
      setCompany(entry) {
        const companyCode = event.currentTarget.value.toUpperCase();
        const company = this.companies.find(c => c.code === companyCode);
        if (company) {
          this.adjustTranzactions(entry, 'company_id', company.id)
        }
      },
      submitForm() {
        $.ajax({
          url: `/batches/${this.batch.id}`,
          type: "PATCH",
          dataType: 'json',
          headers: {
            "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
          },
          data: {
            batch: this.batch
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
    computed: {
      entries() {
        return this.batch.tranzactions_attributes.map(tranzaction => {
          return tranzaction.entries_attributes
        }).flat().sort((a, b) => {
          var x = a.position; var y = b.position;
          return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        })
      }
    }
  }).mount('#vue-batches')
}

if ($('#vue-batches-unpaid').length) {
  createApp({
    name: "unpaidBatch",
    mounted() {
      $.ajax({
        url: '/batches/unpaid',
        type: "GET",
        data: {
          purpose: 'payable'
        },
        dataType: 'json',
        success: resp => {
          this.unmarkedTranzactions = resp.tranzactions;
        },
      });
    },
    data() {
      return {
        unmarkedTranzactions: [{}],
        batch: {
          name: 'Payment Batch',
          purpose: 'payment',
          tranzactions_attributes: [
            {
              tranzaction_type: 'payment',
              company_id: 1,
              contact_id: 1,
              payment_attributes: {
                payment_type: 'check',
                invoice_ids: [],
              },
              entries_attributes: [
                {
                  designation: 'primary',
                  entry_type: 'debit',
                  account_id: 2010,
                },
                {
                  designation: 'distribution',
                  entry_type: 'credit'
                }
              ]
            }
          ]
        }
      }
    },
    methods: {
      toggleTranzaction(tranzaction) {
        const invoice_ids = this.batch.tranzactions_attributes[0].payment_attributes.invoice_ids;
        if (event.currentTarget.checked) {
          invoice_ids.push(tranzaction.id)
        } else {
          invoice_ids.splice(invoice_ids.indexOf(tranzaction.id), 1)
        }
      },
      setPaymentAmount(payment) {
        const entryAmount = parseFloat(event.currentTarget.value.replace(',', ''));
        const paymentEntries = this.tranzactionPayment.entries_attributes;
        paymentEntries.forEach(entry => {
          return entry.amount = entryAmount
        })
      },
      setPaymentAccount(payment) {
        const paymentAccount = event.currentTarget.value;
        this.tranzactionPayment.entries_attributes.find(e => {
          return e.designation === 'distribution'
        }).account_id = paymentAccount;
      },
      setDate(tranzaction) {
        const date = event.currentTarget.value;
        tranzaction.date = common.formatDate(date);
      },
      getPaymentAccount(payment) {
        return this.tranzactionPayment.entries_attributes.find(e => {
          return e.designation === 'distribution'
        }).account_id
      },
      getDate(tranzaction) {
        return common.parseDate(tranzaction.date);
      },
      getPaymentAmount(payment) {
        const entryAmount = this.tranzactionPayment.entries_attributes.find(e => {
          return e.designation === 'primary'
        }).amount

        return common.parseAmount(entryAmount);
      },
      submitForm() {
        $.ajax({
          url: `/batches`,
          type: "POST",
          dataType: 'json',
          headers: {
            "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
          },
          data: {
            batch: this.batch
          },
          success: e => {
            debugger
          },
          error: e => {
            debugger
          }
        });
      }
    },
    computed: {
      tranzactionPayment() {
        return this.batch.tranzactions_attributes[0];
      },
      payment() {
        const payment = this.batch.tranzactions_attributes[0].payment_attributes;
        const tranzactionsAttributes = {...this.batch.tranzactions_attributes[0]}
        delete tranzactionsAttributes.payment_attributes;
        payment.tranzaction_attributes = tranzactionsAttributes;
        return payment
      }
    }
  }).mount('#vue-batches-unpaid')
}

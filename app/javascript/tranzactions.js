import { createApp } from 'vue'
import * as common from 'common'

if ($('#vue-tranzactions').length) {
  createApp({
    name: "tranzactions",
    mounted() {
      let url = `/tranzactions/new?batch_id=${railsParams.batch_id}`
      if (railsParams.action === 'edit') {
        url = `/tranzactions/${railsParams.id}/edit`
      }
      const tranzactionURL = railsParams.id ? `${railsParams.id}/edit` : 'new';
      $.ajax({
        url,
        type: "GET",
        dataType: 'json',
        success: resp => {

          if (railsParams.id == localStorage.getItem('id')) {
            this.batch = JSON.parse(localStorage.getItem('batch'));
            this.tranzaction = JSON.parse(localStorage.getItem('tranzaction'));
          } else {
            this.batch = resp.batch;
            this.tranzaction = resp.tranzaction;
            localStorage.setItem('batch', JSON.stringify(resp.batch));
            localStorage.setItem('tranzaction', JSON.stringify(resp.tranzaction));
            localStorage.setItem('id', railsParams.id);
          }

          this.companies = resp.companies;
          this.contacts = resp.contacts;
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
          ],
          payments_attributes: [
            {
              tranzaction_attributes: {
                entries_attributes: [
                  {
                    designation: 'primary',
                  },
                  {
                    designation: 'distribution',
                  }
                ],
              }
            }
          ]
        },
        companies: [{}],
        contacts: [{}]
      }
    },
    watch: {
      invoiceCompleted(newValue, oldValue) {
        this.tranzaction.completed_at = newValue;
      },
      tranzaction: {
        handler: function (val, oldVal) {
          localStorage.setItem('tranzaction', JSON.stringify(val));
        },
        deep: true
      },
    },
    methods: {
      addEntry() {
        const entries = this.tranzaction.entries_attributes;
        const nextPosition = entries[entries.length - 1].position + 1
        entries.push({
          designation: 'distribution',
          position: nextPosition
        })
      },
      setNumber(tranzaction) {
        const reference_number = event.currentTarget.value;
        tranzaction.reference_number = reference_number;
      },
      paymentTranzaction(payment) {
        return payment.tranzaction_attributes;
      },
      deleteEntry(entry) {
        common.deleteEntry(entry, this.tranzaction)
      },
      getAmount(entry) {
        const batchisPayable = this.batch.purpose === 'payable';
        const entryIsDebit = entry.entry_type == 'debit';
        const isPrimaryEntry = entry.designation == 'primary';
        let entryAmount = entry.amount;

        if (
          (batchisPayable && entryIsDebit && isPrimaryEntry) ||
          (batchisPayable && !entryIsDebit && !isPrimaryEntry) ||
          (!batchisPayable && !entryIsDebit && isPrimaryEntry) ||
          (!batchisPayable && entryIsDebit && !isPrimaryEntry)
        ) {
          entryAmount *= -1;
        }

        return common.parseAmount(entryAmount);
      },
      setAmount(entry) {
        let entryType = undefined;
        let entryAmount = parseFloat(event.currentTarget.value.replace(',', ''));
        const batchPurpose = this.batch.purpose;
        const batchIsPayable = batchPurpose == 'payable';
        const entryIsNegative = entryAmount < 0;
        const isPrimaryEntry = entry.designation == 'primary';

        if (batchPurpose == 'payable')
          if (entryIsNegative && isPrimaryEntry) {
            entryType = 'debit'
            entryAmount *= -1;
          } else if (!entryIsNegative && isPrimaryEntry) {
            entryType = 'credit'
          } else if (entryIsNegative && !isPrimaryEntry) {
            entryType = 'credit'
            entryAmount *= -1;
          } else {
            entryType = 'debit'
          }
        else {
          if (entryIsNegative && isPrimaryEntry) {
            entryType = 'credit'
            entryAmount *= -1;
          } else if (!entryIsNegative && isPrimaryEntry) {
            entryType = 'debit'
          } else if (entryIsNegative && !isPrimaryEntry) {
            entryType = 'debit'
            entryAmount *= -1;
          } else {
            entryType = 'credit'
          }
        }

        if (entryAmount || entryAmount == 0) {
          entry.entry_type = entryType;
          entry.amount = entryAmount;
        } else {
          return
        }
      },
      getDate(tranzaction) {
        return common.parseDate(tranzaction.date);
      },
      setDate(tranzaction) {
        const date = event.currentTarget.value;
        tranzaction.date = common.formatDate(date);
      },
      getContact(tranzaction) {
        if (!tranzaction.contact_id) {
          return null
        }
        return this.contacts.find(c => c.id === tranzaction.contact_id).name
      },
      setContact(tranzaction) {
        const contactName = event.currentTarget.value;
        const contact = this.contacts.find(c => c.name.toUpperCase() === contactName.toUpperCase());
        this.tranzaction.contact_id = contact.id;
        this.payments.forEach(payment => {
          return payment.tranzaction_attributes.contact_id = contact.id;
        });
      },
      getCompany(tranzaction) {
        if (!tranzaction.company_id) {
          return null
        }
        return this.companies.find(c => c.id === tranzaction.company_id).code
      },
      setCompany(tranzaction) {
        const companyCode = event.currentTarget.value.toUpperCase();
        const company = this.companies.find(c => c.code === companyCode);
        this.tranzaction.company_id = company.id;
        this.payments.forEach(payment => {
          return payment.tranzaction_attributes.company_id = company.id
        });
      },
      getPaymentAmount(payment) {
        const entryAmount = payment.tranzaction_attributes.entries_attributes.find(e => {
          return e.designation === 'primary'
        }).amount

        return common.parseAmount(entryAmount);
      },
      setPaymentAmount(payment) {
        const entryAmount = parseFloat(event.currentTarget.value.replace(',', ''));
        const paymentEntries = payment.tranzaction_attributes.entries_attributes;
        paymentEntries.forEach(entry => {
          return entry.amount = entryAmount
        })
      },
      getPaymentAccount(payment) {
        return payment.tranzaction_attributes.entries_attributes.find(e => {
          return e.designation === 'distribution'
        }).account_id
      },
      printAndSubmitForm() {
        $('button').prop("disabled",true)
        const isNew = railsParams.action === 'new'
        const url = isNew ? '/tranzactions' : `/tranzactions/${this.tranzaction.id}`;
        const type = isNew ? 'POST' : 'PATCH';
        $.ajax({
          url,
          type,
          dataType: 'json',
          headers: {
            "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
          },
          data: {
            tranzaction: this.tranzaction
          },
          success:  resp => {
            window.location = `/tranzactions/${this.tranzaction.id}/print`
          },
          error:  resp => {
            location.reload()
          }
        });
      },
      setPaymentAccount(payment) {
        const paymentAccount = event.currentTarget.value;
        payment.tranzaction_attributes.entries_attributes.find(e => {
          return e.designation === 'distribution'
        }).account_id = paymentAccount;
      },
      submitForm() {
        const paymentIsEmpty = $('.payment-input').map(function(idx, elem) {
          return $(elem).val();
        }).get().every(x => x === '')

        if (paymentIsEmpty) {
          delete this.tranzaction.payments_attributes
        }

        $('button').prop("disabled",true)
        const isNew = railsParams.action === 'new'
        const url = isNew ? '/tranzactions' : `/tranzactions/${this.tranzaction.id}`;
        const type = isNew ? 'POST' : 'PATCH';
        $.ajax({
          url,
          type,
          dataType: 'json',
          headers: {
            "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
          },
          data: {
            tranzaction: this.tranzaction
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
      checksPrintable() {
        return !this.payments.map(payment => payment.payment_type).includes('check')
      },
      payments() {
        return this.tranzaction.payments_attributes
      },
      primaryEntry() {
        return this.tranzaction.entries_attributes.find(entry => {
          return entry.designation === 'primary';
        })
      },
      distributionEntries() {
        return this.tranzaction.entries_attributes.filter(entry => {
          return entry.designation === 'distribution';
        })
      },
      debitEntries() {
        return this.tranzaction.entries_attributes.filter(entry => entry.entry_type == 'debit');
      },
      creditEntries() {
        return this.tranzaction.entries_attributes.filter(entry => entry.entry_type == 'credit');
      },
      debitTotal() {
        return this.debitEntries.map(entry => entry.amount || 0).reduce((a, b) => a + b, 0)
      },
      creditTotal() {
        return this.creditEntries.map(entry => entry.amount || 0).reduce((a, b) => a + b, 0)
      },
      amountToDistribute() {
        return this.debitTotal - this.creditTotal;
      },
      invoiceAmount() {
        let invoiceAmount = this.primaryEntry.amount;
        if (this.primaryEntry.entry_type === 'credit') {
          invoiceAmount *= -1;
        }
        return invoiceAmount;
      },
      paymentTotal() {
        return this.payments.map(payment => {
          const primaryEntry = payment.tranzaction_attributes.entries_attributes.find(entry => {
            return entry.designation === 'primary'
          });

          let primaryAmount = primaryEntry.amount;

          if (primaryEntry.entry_type === 'credit') {
            primaryAmount *= -1;
          }
          return primaryAmount
        }).flat().reduce((a, b) => a + b, 0)
      },
      invoiceCompleted() {
        if (this.invoiceAmount === this.paymentTotal * -1) {
          return new Date().toISOString().slice(0, 19).replace('T', ' ');
        } else {
          return null;
        }
      }
    }
  }).mount('#vue-tranzactions')
}

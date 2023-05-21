import { createApp } from 'vue'

$(document).ready(function() {
  createApp({
    name: "general_ledger",
    mounted() {
      $.ajax({
        url: `/batches/${1}/edit`,
        type: "GET",
        dataType: 'json',
        success: batch => {
          this.batch = batch
        },
      });
    },
    data() {
      return {
        batch: {
          tranzactions_attributes: [
            {
              entries_attributes: [{
                account_id: null
              }]
            }
          ]
        }
      }
    },
    methods: {
      addEntry() {
        const tranzactions = this.batch.tranzactions_attributes;
        const lastTranzactionIdx = tranzactions.length - 1;
        tranzactions[lastTranzactionIdx].entries_attributes.push({
          designation: 'distribution'
        })
      },
      getAmount(entry, entryType) {
        if (entry.entry_type === entryType) {
          let amount = `${entry.amount}`;
          const splitAmount = amount.split('.');
          const wholeNumber = parseFloat(splitAmount[0]).toLocaleString("en-US");
          let decimalNumber = splitAmount[1];
          if (decimalNumber == undefined || decimalNumber.length == 0) {
            decimalNumber = '00';
          } else if (decimalNumber.length == 1) {
            decimalNumber = `${decimalNumber}0`;
          }

          return `${wholeNumber}.${decimalNumber}`;
        } else {
          return
        }
      },
      setAmount(entry) {
        const entryType = event.currentTarget.name;
        const entryAmount = parseFloat(event.currentTarget.value);

        if (entryAmount) {
          entry.entry_type = entryType;
          entry.amount = entryAmount;
        } else {
          return
        }

      },
      getDate(entry) {
        const date = this.batch.tranzactions_attributes.find(t => t.entries_attributes.includes(entry)).date;
        if (!date) {
          return
        }
        const splitDate = date.split('-');
        const splitMonth = splitDate[1];
        const splitDay = splitDate[2];
        const splitYear = splitDate[0].substring(2, 4);
        return `${splitMonth}-${splitDay}-${splitYear}`;        
      },
      setDate(entry) {
        const date = event.currentTarget.value;
        const splitDate = date.split('-');
        const splitMonth = splitDate[0];
        const splitDay = splitDate[1];
        const splitYear = splitDate[2];
        const tranzaction = this.batch.tranzactions_attributes.find(t => t.entries_attributes.includes(entry));

        tranzaction.date = `20${splitYear}-${splitMonth}-${splitDay}`;
      },
      getCompany(entry) {
        return this.batch.tranzactions_attributes.find(t => t.entries_attributes.includes(entry)).company_id;
      },
      setCompany(entry) {
        const company_id = event.currentTarget.value;

        const tranzaction = this.batch.tranzactions_attributes.find(t => t.entries_attributes.includes(entry));
        tranzaction.company_id = company_id;
      },
      submitForm() {

        $.ajax({
          url: `/batches/${this.batch.id}`,
          type: "PATCH",
          headers: {
            "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
          },
          data: {
            batch: this.batch
          },
          success:  e => {
            window.location = '/batches'
          },
          error:  e => {
            location.reload()
          }
        });
      }
    },
    computed: {
      entries() {
        return this.batch.tranzactions_attributes.map(tranzaction => tranzaction.entries_attributes).flat()
      }
    }
  }).mount('#vue-batches')
})
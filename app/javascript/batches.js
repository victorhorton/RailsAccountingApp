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
      deleteEntry(entry) {
        const tranzactions = this.batch.tranzactions_attributes;
        const tranzaction = tranzactions.find(t => {
          return t.entries_attributes.includes(entry)
        });
        const entries = tranzaction.entries_attributes;

        if (entry.id != undefined) {
          $.ajax({
            url: `/entries/${entry.id}`,
            type: "DELETE",
            headers: {
              "X-CSRF-Token":  $('[name=csrf-token]')[0].content,
            },
          });
        }
        entries.splice(entries.indexOf(entry), 1);

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
        const splitDate = date.split('-');
        const sqlDate = `20${splitDate[2]}-${splitDate[0]}-${splitDate[1]}`;

        const tranzactions = this.batch.tranzactions_attributes;
        const currentTranzaction = tranzactions.find(t => {
          return t.entries_attributes.includes(entry)
        });
        const matchedTranzaction = tranzactions.find(t => {
          return t.date === sqlDate && t.company_id === currentTranzaction.company_id;
        });        

        if (currentTranzaction.date === sqlDate) {
          return
        }
        else if (entry.id !== undefined || currentTranzaction === matchedTranzaction) {
          currentTranzaction.date = sqlDate
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

          tranzactions.push({
            company_id: currentTranzaction.company_id,
            date: sqlDate,
            entries_attributes: [
              entry
            ]
          })
        }
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
import { createApp } from 'vue'


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
          tranzactions: [
            {
              entries: [{}]
            }
          ]
        }
      }
    },
    methods: {
      addEntry() {
        const tranzactions = this.batch.tranzactions;
        const lastTranzactionIdx = tranzactions.length - 1;
        tranzactions[lastTranzactionIdx].entries.push({
          designation: 'distribution'
        })
      },
      getAmount(entry, entryType) {
        if (entry.entry_type === entryType) {
          return entry.amount
        } else {
          return
        }
      },
      setAmount(entry) {
        const entryType = event.currentTarget.name;
        const entryAmount = event.currentTarget.value;

        if (entryAmount) {
          entry.entry_type = entryType;
          entry.amount = entryAmount;
        } else {
          return
        }

      },
      getDate(entry) {
        const date = this.batch.tranzactions.find(t => t.entries.includes(entry)).date;
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
        const tranzaction = this.batch.tranzactions.find(t => t.entries.includes(entry));

        tranzaction.date = `20${splitYear}-${splitMonth}-${splitDay}`;
      },
      getCompany(entry) {
        return this.batch.tranzactions.find(t => t.entries.includes(entry)).company;
      },
      setCompany(entry) {
        const tranzaction = this.batch.tranzactions.find(t => t.entries.includes(entry));
        const company = event.currentTarget.value;
        tranzaction.company = company;
      },
    },
    computed: {
      entries() {
        return this.batch.tranzactions.map(tranzaction => tranzaction.entries).flat()
      }
    }
  }).mount('#vue-batches')
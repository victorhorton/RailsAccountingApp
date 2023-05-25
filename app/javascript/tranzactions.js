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
      addEntry() {
        const entries = this.tranzaction.entries_attributes;
        const nextPosition = entries[entries.length - 1].position + 1
        entries.push({
          designation: 'distribution',
          position: nextPosition
        })
      },
      deleteEntry(entry) {
        const entries = this.tranzaction.entries_attributes;
        if (entries.length <= 2) {
          return
        }

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
      },
      getAmount(entry) {
        return common.parseAmount(entry.amount);
      },
      setAmount(entry, batchPurpose) {
        let entryType = undefined;
        const entryAmount = parseFloat(event.currentTarget.value);
        const batchIsPayable = batchPurpose == 'payable';
        const entryIsNegative = entryAmount < 0;
        const isPrimaryEntry = entry.designation == 'primary';

        if (batchPurpose == 'payable')
          if (entryIsNegative && isPrimaryEntry) {
            entryType = 'debit'
          } else if (!entryIsNegative && isPrimaryEntry) {
            entryType = 'credit'
          } else if (entryIsNegative && !isPrimaryEntry) {
            entryType = 'credit'
          } else {
            entryType = 'debit'
          }
        else {
          if (entryIsNegative && isPrimaryEntry) {
            entryType = 'credit'
          } else if (!entryIsNegative && isPrimaryEntry) {
            entryType = 'debit'
          } else if (entryIsNegative && !isPrimaryEntry) {
            entryType = 'debit'
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
      },
      submitForm() {
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
      primaryEntry() {
        return this.tranzaction.entries_attributes.find(entry => {
          return entry.designation === 'primary';
        })
      },
      distributionEntries() {
        return this.tranzaction.entries_attributes.filter(entry => {
          return entry.designation === 'distribution';
        })
      }
    }
  }).mount('#vue-tranzactions')

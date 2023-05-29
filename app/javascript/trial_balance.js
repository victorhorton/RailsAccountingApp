import * as common from 'common'

$(document).ready(function() {
  const trialBalanceDatatable = $('#trial-balance-datatable').DataTable({
    "processing": true,
    "serverSide": true,
    dom: 'ltiprB',
    buttons: 'excel'
    "ajax": {
      "url": $('#trial-balance-datatable').data('source')
    },
    footerCallback: function ( tfoot, data, start, end, display ) {
      const tableInfo = trialBalanceDatatable.page.info();
      const api = this.api();

      const debitColumn = api.column( 6 );
      const creditColumn = api.column( 7 );

      if (tableInfo.recordsDisplay != tableInfo.end) {
        $(debitColumn.footer()).html('');
        $(creditColumn.footer()).html('');
        return
      }

      const debit_total = common.sumTotals(debitColumn.data());
      const credit_total = common.sumTotals(creditColumn.data());

      $(debitColumn.footer()).html(`Debits: ${debit_total}`);
      $(creditColumn.footer()).html(`Credits: ${credit_total}`);
    },
    "pagingType": "full_numbers",
    "columns": [
      {"data": "account_id"},
      {"data": "purpose"},
      {"data": "contact"},
      {"data": "date"},
      {"data": "reference_number"},
      {"data": "company"},
      {"data": "debit"},
      {"data": "credit"},
    ]
    // pagingType is optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about
    // available options.
  }).columns().every(function () {
    const datatableColumns = this;
    $('input', this.header()).on('keyup change', function () {
      if (datatableColumns.search() !== this.value) {
        datatableColumns.search(this.value).draw();
      }
    });
  });
});

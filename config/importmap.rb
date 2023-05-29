# Pin npm packages by running ./bin/importmap

pin "application", preload: true
# pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "vue", to: "https://unpkg.com/vue@3/dist/vue.esm-browser.js", preload: true
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.js", preload: true
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js", preload: true
pin "datatables", to: "https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.13.4/b-2.3.6/b-html5-2.3.6/datatables.min.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "common"
pin "batches"
pin "tranzactions"
pin "payments"
pin "trial_balance"

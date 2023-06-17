class CreateInvoicePaymentBatchJoinTable < ActiveRecord::Migration[7.0]
  def change
    remove_reference :batches, :invoice_batch, foreign_key: { to_table: :batches }, after: :id

    create_table :invoices_payments_batch, id: false do |t|
      t.bigint :invoice_batch_id
      t.bigint :payment_batch_id
      t.index :invoice_batch_id
      t.index :payment_batch_id
    end
  end
end

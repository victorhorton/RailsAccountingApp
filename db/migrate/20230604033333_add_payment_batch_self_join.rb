class AddPaymentBatchSelfJoin < ActiveRecord::Migration[7.0]
  def change
    add_reference :batches, :invoice_batch, foreign_key: { to_table: :batches }, after: :id
  end
end

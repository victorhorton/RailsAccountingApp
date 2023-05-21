class AddDeletedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :batches, :deleted_at, :datetime
    add_index :batches, :deleted_at

    add_column :tranzactions, :deleted_at, :datetime
    add_index :tranzactions, :deleted_at

    add_column :entries, :deleted_at, :datetime
    add_index :entries, :deleted_at
  end
end

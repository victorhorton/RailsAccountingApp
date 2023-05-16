class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.references :tranzaction, index: true
      t.string :entry_type
      t.decimal :amount, precision: 18, scale: 2
      t.integer :designation
      t.timestamps
    end
  end
end

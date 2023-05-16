class CreateTranzactions < ActiveRecord::Migration[7.0]
  def change
    create_table :tranzactions do |t|
      t.references :batch, index: true
      t.date :date
      t.string :reference_number
      t.datetime :completed_at
      t.timestamps
    end
  end
end

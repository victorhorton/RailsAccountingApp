class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :tranzaction
      t.integer :payment_type
      t.string :addressee
      t.string :memo
      t.timestamps
    end
  end
end

class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :code
      t.timestamps
    end

    add_reference :tranzactions, :company, null: false, after: :batch_id

  end
end

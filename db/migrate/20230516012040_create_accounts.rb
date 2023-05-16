class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.integer :account_type
      t.timestamps
    end

    add_reference :entries, :account, null: false, after: :id

  end
end

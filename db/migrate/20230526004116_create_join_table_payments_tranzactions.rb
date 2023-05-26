class CreateJoinTablePaymentsTranzactions < ActiveRecord::Migration[7.0]
  def change
    create_join_table :payments, :tranzactions do |t|
    end
  end
end

class AddContactAssociation < ActiveRecord::Migration[7.0]
  def change
    add_reference :tranzactions, :contact, after: :company_id
  end
end

class AddEntryDescription < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :description, :string, after: :designation
  end
end

class AddPositionToEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :position, :integer, after: :designation
  end
end

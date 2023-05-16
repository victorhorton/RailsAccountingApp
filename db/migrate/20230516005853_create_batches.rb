class CreateBatches < ActiveRecord::Migration[7.0]
  def change
    create_table :batches do |t|
      t.string :name
      t.string :comment
      t.integer :purpose
      t.datetime :posted_at
      t.timestamps
    end
  end
end

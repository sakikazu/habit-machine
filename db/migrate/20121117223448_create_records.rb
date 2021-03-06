class CreateRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :records do |t|
      t.integer :habit_id
      t.date :record_at
      t.float :value
      t.text :memo

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

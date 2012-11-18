class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.integer :habit_id
      t.date :record_at
      t.float :value

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

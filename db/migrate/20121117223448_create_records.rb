class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.integer :habit_id
      t.integer :recorddata_id
      t.integer :value

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

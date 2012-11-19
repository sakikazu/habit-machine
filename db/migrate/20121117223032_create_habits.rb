class CreateHabits < ActiveRecord::Migration
  def change
    create_table :habits do |t|
      t.string :title
      t.integer :user_id
      t.integer :graph_type
      t.integer :data_type
      t.string :data_unit
      t.boolean :reminder
      t.text :goal

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

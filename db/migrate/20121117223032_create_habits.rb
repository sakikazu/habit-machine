class CreateHabits < ActiveRecord::Migration
  def change
    create_table :habits do |t|
      t.integer :status
      t.string :title
      t.integer :user_id
      t.integer :result_type
      t.integer :value_type
      t.string :value_unit
      t.boolean :reminder
      t.text :goal
      t.text :memo

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

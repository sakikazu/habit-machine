class CreateHabitodos < ActiveRecord::Migration[5.2]
  def change
    create_table :habitodos do |t|
      t.string :title
      t.text :body
      t.references :user
      t.string :uuid
      t.integer :order_number, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

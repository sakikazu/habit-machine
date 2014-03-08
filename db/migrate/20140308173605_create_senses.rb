class CreateSenses < ActiveRecord::Migration
  def change
    create_table :senses do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.text :content
      t.date :start_at
      t.date :end_at
      t.boolean :is_active
      t.integer :sort_order

      t.timestamps
    end
  end
end

class CreateDiaries < ActiveRecord::Migration[4.2]
  def change
    create_table :diaries do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.date :record_at
      t.has_attached_file :image

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

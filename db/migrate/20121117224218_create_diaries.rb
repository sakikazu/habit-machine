class CreateDiaries < ActiveRecord::Migration
  def change
    create_table :diaries do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.integer :recorddate_id

      t.datetime :deleted_at

      t.timestamps
    end
  end
end

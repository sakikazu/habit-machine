class CreateDiaryLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :diary_links do |t|
      t.bigint :source_diary_id, null: false
      t.bigint :target_diary_id, null: false

      t.timestamps
    end

    add_index :diary_links, [:source_diary_id, :target_diary_id], unique: true
    add_index :diary_links, :target_diary_id
    add_foreign_key :diary_links, :diaries, column: :source_diary_id
    add_foreign_key :diary_links, :diaries, column: :target_diary_id
  end
end

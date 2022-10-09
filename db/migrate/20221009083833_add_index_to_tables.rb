class AddIndexToTables < ActiveRecord::Migration[5.2]
  def change
    add_index :habits, :user_id
    add_index :records, :habit_id
    add_index :records, :record_at
    add_index :diaries, :user_id
    add_index :diaries, :record_at
    add_index :histories, :target_date
    # NOTE: 外部キー制約されていたカラムはindexが削除できないため、まずは外部キーを削除する
    remove_foreign_key :histories, column: :source_id
    remove_index :histories, :source_id
    add_foreign_key :histories, :children, column: :source_id
    add_index :histories, %i[source_id source_type]
  end
end

class AddSourceToHabit < ActiveRecord::Migration[5.2]
  def change
    rename_column :habits, :user_id, :source_id
    change_column_null :habits, :source_id, false
    add_column :habits, :source_type, :string, null: false, after: :source_id
    add_index :habits, %i[source_id source_type]
    # NOTE: 元のuser_idのindex（rename_columnでsource_idのindexになっていた）
    remove_index :habits, :source_id
  end
end

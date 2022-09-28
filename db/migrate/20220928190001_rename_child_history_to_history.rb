class RenameChildHistoryToHistory < ActiveRecord::Migration[5.2]
  def change
    rename_table :child_histories, :histories
    rename_column :histories, :child_id, :source_id
    change_column_null :histories, :source_id, false
    add_column :histories, :source_type, :string, null: false, after: :source_id
  end
end

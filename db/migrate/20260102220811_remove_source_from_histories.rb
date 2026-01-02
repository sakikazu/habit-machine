class RemoveSourceFromHistories < ActiveRecord::Migration[6.1]
  def change
    # historiesの旧sourceカラムを削除
    if foreign_key_exists?(:histories, :children, column: :source_id)
      remove_foreign_key :histories, :children, column: :source_id
    end

    remove_index :histories, column: %i[source_id source_type] if index_exists?(:histories, %i[source_id source_type])
    remove_column :histories, :source_id, :bigint if column_exists?(:histories, :source_id)
    remove_column :histories, :source_type, :string if column_exists?(:histories, :source_type)
  end
end

# 複数member対応のためhistories.source_*をNULL許容にする
class AllowNullOnHistoriesSource < ActiveRecord::Migration[7.2]
  def up
    remove_foreign_key :histories, column: :source_id
    change_column_null :histories, :source_id, true
    change_column_null :histories, :source_type, true
  end

  def down
    change_column_null :histories, :source_id, false
    change_column_null :histories, :source_type, false
    add_foreign_key :histories, :children, column: :source_id
  end
end

class RenameColumnIsActiveOnSense < ActiveRecord::Migration[4.2]
  def change
    rename_column :senses, :is_active, :is_inactive
    change_column :senses, :sort_order, :integer, default: 1
  end
end

class AddColumnsToDiary < ActiveRecord::Migration[5.2]
  def change
    add_column :diaries, :pinned, :boolean, null: false, default: false
    add_column :diaries, :pin_priority, :integer, null: false, default: 0
  end
end

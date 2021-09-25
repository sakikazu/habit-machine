class AddMainInDayToDiary < ActiveRecord::Migration[5.2]
  def change
    add_column :diaries, :main_in_day, :boolean, null: false, default: false
  end
end

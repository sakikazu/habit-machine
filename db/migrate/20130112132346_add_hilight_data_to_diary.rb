class AddHilightDataToDiary < ActiveRecord::Migration
  def change
    add_column :diaries, :is_hilight, :boolean
    add_column :diaries, :is_about_date, :boolean
    add_column :diaries, :is_secret, :boolean
  end
end

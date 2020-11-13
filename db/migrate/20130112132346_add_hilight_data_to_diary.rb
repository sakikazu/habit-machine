class AddHilightDataToDiary < ActiveRecord::Migration[4.2]
  def change
    add_column :diaries, :is_hilight, :boolean
    add_column :diaries, :is_about_date, :boolean
    add_column :diaries, :is_secret, :boolean
  end
end

class AddColorAndPinnedToTag < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :color, :string
    add_column :tags, :pinned, :boolean, default: false
  end
end

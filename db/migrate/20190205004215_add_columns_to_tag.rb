class AddColumnsToTag < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :user_id, :integer
    add_column :tags, :last_used_at, :datetime
    add_column :tags, :description, :text
  end
end

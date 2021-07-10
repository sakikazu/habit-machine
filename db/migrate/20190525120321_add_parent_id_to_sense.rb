class AddParentIdToSense < ActiveRecord::Migration[5.2]
  def change
    add_column :senses, :parent_id, :integer
  end
end

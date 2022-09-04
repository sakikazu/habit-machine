class AddFaimlyIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :family, foreign_key: true
    add_reference :children, :family, foreign_key: true
  end
end

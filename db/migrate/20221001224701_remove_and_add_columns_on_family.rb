class RemoveAndAddColumnsOnFamily < ActiveRecord::Migration[5.2]
  def change
    remove_column :families, :has_others, :boolean, default: false, null: false
    add_column :families, :enabled, :boolean, default: false, null: false
  end
end

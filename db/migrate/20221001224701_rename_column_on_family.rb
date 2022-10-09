class RenameColumnOnFamily < ActiveRecord::Migration[5.2]
  def change
    rename_column :families, :has_others, :enabled
  end
end

class AddHasOthersToFamily < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :has_others, :boolean, default: false, null: false
  end
end

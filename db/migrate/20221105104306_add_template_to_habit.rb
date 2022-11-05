class AddTemplateToHabit < ActiveRecord::Migration[6.0]
  def change
    add_column :habits, :template, :text
  end
end

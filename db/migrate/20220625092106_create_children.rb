class CreateChildren < ActiveRecord::Migration[5.2]
  def change
    create_table :children do |t|
      t.string :name
      t.date :birthday
      t.integer :gender

      t.timestamps
    end
  end
end

class CreateCategoryDiaries < ActiveRecord::Migration[6.1]
  def change
    create_table :category_diaries do |t|
      t.references :category, null: false, foreign_key: true
      t.references :diary, null: false, foreign_key: true

      t.timestamps
    end
  end
end

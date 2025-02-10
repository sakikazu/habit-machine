class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :parent, foreign_key: { to_table: :categories }, index: true, comment: '親カテゴリ'
      t.references :source, polymorphic: true, index: true, null: false, comment: 'カテゴリの所有者（ポリモーフィック）'

      t.timestamps
    end
  end
end

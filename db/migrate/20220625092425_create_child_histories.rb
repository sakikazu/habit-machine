class CreateChildHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :child_histories do |t|
      t.references :child, foreign_key: true
      t.integer :author_id, index: true
      t.string :title
      t.text :content
      t.date :target_date
      t.boolean :about_date
      t.has_attached_file :image
      t.boolean :as_profile_image
      t.json :data

      t.timestamps
    end
    add_foreign_key :child_histories, :users, column: :author_id
  end
end

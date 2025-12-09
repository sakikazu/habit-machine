class CreateFavorites < ActiveRecord::Migration[6.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :favoritable, null: false, polymorphic: true

      t.timestamps
    end

    add_index :favorites, [:user_id, :favoritable_type, :favoritable_id],
              unique: true,
              name: 'idx_favorites_on_user_and_favoritable'
  end
end

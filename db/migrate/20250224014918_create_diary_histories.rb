class CreateDiaryHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :diary_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :diary, null: false, foreign_key: true
      t.json :changed_prev_attrs, comment: '変更されたカラムの変更前の値'

      t.timestamps
    end
  end
end

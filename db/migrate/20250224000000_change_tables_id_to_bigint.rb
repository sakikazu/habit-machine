class ChangeTablesIdToBigint < ActiveRecord::Migration[6.1]
  def up
    # 外部キーが存在していると、外部キー制約の対象となっているカラムの型の変更がエラーになるので、一旦削除
    remove_foreign_key :histories, :users, column: :author_id
    change_column :histories, :author_id, :bigint
    change_column :users, :id, :bigint, auto_increment: true
    change_column :habits, :id, :bigint, auto_increment: true
    change_column :records, :id, :bigint, auto_increment: true
    change_column :tags, :id, :bigint, auto_increment: true
    change_column :taggings, :id, :bigint, auto_increment: true
    add_foreign_key :histories, :users, column: :author_id
  end

  def down
    remove_foreign_key :histories, :users, column: :author_id
    change_column :histories, :author_id, :int
    change_column :users, :id, :int, auto_increment: true
    change_column :habits, :id, :int, auto_increment: true
    change_column :records, :id, :int, auto_increment: true
    change_column :tags, :id, :int, auto_increment: true
    change_column :taggings, :id, :int, auto_increment: true
    add_foreign_key :histories, :users, column: :author_id
  end
end

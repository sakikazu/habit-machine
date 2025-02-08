class ChangeDiariesIdToBigint < ActiveRecord::Migration[6.1]
  def up
    change_column :diaries, :id, :bigint, auto_increment: true
    change_column_comment :diaries, :image_file_name, 'AS移行により不要。削除する'
    change_column_comment :diaries, :image_content_type, 'AS移行により不要。削除する'
    change_column_comment :diaries, :image_file_size, 'AS移行により不要。削除する'
    change_column_comment :diaries, :image_updated_at, 'AS移行により不要。削除する'
  end

  def down
    change_column :diaries, :id, :int, auto_increment: true
  end
end

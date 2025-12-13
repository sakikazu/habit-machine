class RemovePaperclipColumnsFromDiariesAndHistories < ActiveRecord::Migration[6.1]
  def change
    remove_column :diaries, :image_file_name, :string, comment: 'AS移行により不要。削除する'
    remove_column :diaries, :image_content_type, :string, comment: 'AS移行により不要。削除する'
    remove_column :diaries, :image_file_size, :integer, comment: 'AS移行により不要。削除する'
    remove_column :diaries, :image_updated_at, :datetime, comment: 'AS移行により不要。削除する'

    remove_column :histories, :image_file_name, :string
    remove_column :histories, :image_content_type, :string
    remove_column :histories, :image_file_size, :bigint
    remove_column :histories, :image_updated_at, :datetime
  end
end

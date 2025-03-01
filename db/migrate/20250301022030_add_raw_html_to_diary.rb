class AddRawHtmlToDiary < ActiveRecord::Migration[6.1]
  def change
    add_column :diaries, :content_is_html, :boolean, default: false, null: false, comment: 'contentがhtmlであるか'
  end
end

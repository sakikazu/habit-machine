json.favorites do
  json.array! @favorites do |fav|
    json.extract! fav, :id, :type, :title, :date, :path, :member, :favorited_at, :edit_path, :content
    json.content_html fav[:content_html]
  end
end

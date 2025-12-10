json.favorites do
  json.array! @favorites do |fav|
    json.extract! fav, :id, :type, :title, :date, :path, :member, :favorited_at, :edit_path, :content
  end
end

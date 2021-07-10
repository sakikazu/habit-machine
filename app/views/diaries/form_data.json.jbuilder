json.diary do
  json.extract! @diary, :id, :title, :content, :is_hilight, :is_secret, :is_about_date
  json.image_path @diary.image(:small) if @diary.image.present?
  json.tag_list @diary.tag_list.join(', ')
end

json.pinned_tags do
  json.array! @pinned_tags do |tag|
    json.name tag.name
    json.color_style tag.color_style
  end
end

json.latest_tags do
  json.array! @latest_tags do |tag|
    json.name tag.name
    json.color_style tag.color_style
  end
end

json.tagnames @tagnames

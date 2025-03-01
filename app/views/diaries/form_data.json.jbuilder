json.diary do
  json.extract! @diary, :id, :title, :content, :main_in_day, :is_hilight, :is_about_date, :pinned, :pin_priority, :content_is_html
  json.image_path url_for(@diary.eyecatch_image_small) if @diary.eyecatch_image.attached?
  json.images do
    json.array! @diary.images do |image|
      json.id image.id
      json.url url_for(image.variant(Diary::SUB_IMAGE_VARIANT_HASH))
      json.filename image.filename
    end
  end
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

json.diaries do
  json.array! @diaries do |diary|
    json.extract! diary, :id, :title, :content, :record_at, :pin_priority, :pinned
  end
end


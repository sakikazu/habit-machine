json.habit_records do
  json.array! @habits do |habit|
    json.habit do
      json.id habit.id
      json.title habit.title
      json.value_type habit.value_type
      json.value_unit habit.value_unit
      json.value_collection habit.value_select_options
    end

    json.partial! 'records/show', record: habit.record_at_date
  end
end

json.diaries do
  json.array! @diaries do |diary|
    json.partial! 'diaries/show', diary: diary
  end
end

json.diary_links_list diary_links_list(@diaries)

json.everyday_diaries do
  json.array! @everyday_diaries do |diary|
    json.extract! diary, :id, :title, :content
  end
end

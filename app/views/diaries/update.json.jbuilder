json.diary do
  json.partial! 'show', diary: @diary
end
json.changed_record_at @changed_record_at

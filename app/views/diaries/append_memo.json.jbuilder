json.diary do
  json.partial! 'show', diary: @diary
end
json.after_created_by_memo @after_created_by_memo

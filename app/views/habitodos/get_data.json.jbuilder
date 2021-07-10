json.habitodos do
  json.array! @habitodos do |habitodo|
    json.partial! 'show', habitodo: habitodo
  end
end

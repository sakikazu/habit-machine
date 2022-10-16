json.extract! todo, :id, :title, :content, :priority, :sort_order, :created_at, :updated_at
json.url todo_url(todo, format: :json)

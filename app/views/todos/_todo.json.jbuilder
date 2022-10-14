json.extract! todo, :id, :title, :content, :state, :created_at, :updated_at
json.url todo_url(todo, format: :json)

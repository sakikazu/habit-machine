json.extract! todo_project, :id, :title, :content, :source_id, :source_type, :created_at, :updated_at
json.url todo_project_url(todo_project, format: :json)

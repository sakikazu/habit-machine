json.id category[:id]
json.name category[:name]
json.shared category[:shared]
json.children do
  json.array! category[:children] do |child|
    json.partial! 'categories/category_node', category: child
  end
end

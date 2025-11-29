json.categories do
  json.array! @categories do |category|
    json.partial! 'categories/category_node', category: category
  end
end

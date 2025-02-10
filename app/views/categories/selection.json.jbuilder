json.categories do
  json.array! @categories.select { |cate| cate.parent_id.nil? } do |category|
    json.id category.id
    json.name category.name
    json.shared category.shared?
    json.children do
      json.array! category.children do |child|
        json.id child.id
        json.name child.name
        json.shared child.shared?
        json.children do
          json.array! child.children do |granchild|
            json.id granchild.id
            json.name granchild.name
            json.shared granchild.shared?
          end
        end
      end
    end
  end
end

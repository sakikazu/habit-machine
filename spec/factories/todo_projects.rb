# == Schema Information
#
# Table name: todo_projects
#
#  id          :bigint           not null, primary key
#  content     :text(65535)
#  source_type :string(255)      not null
#  title       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          not null
#
FactoryBot.define do
  factory :todo_project do
    title { "MyString" }
    content { "MyText" }
    source_id { 1 }
    source_type { "MyString" }
  end
end

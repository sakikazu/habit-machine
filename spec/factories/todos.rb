# == Schema Information
#
# Table name: todos
#
#  id         :bigint           not null, primary key
#  content    :text(65535)
#  state      :integer
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :todo do
    title { "MyString" }
    content { "MyText" }
    state { 1 }
  end
end

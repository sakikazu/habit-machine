# == Schema Information
#
# Table name: senses
#
#  id          :integer          not null, primary key
#  content     :text(65535)
#  description :text(65535)
#  end_at      :date
#  is_inactive :boolean
#  sort_order  :integer          default(1)
#  start_at    :date
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  parent_id   :integer
#  user_id     :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :sense do
    user_id { 1 }
    title { "MyString" }
    description { "MyText" }
    content { "MyText" }
    start_at { "2014-03-09" }
    end_at { "2014-03-09" }
    is_active { false }
    sort_order { 1 }
  end
end

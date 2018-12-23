# == Schema Information
#
# Table name: senses
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  title       :string(255)
#  description :text(65535)
#  content     :text(65535)
#  start_at    :date
#  end_at      :date
#  is_inactive :boolean
#  sort_order  :integer          default(1)
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sense do
    user_id 1
    title "MyString"
    description "MyText"
    content "MyText"
    start_at "2014-03-09"
    end_at "2014-03-09"
    is_active false
    sort_order 1
  end
end

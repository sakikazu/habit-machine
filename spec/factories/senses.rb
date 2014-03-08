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

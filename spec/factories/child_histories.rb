FactoryBot.define do
  factory :child_history do
    child
    title { "MyString" }
    content { "MyText" }
    target_date { "2022-09-28" }
    data { {"height"=>"46", "weight"=>"2.4"} }
  end
end

FactoryBot.define do
  factory :user do
    family
    familyname { '田中' }
    givenname { 'はじめ' }
    email { 'example@com' }
    password { 'test1234' }
  end
end

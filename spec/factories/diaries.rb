FactoryBot.define do
  factory :diary do
    user
    record_at { Date.today }
    sequence(:title) { |n| "happy day #{n}" }
    content { 'I hope it happy day' }
  end
end

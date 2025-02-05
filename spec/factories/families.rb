# == Schema Information
#
# Table name: families
#
#  id         :bigint           not null, primary key
#  enabled    :boolean          default(FALSE), not null
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :family do
    name { '田中' }
    enabled { true }
  end
end

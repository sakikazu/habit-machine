# == Schema Information
#
# Table name: categories
#
#  id                                              :bigint           not null, primary key
#  name                                            :string(255)      not null
#  source_type                                     :string(255)      not null
#  created_at                                      :datetime         not null
#  updated_at                                      :datetime         not null
#  parent_id(親カテゴリ)                           :bigint
#  source_id(カテゴリの所有者（ポリモーフィック）) :bigint           not null
#
# Indexes
#
#  index_categories_on_parent_id                  (parent_id)
#  index_categories_on_source_type_and_source_id  (source_type,source_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => categories.id)
#
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "カテゴリ#{n}" }
    association :source, factory: :user
  end
end

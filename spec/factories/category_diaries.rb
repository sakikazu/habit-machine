# == Schema Information
#
# Table name: category_diaries
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#  diary_id    :bigint           not null
#
# Indexes
#
#  index_category_diaries_on_category_id  (category_id)
#  index_category_diaries_on_diary_id     (diary_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (diary_id => diaries.id)
#
FactoryBot.define do
  factory :category_diary do
    category { nil }
    diary { nil }
  end
end

# == Schema Information
#
# Table name: habits
#
#  id          :bigint           not null, primary key
#  deleted_at  :datetime
#  goal        :text(16777215)
#  memo        :text(16777215)
#  reminder    :boolean
#  result_type :integer
#  source_type :string(255)      not null
#  status      :integer
#  template    :text(16777215)
#  title       :string(255)
#  value_type  :integer
#  value_unit  :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          not null
#
# Indexes
#
#  index_habits_on_source_id_and_source_type  (source_id,source_type)
#
FactoryBot.define do
  factory :habit do
    association :source, factory: :user
    sequence(:title) { |n| "習慣#{n}" }
    status { :enabled }
    result_type { :table }
    value_type { :integer }
  end
end

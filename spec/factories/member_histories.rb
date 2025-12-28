# == Schema Information
#
# Table name: member_histories
#
#  id          :bigint           not null, primary key
#  member_type :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  history_id  :bigint           not null
#  member_id   :bigint           not null
#
# Indexes
#
#  index_member_histories_on_history_and_member  (history_id,member_type,member_id) UNIQUE
#  index_member_histories_on_history_id          (history_id)
#  index_member_histories_on_member              (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (history_id => histories.id)
#
FactoryBot.define do
  factory :member_history do
    history
    association :member, factory: :user
  end
end

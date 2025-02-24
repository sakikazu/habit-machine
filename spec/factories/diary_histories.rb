# == Schema Information
#
# Table name: diary_histories
#
#  id                                               :bigint           not null, primary key
#  changed_prev_attrs(変更されたカラムの変更前の値) :json
#  created_at                                       :datetime         not null
#  updated_at                                       :datetime         not null
#  diary_id                                         :bigint           not null
#  user_id                                          :bigint           not null
#
# Indexes
#
#  index_diary_histories_on_diary_id  (diary_id)
#  index_diary_histories_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (diary_id => diaries.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :diary_history do
    diary { nil }
    attrs { "" }
  end
end

# == Schema Information
#
# Table name: diaries
#
#  id                                             :bigint           not null, primary key
#  content                                        :text(16777215)
#  deleted_at                                     :datetime
#  image_content_type(AS移行により不要。削除する) :string(255)
#  image_file_name(AS移行により不要。削除する)    :string(255)
#  image_file_size(AS移行により不要。削除する)    :integer
#  image_updated_at(AS移行により不要。削除する)   :datetime
#  is_about_date                                  :boolean
#  is_hilight                                     :boolean
#  is_secret                                      :boolean
#  main_in_day                                    :boolean          default(FALSE), not null
#  pin_priority                                   :integer          default(0), not null
#  pinned                                         :boolean          default(FALSE), not null
#  record_at                                      :date
#  title                                          :string(255)
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  user_id                                        :integer
#
# Indexes
#
#  index_diaries_on_record_at  (record_at)
#  index_diaries_on_user_id    (user_id)
#
FactoryBot.define do
  factory :diary do
    user
    record_at { Date.today }
    sequence(:title) { |n| "happy day #{n}" }
    content { 'I hope it happy day' }
  end
end

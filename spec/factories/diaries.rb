# == Schema Information
#
# Table name: diaries
#
#  id                 :integer          not null, primary key
#  content            :text(16777215)
#  deleted_at         :datetime
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  is_about_date      :boolean
#  is_hilight         :boolean
#  is_secret          :boolean
#  main_in_day        :boolean          default(FALSE), not null
#  pin_priority       :integer          default(0), not null
#  pinned             :boolean          default(FALSE), not null
#  record_at          :date
#  title              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
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

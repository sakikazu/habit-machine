# == Schema Information
#
# Table name: histories
#
#  id                 :bigint           not null, primary key
#  about_date         :boolean
#  as_profile_image   :boolean
#  content            :text(16777215)
#  data               :json
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :bigint
#  image_updated_at   :datetime
#  source_type        :string(255)      not null
#  target_date        :date
#  title              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint
#  family_id          :bigint
#  source_id          :bigint           not null
#
# Indexes
#
#  index_histories_on_author_id                  (author_id)
#  index_histories_on_family_id                  (family_id)
#  index_histories_on_source_id_and_source_type  (source_id,source_type)
#  index_histories_on_target_date                (target_date)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (family_id => families.id)
#  fk_rails_...  (source_id => children.id)
#
FactoryBot.define do
  factory :history do
    source { build(:child) }
    title { "MyString" }
    content { "MyText" }
    target_date { "2022-09-28" }
    data { {"height"=>"46", "weight"=>"2.4"} }
  end
end

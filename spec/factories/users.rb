# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  auth_token             :string(255)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  deleted_at             :datetime
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  familyname             :string(255)
#  givenname              :string(255)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  nickname               :string(255)
#  preferences            :json
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  family_id              :bigint
#
# Indexes
#
#  index_users_on_auth_token            (auth_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_family_id             (family_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
FactoryBot.define do
  factory :user do
    family
    familyname { '田中' }
    givenname { 'はじめ' }
    email { 'example@com' }
    password { 'test1234' }
  end
end

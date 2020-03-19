# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  familyname             :string(255)
#  givenname              :string(255)
#  deleted_at             :datetime
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  authentication_token   :string(255)
#

class User < ApplicationRecord
  acts_as_paranoid

  # API認証時のtokenを用意するため
  # NOTE: 通常はデータ作成時に自動で指定カラムにトークンが作られて保存されるが、regenerate_auth_tokenを使えば後で作成することも可能
  has_secure_token :auth_token

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :habits
  has_many :diaries
  has_many :senses
  has_many :mytags, class_name: 'CustomTag'
  has_many :habitodos

  def self.find_or_create(data)
    user = self.find_by_email(data[:email])
    if user.blank?
      user = self.create!(data)
    end
    return user
  end

  def fullname
    "#{self.familyname}#{self.givenname}"
  end
end

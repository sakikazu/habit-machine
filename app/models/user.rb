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

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :habits
  has_many :diaries
  has_many :senses
  has_many :mytags, class_name: 'CustomTag'

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

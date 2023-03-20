# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
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
#  created_at             :datetime
#  updated_at             :datetime
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

  belongs_to :family
  has_many :habits, as: :source
  has_many :diaries
  has_many :senses
  has_many :mytags, class_name: 'CustomTag'
  has_many :habitodos
  has_many :histories, as: :source
  has_many :todos, as: :source
  has_many :todo_projects, as: :source

  def self.find_or_create(data)
    user = self.find_by_email(data[:email])
    if user.blank?
      user = self.create!(data)
    end
    return user
  end

  # NOTE: has_many の whereオプションでやれそうだが、めんどそう
  def habits_including_familys
    return habits if family.blank?

    habits + family.habits
  end

  def dispname
    nickname || fullname
  end

  def fullname
    "#{self.familyname}#{self.givenname}"
  end
end

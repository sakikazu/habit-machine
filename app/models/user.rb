# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :familyname, :givenname
  # attr_accessible :title, :body

  has_many :diaries


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

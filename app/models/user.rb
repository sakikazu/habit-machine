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


  def self.find_or_create(email, password, familyname, givenname)
    user = self.find_by_email(email)
    if user.blank?
      user = self.create!(email: email, password: password, password_confirmation: password, familyname: familyname, givenname: givenname)
    end
    return user
  end

end

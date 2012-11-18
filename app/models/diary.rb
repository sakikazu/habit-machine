# -*- coding: utf-8 -*-
class Diary < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :content, :record_at, :title, :user_id

  belongs_to :user
end

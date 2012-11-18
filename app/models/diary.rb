# -*- coding: utf-8 -*-
class Diary < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :content, :recorddate_id, :title, :user_id
end

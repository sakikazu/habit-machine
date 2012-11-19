# -*- coding: utf-8 -*-
class Habit < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :data_type, :data_unit, :graph_type, :reminder, :title, :user_id, :goal

  belongs_to :user
  has_many :records
end

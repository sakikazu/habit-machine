# -*- coding: utf-8 -*-
class Habit < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :data_type, :data_unit, :graph_type, :reminder, :title, :user_id, :goal

  belongs_to :user
  has_many :records

  validates_presence_of :title, :graph_type, :data_type

  VALUE_TYPE = [["整数", 1], ["小数込", 2], ["○/☓/△", 3]]
  GRAPH_TYPE = [["折れ線グラフ", 1], ["棒グラフ", 2], ["円グラフ", 3]]

  def data_name
    Hash[*VALUE_TYPE.flatten.reverse][self.data_type]
  end

  def graph_name
    Hash[*GRAPH_TYPE.flatten.reverse][self.graph_type]
  end

end

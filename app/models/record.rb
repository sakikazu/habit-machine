# -*- coding: utf-8 -*-
class Record < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :habit_id, :record_at, :value, :memo

  belongs_to :habit

  # best_in_placeで扱うcollectionの形が、Railsの普通のselectとは表示値と値が逆だった
  SYMBOLIC_VALUE = [[nil, ""], [1, "○"], [2, "☓"], [3, "△"]]


  def self.find_or_create(habit_id, record_at)
    record = self.where(habit_id: habit_id, record_at: record_at).first
    record = self.create(habit_id: habit_id, record_at: record_at) if record.blank?
    return record
  end

  def symbolic_name
    Hash[*SYMBOLIC_VALUE.flatten][self.value.to_i]
  end

  def formatted_value
    case self.habit.data_type
    when 1
      self.value.to_i
    when 2
      # 元々float型なのでそのままでOK
      self.value
    when 3
      self.symbolic_name
    end
  end

end

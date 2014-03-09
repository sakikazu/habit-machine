# -*- coding: utf-8 -*-
class Record < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :habit

  # best_in_placeで扱うcollectionの形が、Railsの普通のselectとは表示値と値が逆だった
  SYMBOLIC_VALUE = [[nil, ""], [1.0, "1"], [2.0, "2"], [3.0, "3"], [4.0, "4"], [5.0, "5"]]

  def self.find_or_new(habit_id, record_at)
    record = self.where(habit_id: habit_id, record_at: record_at).first
    record = self.new(habit_id: habit_id, record_at: record_at) if record.blank?
    return record
  end

  # def self.find_or_create(habit_id, record_at)
    # record = self.where(habit_id: habit_id, record_at: record_at).first
    # record = self.create(habit_id: habit_id, record_at: record_at) if record.blank?
    # return record
  # end

  def symbolic_name
    Hash[*SYMBOLIC_VALUE.flatten][self.value.to_i]
  end

  def formatted_value
    case self.habit.value_type
    when 1
      self.symbolic_name
    when 2
      self.value.to_i
    when 3
      # 元々float型なのでそのままでOK
      self.value
    end
  end

end

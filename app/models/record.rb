# -*- coding: utf-8 -*-
class Record < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :habit_id, :record_at, :value, :memo

  belongs_to :habit

  def self.find_or_create(habit_id, record_at)
    record = self.where(habit_id: habit_id, record_at: record_at).first
    record = self.create(habit_id: habit_id, record_at: record_at) if record.blank?
    return record
  end

end

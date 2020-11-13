# == Schema Information
#
# Table name: records
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  memo       :text(65535)
#  record_at  :date
#  value      :float(24)
#  created_at :datetime
#  updated_at :datetime
#  habit_id   :integer
#

class Record < ApplicationRecord
  acts_as_paranoid

  belongs_to :habit

  # NOTE: valueはFloat型のためフォームには小数点を含む値がセットされており、optionsの値も合わせておかないと正しく表示されない
  # NOTE: 空の選択肢の値がnilだと0がポストされてしまうので、空文字列にする必要がある
  SYMBOLIC_VALUE = [['', ''], [1.0, "1"], [2.0, "2"], [3.0, "3"], [4.0, "4"], [5.0, "5"]]

  scope :user_by, lambda { |user| where(habit: user.habits) }
  scope :has_data, lambda { where("value is not NULL OR memo is not NULL") }
  scope :newer, lambda { order("record_at DESC") }

  # def self.find_or_new(habit_id, record_at)
    # record = self.where(habit_id: habit_id, record_at: record_at).first
    # record = self.new(habit_id: habit_id, record_at: record_at) if record.blank?
    # return record
  # end

  # def self.find_or_create(habit_id, record_at)
    # record = self.where(habit_id: habit_id, record_at: record_at).first
    # record = self.create(habit_id: habit_id, record_at: record_at) if record.blank?
    # return record
  # end
end

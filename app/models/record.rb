# == Schema Information
#
# Table name: records
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  memo       :text(65535)
#  record_at  :date
#  value      :float(24)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  habit_id   :integer
#

class Record < ApplicationRecord
  acts_as_paranoid

  belongs_to :habit

  scope :user_by, lambda { |user| where(habit: user.habits) }
  scope :has_data, lambda { where("value is not NULL OR memo is not NULL") }
  scope :newer, lambda { order("record_at DESC") }

  validates_presence_of :habit_id, :record_at
  validate :value_or_memo

  def displaying_value
    return "" if value.blank?
    habit.value_type_integer? ? value.to_i : value
  end

  def search_result_items
    {
      id: id,
      title: "#{record_at.to_s} > #{habit.title}",
      body: memo,
      target_text: memo,
      show_path: Rails.application.routes.url_helpers.day_path(record_at),
    }
  end

  private

  def value_or_memo
    errors.add(:base, '値かメモのいずれかでも入力してください') if value.blank? && memo.blank?
  end
end

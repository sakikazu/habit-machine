# == Schema Information
#
# Table name: senses
#
#  id          :integer          not null, primary key
#  content     :text(16777215)
#  description :text(16777215)
#  end_at      :date
#  is_inactive :boolean
#  sort_order  :integer          default(1)
#  start_at    :date
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  parent_id   :integer
#  user_id     :integer
#

class Sense < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Sense", foreign_key: "parent_id", optional: true

  validates_presence_of :title

  scope :index_order, -> { order("sort_order ASC, start_at DESC") }
  scope :options_order, -> { order("title ASC") }
  scope :active, -> { where(is_inactive: false) }
  scope :inactive, -> { where(is_inactive: true) }
  scope :current, -> { where("start_at <= :day AND end_at >= :day", day: Date.today) }
  scope :nocurrent, -> { where("start_at > :day OR end_at < :day", day: Date.today) }

  scope :find_by_word, lambda { |word| where('title like :q OR description like :q OR content like :q', :q => "%#{word}%") }
end

# == Schema Information
#
# Table name: senses
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  title       :string(255)
#  description :text(65535)
#  content     :text(65535)
#  start_at    :date
#  end_at      :date
#  is_inactive :boolean
#  sort_order  :integer          default(1)
#  created_at  :datetime
#  updated_at  :datetime
#

class Sense < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Sense", foreign_key: "parent_id", optional: true

  validates_presence_of :title

  scope :index_order, -> { order("sort_order ASC, start_at DESC") }
  scope :active, -> { where(is_inactive: false) }
  scope :inactive, -> { where(is_inactive: true) }
  scope :current, -> { where("start_at <= :day AND end_at >= :day", day: Date.today) }
  scope :nocurrent, -> { where("start_at > :day OR end_at < :day", day: Date.today) }
end

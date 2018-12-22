class Diary < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  content_name = "diary"
  has_attached_file :image,
    :styles => {
      :small => "80x80>",
      :large => "1600x1600>"
    },
    :convert_options => {
      :small => ['-quality 70', '-strip'],
    },
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  validates_attachment :image,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  attr_accessor :search_word

  belongs_to :user

  scope :by_user, lambda {|user| where(user_id: user.id)}
  scope :hilight, lambda {where(is_hilight: true)}

  def title_mod
    self.title.presence || "(タイトルなし)"
  end

  def self.all_years
    oldest_diary = Diary.order("record_at ASC").first
    if oldest_diary.record_at.year == Date.today.year
      return [Date.today.year]
    else
      return oldest_diary.record_at.year..Date.today.year
    end
  end

  def self.group_by_record_at(current_user, date_term)
    diaries = self.by_user(current_user).where(record_at: date_term).order("id ASC")
    diaries.group_by{|d| d.record_at}
  end
end

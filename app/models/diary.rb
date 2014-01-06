# -*- coding: utf-8 -*-
class Diary < ActiveRecord::Base
  acts_as_paranoid
  acts_as_taggable

  content_name = "diary"
  has_attached_file :image,
    :styles => {
      :small => "80x80>",
      :large => "800x800>"
    },
    :convert_options => {
      :small => ['-quality 70', '-strip'],
    },
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  # todo 何のためだっけ？
  attr_accessible :content, :record_at, :title, :tag_list, :image, :is_hilight, :is_about_date, :is_secret, :search_word

  attr_accessor :search_word

  belongs_to :user

  validates_presence_of :content

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
end

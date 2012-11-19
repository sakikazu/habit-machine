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

  attr_accessible :content, :record_at, :title, :user_id, :tag_list, :image

  belongs_to :user

  validates_presence_of :content

  def tag_formatted
    return "" if self.tag_list.blank?
    return self.tag_counts.map{|t| "[#{t}]"}.join(" ")
  end

  def dispinfo
    return self.tag_formatted if self.tag_list.present?
    return self.title if self.title.present?
    return self.content.truncate(20, omission: "...")
  end

end

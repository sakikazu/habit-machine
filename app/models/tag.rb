# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  taggings_count :integer          default(0)
#

class Tag < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
end

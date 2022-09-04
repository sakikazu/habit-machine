# == Schema Information
#
# Table name: families
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Family < ApplicationRecord
  has_many :users
  has_many :children
  has_many :child_histories, through: :children
end

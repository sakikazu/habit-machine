# == Schema Information
#
# Table name: families
#
#  id         :bigint           not null, primary key
#  enabled    :boolean          default(FALSE), not null
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Family < ApplicationRecord
  has_many :users
  has_many :children
  has_many :histories, as: :source

  def name_with_suffix
    "#{name}家"
  end
end

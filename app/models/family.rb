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
  # TODO: enabled は、「家族」メニューを非表示にしたい時が出てきた時に利用する
  has_many :users
  has_many :children
  has_many :histories, as: :source
  has_many :all_histories, class_name: 'History'
  has_many :habits, as: :source

  def name_with_suffix
    "#{name}家"
  end

  def dispname
    name_with_suffix
  end
end

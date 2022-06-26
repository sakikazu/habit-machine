# == Schema Information
#
# Table name: children
#
#  id         :bigint           not null, primary key
#  birthday   :date
#  gender     :integer
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Child < ApplicationRecord
  has_many :child_histories

  def profile_image
    child_histories.where(as_profile_image: true).order(target_date: :desc).first&.image
  end

  def relative_age(base_date)
    return "-歳-ヶ月" if base_date < birthday

    diff = (base_date - birthday).to_i
    year = diff / 365
    # TODO: 適当なので直す
    month = (diff - year * 365) / 30
    "#{year}歳#{month}ヶ月"
  end
end

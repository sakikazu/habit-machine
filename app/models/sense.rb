class Sense < ApplicationRecord
  scope :by_user, lambda {|user| where(user_id: user.id)}
end

class Sense < ActiveRecord::Base
  scope :by_user, lambda {|user| where(user_id: user.id)}
end

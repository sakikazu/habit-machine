class Habitodo < ApplicationRecord
  acts_as_paranoid
  belongs_to :user

  def generate_uuid
    require 'securerandom'
    self.uuid = SecureRandom.uuid
  end
end

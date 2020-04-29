class Habitodo < ApplicationRecord
  acts_as_paranoid
  belongs_to :user

  scope :find_by_word, lambda { |word| where('title like :q OR body like :q', :q => "%#{word}%") }

  def generate_uuid
    require 'securerandom'
    self.uuid = SecureRandom.uuid
  end
end

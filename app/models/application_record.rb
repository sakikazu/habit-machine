class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  validates_with FourByteCharacterValidator
end

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
require 'rails_helper'

RSpec.describe Child, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

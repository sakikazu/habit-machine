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
require 'rails_helper'

RSpec.describe Family, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

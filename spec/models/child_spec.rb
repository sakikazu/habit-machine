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
#  family_id  :bigint
#
# Indexes
#
#  index_children_on_family_id  (family_id)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
require 'rails_helper'

RSpec.describe Child, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

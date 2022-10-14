# == Schema Information
#
# Table name: todos
#
#  id         :bigint           not null, primary key
#  content    :text(65535)
#  state      :integer
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Todo, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

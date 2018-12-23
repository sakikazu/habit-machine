# == Schema Information
#
# Table name: habits
#
#  id          :integer          not null, primary key
#  status      :integer
#  title       :string(255)
#  user_id     :integer
#  result_type :integer
#  value_type  :integer
#  value_unit  :string(255)
#  reminder    :boolean
#  goal        :text(65535)
#  memo        :text(65535)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Habit do
  pending "add some examples to (or delete) #{__FILE__}"
end

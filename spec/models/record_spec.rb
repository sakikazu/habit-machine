# == Schema Information
#
# Table name: records
#
#  id         :integer          not null, primary key
#  habit_id   :integer
#  record_at  :date
#  value      :float(24)
#  memo       :text(65535)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Record do
  pending "add some examples to (or delete) #{__FILE__}"
end

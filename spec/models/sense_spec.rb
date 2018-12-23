# == Schema Information
#
# Table name: senses
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  title       :string(255)
#  description :text(65535)
#  content     :text(65535)
#  start_at    :date
#  end_at      :date
#  is_inactive :boolean
#  sort_order  :integer          default(1)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Sense do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: senses
#
#  id          :integer          not null, primary key
#  content     :text(65535)
#  description :text(65535)
#  end_at      :date
#  is_inactive :boolean
#  sort_order  :integer          default(1)
#  start_at    :date
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  parent_id   :integer
#  user_id     :integer
#

require 'spec_helper'

describe Sense do
  pending "add some examples to (or delete) #{__FILE__}"
end

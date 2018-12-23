# == Schema Information
#
# Table name: diaries
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  content            :text(65535)
#  user_id            :integer
#  record_at          :date
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_hilight         :boolean
#  is_about_date      :boolean
#  is_secret          :boolean
#

require 'spec_helper'

describe Diary do
  pending "add some examples to (or delete) #{__FILE__}"
end

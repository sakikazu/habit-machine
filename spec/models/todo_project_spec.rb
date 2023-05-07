# == Schema Information
#
# Table name: todo_projects
#
#  id          :bigint           not null, primary key
#  content     :text(16777215)
#  source_type :string(255)      not null
#  title       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          not null
#
# Indexes
#
#  index_todo_projects_on_source_id_and_source_type  (source_id,source_type)
#
require 'rails_helper'

RSpec.describe TodoProject, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

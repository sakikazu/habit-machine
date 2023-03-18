# == Schema Information
#
# Table name: todos
#
#  id          :bigint           not null, primary key
#  content     :text(16777215)
#  done_at     :datetime
#  priority    :integer          default(0), not null
#  sort_order  :integer          default(0), not null
#  source_type :string(255)      not null
#  title       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :integer
#  source_id   :integer          not null
#
# Indexes
#
#  index_todos_on_source_id_and_source_type  (source_id,source_type)
#
class Todo < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :project, class_name: 'TodoProject', foreign_key: :project_id, optional: true
end

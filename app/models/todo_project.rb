# == Schema Information
#
# Table name: todo_projects
#
#  id          :bigint           not null, primary key
#  content     :text(65535)
#  source_type :string(255)      not null
#  title       :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          not null
#
class TodoProject < ApplicationRecord
  belongs_to :source, polymorphic: true
  has_many :todos, class_name: 'Todo', foreign_key: :project_id
end

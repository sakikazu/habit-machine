# == Schema Information
#
# Table name: todos
#
#  id          :bigint           not null, primary key
#  content     :text(65535)
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
FactoryBot.define do
  factory :todo do
    title { "MyString" }
    content { "MyText" }
    state { 1 }
  end
end

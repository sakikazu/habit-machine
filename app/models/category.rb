# == Schema Information
#
# Table name: categories
#
#  id                                              :bigint           not null, primary key
#  name                                            :string(255)      not null
#  source_type                                     :string(255)      not null
#  created_at                                      :datetime         not null
#  updated_at                                      :datetime         not null
#  parent_id(親カテゴリ)                           :bigint
#  source_id(カテゴリの所有者（ポリモーフィック）) :bigint           not null
#
# Indexes
#
#  index_categories_on_parent_id                  (parent_id)
#  index_categories_on_source_type_and_source_id  (source_type,source_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => categories.id)
#
class Category < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy

  validates :name, presence: true
  validate :validate_depth

  def shared?
    source.present? && source.class == Family
  end

  private

  def validate_depth
    depth = 0
    current = self
    while current.parent
      depth += 1
      current = current.parent
      if depth >= 3
        errors.add(:parent, 'カテゴリは3階層までしか作成できません')
        break
      end
    end
  end
end

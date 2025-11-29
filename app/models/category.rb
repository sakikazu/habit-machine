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
  has_many :category_diaries, dependent: :destroy
  has_many :diaries, through: :category_diaries

  validates :name, presence: true
  validate :validate_depth

  def shared?
    source.present? && source.class == Family
  end

  def shared_and_same_family?(family_id)
    shared? && source_id == family_id
  end

  # 家族所有カテゴリを先頭、自分所有を後方に並べ、各階層を名前順、配下の日記をタイトル順でソートしたツリーを返す。
  # include_diaries=falseの場合はカテゴリのみで構成する（選択用など）。
  def self.sorted_tree(categories, include_diaries: true)
    root_categories = categories.select { |cate| cate.parent_id.nil? }
    shared, personal = root_categories.partition(&:shared?)
    sort_categories(shared, include_diaries) + sort_categories(personal, include_diaries)
  end

  def self.sort_categories(categories, include_diaries)
    categories
      .sort_by { |cate| [cate.name.to_s.downcase, cate.id] }
      .map { |category| serialize_category(category, include_diaries) }
  end

  def self.serialize_category(category, include_diaries)
    {
      id: category.id,
      name: category.name,
      shared: category.shared?,
      diaries: include_diaries ? sorted_diaries(category.diaries) : [],
      children: sort_categories(category.children, include_diaries)
    }
  end

  def self.sorted_diaries(diaries)
    diaries.sort_by { |diary| [diary.title_mod.to_s.downcase, diary.id] }
          .map { |diary| { id: diary.id, record_at: diary.record_at, title: diary.title_mod } }
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

# == Schema Information
#
# Table name: diary_links
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  source_diary_id :bigint           not null
#  target_diary_id :bigint           not null
#
# Indexes
#
#  index_diary_links_on_source_diary_id_and_target_diary_id  (source_diary_id,target_diary_id) UNIQUE
#  index_diary_links_on_target_diary_id                      (target_diary_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_diary_id => diaries.id)
#  fk_rails_...  (target_diary_id => diaries.id)
#
class DiaryLink < ApplicationRecord
  belongs_to :source_diary, class_name: 'Diary'
  belongs_to :target_diary, class_name: 'Diary'

  validates :source_diary_id, uniqueness: { scope: :target_diary_id }

  def self.refresh_for(diary, target_ids:)
    ids = Diary.where(id: target_ids).pluck(:id)
    ids = ids.reject { |id| id == diary.id }
    transaction do
      existing_ids = where(source_diary_id: diary.id).pluck(:target_diary_id)
      deletions = existing_ids - ids
      additions = ids - existing_ids

      where(source_diary_id: diary.id, target_diary_id: deletions).delete_all if deletions.any?
      additions.each do |target_id|
        create!(source_diary_id: diary.id, target_diary_id: target_id)
      rescue ActiveRecord::RecordNotUnique
        # 並列更新で競合した場合は無視（ユニーク制約で担保）
      end
    end
  end
end

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
require 'rails_helper'

RSpec.describe DiaryLink, type: :model do
  describe '.refresh_for' do
    let(:user) { create(:user) }
    let(:target) { create(:diary, user:) }
    let(:source) do
      create(
        :diary,
        user:,
        content: "参照: https://example.com/day/#{target.record_at}/diaries/#{target.id}"
      )
    end

    it '保存時に日記間リンクを作成し、バックリンクから辿れる' do
      source.reload

      expect(source.outgoing_diary_links.pluck(:target_diary_id)).to contain_exactly(target.id)
      expect(target.backlinked_diaries).to include(source)
    end

    it 'リンクを削除すると日記間リンクも削除される' do
      source
      expect { source.update!(content: 'リンク削除') }
        .to change { source.outgoing_diary_links.count }.from(1).to(0)
    end

    it '存在しない日記IDは無視する' do
      expect do
        DiaryLink.refresh_for(source, target_ids: [target.id, 99_999_999])
      end.not_to raise_error

      expect(source.reload.outgoing_diary_links.pluck(:target_diary_id)).to contain_exactly(target.id)
    end

    it '自己リンクは作らない' do
      diary = create(:diary, user:, content: "https://example.com/day/#{Date.today}/diaries/TMP_ID")
      diary.update!(content: "https://example.com/day/#{diary.record_at}/diaries/#{diary.id}")

      expect(diary.outgoing_diary_links).to be_empty
    end
  end
end

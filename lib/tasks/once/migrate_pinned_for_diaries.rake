namespace :migrate_tag_to_pinned do
  TARGET_TAG_2 = 'everyday'

  desc "日記の固定表示をタグからpinnedカラムに変更"
  task execute: :environment do
    all_count = 0
    error_count = 0
    Diary.tagged_with(TARGET_TAG_2).find_each do |diary|
      all_count += 1
      begin
        ActiveRecord::Base.transaction do
          diary.update!(pinned: true)
          diary.tag_list.remove(TARGET_TAG_2)
          diary.save!
        end
      rescue => e
        error_count += 1
        p e.message
        p "target diary id: #{diary.id}, date: #{diary.record_at}"
      end
    end

    p "ALL COUNt: #{all_count}"
    p "ERR COUNt: #{error_count}"
  end
end

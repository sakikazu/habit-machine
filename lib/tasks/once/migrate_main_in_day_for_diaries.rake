namespace :migrate_tag_to_main_in_day do
  TARGET_TAG = 'やったこと'

  desc "1日のメイン日記をタグからmain_in_dayカラムに変更"
  task execute: :environment do
    all_count = 0
    error_count = 0
    Diary.tagged_with(TARGET_TAG).find_each do |diary|
      all_count += 1
      # transaction内でrescueするとrollbackされなくなるので（手動でrollbackすることになる）、外側で行う
      begin
        ActiveRecord::Base.transaction do
          diary.update!(main_in_day: true)
          diary.tag_list.remove(TARGET_TAG)
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

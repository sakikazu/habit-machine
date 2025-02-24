json.extract! diary, :id, :title, :content, :record_at, :main_in_day, :is_hilight, :is_secret, :is_about_date
json.title_mod diary.title_mod
json.disp_record_at dispdate(diary.record_at, true)
json.markdowned_content markdown(diary.content)
json.image_path url_for(diary.eyecatch_image_large) if diary.eyecatch_image.attached?
json.tag_links tags_link(diary)
json.category_ids diary.category_ids
json.history_count diary.histories.count

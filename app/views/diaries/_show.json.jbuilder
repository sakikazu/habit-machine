json.extract! diary, :id, :title, :record_at, :is_hilight, :is_secret, :is_about_date
json.title_mod diary.title_mod
json.markdowned_content markdown(diary.content)
json.image_path diary.image(:large) if diary.image.present?
json.tag_links tags_link(diary)

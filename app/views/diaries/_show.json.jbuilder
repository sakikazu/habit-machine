# TODO: ActiveStorage移行が完了するまでのワークアラウンド
def tmp_image_path(diary)
  "/#{diary.image(:large)}"
end

json.extract! diary, :id, :title, :content, :record_at, :main_in_day, :is_hilight, :is_secret, :is_about_date
json.title_mod diary.title_mod
json.disp_record_at dispdate(diary.record_at, true)
json.markdowned_content markdown(diary.content)
json.image_path tmp_image_path(diary) if diary.image.present?
json.tag_links tags_link(diary)

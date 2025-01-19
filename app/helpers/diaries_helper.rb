module DiariesHelper
  def tags_link(diary)
    output = ""
    diary.tags.each do |tag|
      custom_tag = CustomTag.new(tag.attributes)
      output += link_to tag.name, diaries_path(tag: tag.name), class: "badge mr5", style: custom_tag.color_style
    end
    return output.html_safe
  end

  # monthページで表示する日記コンテンツ
  def show_diary_for_month(diary)
    output = ""
    tags = tags_link(diary)

    output += "<span class='mr5 badge badge-danger'>ｼｰｸﾚｯﾄ</span>".html_safe if diary.is_secret
    output += "<span class='badge badge-warning'>ﾊｲﾗｲﾄ</span>".html_safe if diary.is_hilight
    output += "<br>".html_safe if diary.is_hilight or diary.is_secret
    output += tags + "<br>".html_safe if tags.present?
    output += "<i class='fa fa-star text-danger'></i>" if diary.main_in_day.present?
    output += "<strong>" + (link_to diary.title_mod, diary_with_date_path(diary.record_at, diary), class: 'diary-title') + "</strong>"
    # ここから日記編集は不要かなー（編集画面をなくしたのでUIを作るのもメンドイし）
    # output += " " + (link_to fa_icon('pencil'), edit_diary_path(diary)) + "<br>"
    output += image_tag("/#{diary.image(:small)}", class: "img-thumbnail") + "<br>".html_safe if diary.image.present?
    return output.html_safe
  end

  # dayページの日記一覧リンクの表示のために使用
  # NOTE: content_tagではなくtagを使うこと
  def diary_links_list(diaries)
    tag.ul do |tag|
      diaries.each do |diary|
        title = diary.title.presence || '（タイトルなし）'
        concat tag.li(link_to(title, diary_with_date_path(diary.record_at, diary)) + " " + tags_link(diary))
      end
    end
  end
end

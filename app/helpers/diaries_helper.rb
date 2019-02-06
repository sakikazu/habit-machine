module DiariesHelper
  def tags_link(diary)
    output = ""
    diary.tag_counts.each do |tag|
      output += link_to tag.name, diaries_path(tag: tag.name), class: "badge badge-secondary mr5"
    end
    return output.html_safe
  end

  def show_diary_for_toppage(diary)
    output = ""
    tags = tags_link(diary)

    output += "<span class='mr5 badge badge-danger'>ｼｰｸﾚｯﾄ</span>".html_safe if diary.is_secret
    output += "<span class='badge badge-warning'>ﾊｲﾗｲﾄ</span>".html_safe if diary.is_hilight
    output += "<br>".html_safe if diary.is_hilight or diary.is_secret
    output += tags + "<br>".html_safe if tags.present?
    output += "<strong>" + (link_to diary.title_mod, diary_path(diary)) + "</strong>"
    output += " " + (link_to fa_icon('pencil'), edit_diary_path(diary)) + "<br>"
    output += image_tag(diary.image(:small), class: "img-thumbnail") + "<br>".html_safe if diary.image.present?
    return output.html_safe
  end
end

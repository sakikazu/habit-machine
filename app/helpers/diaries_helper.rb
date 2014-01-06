# -*- coding: utf-8 -*-
module DiariesHelper

  def tags_link(diary)
    output = ""
    diary.tag_counts.each do |tag|
      output += link_to "[#{tag.name}]", diaries_path(tag: tag.name)
    end
    return output.html_safe
  end

  def show_diary_for_toppage(diary)
    output = ""
    tags = tags_link(diary)

    output += tags + "<br>".html_safe if tags.present?
    output += "<strong>" + (link_to diary.title_mod, diary_path(diary)) + "</strong>"
    output += " " + (link_to "[edit]", edit_diary_path(diary)) + "<br>"
    output += link_to(image_tag(diary.image(:small)), diary.image(:large), {class: colorbox_class}) + "<br>".html_safe if diary.image.present?
    output += truncate_30_link(diary.content)
    return output.html_safe
  end
end

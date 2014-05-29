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
    output += truncate_and_show_diary(diary)
    return output.html_safe
  end

  private
  def truncate_and_show_diary(diary)
    text = diary.content
    text2 = strip_tags(text)
    ret = sani(text2.truncate(30, :omission => ""))
    ret += link_to " ...(続き)", diary_path(diary), class: "colorbox_big", remote: true
    ret.html_safe
  end

end

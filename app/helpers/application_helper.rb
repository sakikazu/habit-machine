# -*- coding: utf-8 -*-
module ApplicationHelper

  #
  # 記録データのメモ表示(habits#index用)
  #
  def dispmemo(memo)
	return "" if memo.blank?
    icon = '<span class="glyphicon glyphicon-comment"> </span>'
    link_to icon.html_safe, "#", title: memo
  end

  #
  # 日付表示(habits#index用)
  #
  def dispdate(date, is_long = false)
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    ret = ""
    if is_long
      ret = date.to_s(:normal)
    else
      ret = date.to_s(:short)
    end
    ret += "(#{wdays[date.wday]})"
  end

  #
  # 日付セル用CSSのclass(habits#index用)
  #
  def dateclass(date)
    if date == Date.today
      return "today"
    elsif date.wday == 0
      return "sunday"
    elsif date.wday == 6
      return "saturday"
    end
  end


  #
  # UserAgentから各デバイス名を割り出す
  #
  def useragent(ua)
    case ua
    when /iPhone OS (\d)/
      ret = "iOS#{$1}"
    when /Chrome\/([\d]*)/
      ret = "Chrome#{$1}"
      ret += " [Android#{$1}]" if /Android ([\d\.\s]*)/ =~ ua
    when /Firefox\/([\d]*)/
      ret = "Firefox#{$1}"
      ret += " [Android#{$1}]" if /Android([\d\.\s]*)/ =~ ua
    when /Opera\/([\d]*)/
      ret = "Opera#{$1}"
      ret += " [Android#{$1}]" if /Android ([\d\.\s]*)/ =~ ua
    when /Android ([\d\.]*)/
      ret = "Android #{$1}"
    when /MSIE (\d)/
      ret = "IE#{$1}"
    else
      ret = " 不明 "
    end
    return ret
  end


  #
  # イイネの表示フィールド
  # 何度もrenderされるので、無理にヘルパーにした
  #
  def nice_field(content, content_type, area)
    output = <<"EOS"
<script>
jQuery(document).ready(function(){
  nice_member();
})
</script>

EOS

    if content.nices.size > 0
      output += <<"EOS"
<strong style="color:red" class="nice_members" nice_members="#{content.nices.map{|n| n.user.dispname}.join(",")}">イイネ(#{content.nices.size})</strong>
EOS
    end

    nice = content.nices.blank? ? nil : content.nices.where(:user_id => current_user.id).first
    if nice.present?
      output += <<"EOS"
  :#{link_to 'イイネを取り消す', nice_path(:id => nice.id, :type => content_type, :content_id => content.id, :area => area), :method => :delete, :remote => true}
EOS
    else
      output += <<"EOS"
  #{link_to '<span class="glyphicon glyphicon-heart"></span>&nbsp;イイネ '.html_safe, nices_path(:type => content_type, :content_id => content.id, :area => area), :method => :post, :remote => true}
EOS
    end

    return output.html_safe
  end

  def nice_field_disp_only(content)
    output = <<"EOS"
<script>
jQuery(document).ready(function(){
  nice_member();
})
</script>

EOS

    if content.nices.size > 0
      output += <<"EOS"
<strong style="color:red" class="nice_members" nice_members="#{content.nices.map{|n| n.user.dispname}.join(",")}">イイネ(#{content.nices.size})</strong>
EOS
    end

    return output.html_safe
  end


  def nice_author_and_created_at(obj)
     "<div class='nice_content_info'>投稿者：#{obj.user.dispname} / 投稿日：#{l obj.created_at}</div>".html_safe
  end

  def colorbox_class
    # request.smart_phone? ? "" : "colorbox"
    "colorbox"
  end

  def colorbox_fix_size
    # request.smart_phone? ? "" : "colorbox_fix_size"
    "colorbox_fix_size"
  end


  def form_html_option
    # request.smart_phone? ? {} : {:multipart => true}
    {:multipart => true}
  end

  def editable(login_user, content_user)
    login_user.role == 0 or login_user.role == 1 or (content_user.present? and (login_user.id == content_user.id))
  end

  def sani(html)
    auto_link(Sanitize.clean(html, Sanitize::Config::BASIC)).html_safe
  end

  def sani_br(html)
    html.gsub!(/\r\n|\r|\n/, "<br>") unless html.blank?
    auto_link(Sanitize.clean(html, Sanitize::Config::BASIC)).html_safe
  end

  def sani_custom(html)
    auto_link(Sanitize.clean(html, Sanitize::Config::CUSTOM)).html_safe
  end

  def sani_custom_br(html)
    html.gsub!(/\r\n|\r|\n/, "<br>") unless html.blank?
    auto_link(Sanitize.clean(html, Sanitize::Config::CUSTOM)).html_safe
  end

  #jsコード内に出力するときに改行コードがあるとjsコード自体が改行されてしまうのでスペースに変換する
  def sani_for_js(html)
    html.gsub!(/[\r\n]+/, " ") if html.present?
    # これだとクォーテーションなどがそのままになり、JSの動作に不具合が生じた。タグを有効にしたかったんだろうけどとりあえずJS内ではデザインなしってことで無効。
    # auto_link(Sanitize.clean(h(html), Sanitize::Config::BASIC)).html_safe
    auto_link(h(html))
  end

  #※マルチバイト文字対応(utf8)
  def truncate_120_link(text)
    text2 = strip_tags(text)
    if text2.split(//u).length > 120
      ret = sani_br(text2.truncate(120, :omission => ""))
      ret += link_to " ...(続き)", "javascript:void(0)", :title => text2, :class => "overstring"
    else
      ret = sani_br(text2)
    end
    ret.html_safe
  end

  #※マルチバイト文字対応(utf8)
  def truncate_30_link(text)
    text2 = strip_tags(text)
    if text2.split(//u).length > 30
      ret = sani(text2.truncate(30, :omission => ""))
      ret += link_to " ...(続き)", "javascript:void(0)", :title => text2, :class => "overstring"
    else
      ret = sani(text2)
    end
    ret.html_safe
  end

end

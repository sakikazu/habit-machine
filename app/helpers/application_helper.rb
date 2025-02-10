module ApplicationHelper
  def current_family
    current_user&.family
  end

  #
  # <title>
  #
  def page_title
    return @page_title if @page_title.present?

    action_name_h = @action_name || case controller.action_name
                    when "show"
                      ''
                    when "edit"
                      '編集'
                    when "index"
                      '一覧'
                    when "new"
                      '新規作成'
                    end
    controller_name_h = case controller.controller_name
                        when "senses"
                          "意識付け"
                        when "tags"
                          "日記タグ"
                        when "diaries"
                          "日記"
                        when "habits"
                          "習慣"
                        when "records"
                          "記録"
                        when "habitodos"
                          "Habitodo"
                        end

    result = ''
    result += action_name_h.presence || ''
    result += ' | ' if action_name_h.present? && @content_title.present?
    result += @content_title.presence || ''
    result += "[#{controller_name_h}]" if controller_name_h.present?
    return result
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
    wday = if date.wday == 0
             "sunday"
           elsif date.wday == 6
             "saturday"
           else
             ""
           end
    date == Date.today ? "#{wday} today" : wday
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
    html_br = nl2br(html)
    auto_link(Sanitize.clean(html_br, Sanitize::Config::BASIC)).html_safe
  end

  def sani_custom(html)
    auto_link(Sanitize.clean(html, Sanitize::Config::CUSTOM)).html_safe
  end

  def sani_custom_br(html)
    html_br = nl2br(html)
    auto_link(Sanitize.clean(html_br, Sanitize::Config::CUSTOM)).html_safe
  end

  #jsコード内に出力するときに改行コードがあるとjsコード自体が改行されてしまうのでスペースに変換する
  def sani_for_js(html)
    html.gsub!(/[\r\n]+/, " ") if html.present?
    # これだとクォーテーションなどがそのままになり、JSの動作に不具合が生じた。タグを有効にしたかったんだろうけどとりあえずJS内ではデザインなしってことで無効。
    # auto_link(Sanitize.clean(h(html), Sanitize::Config::BASIC)).html_safe
    auto_link(h(html))
  end

  #※マルチバイト文字対応(utf8)
  def truncate_link(text, length)
    return '' if text.blank?
    text2 = strip_tags(text)
    if text2.split(//u).length > length
      ret = sani_switching(text2.truncate(length, :omission => ""), length)
      ret += link_to " ...(続き)", "javascript:void(0)", :title => text2, :class => "overstring"
    else
      ret = sani_switching(text2, length)
    end
    ret.html_safe
  end

  def sani_switching(text, length)
    length > 100 ? sani_br(text) : sani(text)
  end

  def truncate_120_link(text)
    truncate_link(text, 120)
  end

  def truncate_30_link(text)
    truncate_link(text, 30)
  end

  def nl2br(str)
    return str.present? ? str.gsub(/\r\n|\r|\n/, '<br>') : ''
    # return sanitize(str).gsub(/\r\n|\n/, '<br>').html_safe
  end

  # filter_htmlオプションにより入力されたタグを無効化してくれるのでサニタイズは不要
  def markdown text
    return '' if text.blank?

    options = {
      filter_html:     true, # htmlタグをサニタイズではなく<p>タグに置き換えて無効化
      hard_wrap:       true, # 空行を改行ではなく、改行を改行に変換
      space_after_headers: true, # ｼｬｰﾌﾟの後に空白がないと見出しと認めません
    }

    extensions = {
      autolink:           true, # リンクタグ適用
      no_intra_emphasis:  true, # aaa_bbb_ccc の bbb を強調しないように
      fenced_code_blocks: true, # ```で囲まれた部分をコードとして装飾
    }

    renderer = CustomRedcarpetRender.new(options)
    md = Redcarpet::Markdown.new(renderer, extensions)

    md.render(text).html_safe
  end

  def markdown_help_link
    link_to "markdown記法", "https://qiita.com/tbpgr/items/989c6badefff69377da7", target: :blank
  end

  # TODO: 「家族」タブでは複数controllerが含まれるので、それに対応できるようにしたい。activeかどうかのメソッドを切り出して、家族の方ではそのメソッドを並べて、viewの方でactiveを出力するとか
  def active_class(controller_name, only: [], except: [])
    return '' unless controller.controller_name == controller_name
    return '' if only.present? && only.exclude?(controller.action_name)
    return '' if except.present? && except.include?(controller.action_name)

    'active'
  end
end

class CustomRedcarpetRender < Redcarpet::Render::HTML
  def header(text, header_level)
    if text == Diary::ACTION_MEMO_LINE.gsub(/^#+\s+/, '')
      %(<h#{header_level} class="action_memo_in_md">メモ追加欄</h#{header_level}>)
    else
      %(<h#{header_level}>#{text}</h#{header_level}>)
    end
  end
end

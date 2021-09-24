class CustomRedcarpetRender < Redcarpet::Render::HTML
  def header(text, header_level)
    if text == Diary::ACTION_MEMO_LINE.gsub(/^#+\s+/, '')
      # NOTE: パーセントで囲むとhtmlがそのまま書けるのか。使える
      %(<h#{header_level} class="action_memo_in_md">追加されたメモ</h#{header_level}>)
    else
      %(<h#{header_level}>#{text}</h#{header_level}>)
    end
  end
end

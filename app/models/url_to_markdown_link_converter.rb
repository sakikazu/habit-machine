# テキスト内の本サービスURLを、そのURL先のリソース情報を合わせてmarkdownのリンク形式にするクラス
# 既にmarkdownリンクになっているURLも再変換を行うので、URL先リソースの変更（日記タイトル変更など）があっても、再実行すれば変更が反映可能
#
# 自サービス内のURLなので、URL先を取得する際はAPIではなくDBから直接取得
# 現在は、日記ページURLのみに対応している
# 変換によって元テキストを壊したりしないかの懸念については、変換対象はマークダウンのリンク部分と、本サービスURL部分のみなので、あとはそこの変換が問題ないことはrspecで担保
# Claudeが生成したコードに手を加えたもの
class UrlToMarkdownLinkConverter
  include Rails.application.routes.url_helpers
  # NOTE: /\[.*?\]\(.*?\)/ にしてたら意図した最短一致にはならず、 "[15:00] xxx [title](url)" でもマッチしてしまったので修正
  MARKDOWN_LINK_PATTERN = /\[[^\]]+\]\([^\)]+\)/
  DIARY_PATH = 'day/.+?/diaries'

  def initialize(target_model)
    @target_model = target_model
    @root_url = root_url(host: Rails.application.routes.default_url_options[:host])
  end

  # TODO: user: だけにできるrubyバージョンにしたいな
  def convert(text)
    # 既存のMarkdownリンクを一時的に置換して保護
    placeholders = {}
    text_without_existing_links = text.gsub(MARKDOWN_LINK_PATTERN) do |matched|
      placeholder = "PLACEHOLDER_#{placeholders.length}"
      # ここはシンプルな正規表現でOK
      url = if match_data = matched.match(/\[.*?\]\((.*?)\)/)
              match_data[1]
            end
      label = diary_markdown_link_from(url)
      placeholders[placeholder] = label.presence || matched
      placeholder
    end

    # URLを検出して変換
    processed_text = text_without_existing_links.gsub(%r{#{diary_path}/\d+}) do |url|
      label = diary_markdown_link_from(url)
      label.presence || url
    end

    # プレースホルダーを元のMarkdownリンクに戻す
    placeholders.each do |placeholder, original|
      processed_text.gsub!(placeholder, original)
    end

    processed_text
  end

  private

  def diary_markdown_link_from(url)
    diary_id = if match_data = url.match(%r{#{diary_path}/(\d+)})
                 match_data[1]
               end
    return if diary_id.blank?

    diary = @target_model.find_by(id: diary_id)
    return if diary.blank?

    diary_title = diary.title.presence || '（タイトルなし）'
    "[🔗#{diary.record_at}: #{diary_title}🔗](#{url})"
  end

  def diary_path
    "#{@root_url}#{DIARY_PATH}"
  end
end

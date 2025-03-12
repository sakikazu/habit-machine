require 'open-uri'

# contentEditableにコピペされたhtmlから余計なものを削除したり、画像を持ってきてHMの画像にして、content内容を置換するクラス
class Diary::HtmlConverter
  attr_reader :converted_content, :uploaded_images

  # @param [String] contentEditableの内容
  def initialize(content)
    @converted_content = content
    @uploaded_images = []
  end

  def convert
    remove_tw_attributes
    remove_source_tags
    image_urls = extract_image_urls
    replace_with_active_storage_urls(image_urls)
  end

  private

  # cookpadレシピのhtml style内に含まれる「--tw-xxx」という属性を削除（大量にあるので、文字数削減のため）
  # styleごと削除しちゃうとレイアウトが崩れるのでうまいこと削除する
  # ex. style="--tw-border-spacing-x: 0; margin-top: calc(1rem*(1 - var(--tw-space-y-reverse)));" みたいな文字列
  def remove_tw_attributes
    @converted_content.gsub!(/--tw-[\w-]+:[^;]*;|--tw-[\w-]+\b/, '')
  end

  def remove_source_tags
    # NOTE: \bは単語境界。<sourcefoo>などのタグを誤って検知しないように
    # NOTE: .*?の最短マッチより、[^>]*のほうが使いやすそう（どっかで、後者じゃないと成功しないケースがあったが見失った）
    @converted_content.gsub!(/<source\b[^>]*>/, '')
  end

  # content中の <img> タグの src 属性から画像URLを抽出
  def extract_image_urls
    # 正規表現で <img> タグの src 属性を抽出
    @converted_content.scan(/<img[^>]+src=["']([^"']+)["']/i).flatten
  end

  # 画像URLからダウンロードし、ActiveStorageに保存して、そのURLで置換する
  def replace_with_active_storage_urls(image_urls)
    image_urls.each do |image_url|
      begin
        # 画像をダウンロード
        decoded_image_url = CGI.unescapeHTML(image_url) # &が&amp;のようにエスケープされているのをデコードする
        downloaded_image = URI.open(decoded_image_url)
        filename = URI.decode_www_form_component(File.basename(URI.parse(image_url).path))

        # attachだとモデルのsave後に処理されてしまい、attachの時点では正確な画像URLが取得できないので、即時処理されるcreate_and_upload!を使う
        blob = ActiveStorage::Blob.create_and_upload!(
          io: downloaded_image,
          filename:,
          content_type: downloaded_image.content_type
        )

        # ActiveStorageのURLに置換
        # 貼り付けたhtml内の画像はサムネイル画像サイズ想定のため、ActiveStorageではリサイズせずオリジナルを使う
        @converted_content.gsub!(image_url, Rails.application.routes.url_helpers.url_for(blob))

        @uploaded_images << blob
      end
    end
  end
end

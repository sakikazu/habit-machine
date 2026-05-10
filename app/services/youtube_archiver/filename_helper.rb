# frozen_string_literal: true

module YoutubeArchiver
  module FilenameHelper
    module_function

    # ダウンロード向けにファイル名へ使えない文字を除去する
    def sanitize_filename(name, max_length: 120)
      safe_name = name.to_s.gsub(/[\/\\:*?"<>|]/, "_").gsub(/\s+/, "_").gsub(/\A_+|_+\z/, "")
      safe_name = safe_name[0, max_length]
      safe_name.empty? ? "untitled" : safe_name
    end
  end
end

# frozen_string_literal: true

require "fileutils"
require "securerandom"
require_relative "fetcher"
require_relative "filename_helper"
require_relative "formatter"

module YoutubeArchiver
  class CommentsArchiver
    DEFAULT_MAX_THREADS = 1_000
    DEFAULT_OUTPUT_ROOT = "/tmp/habit_machine/youtube_archives"
    CLEANUP_THRESHOLD = 1.day

    def initialize(url:, output_root: DEFAULT_OUTPUT_ROOT, max_threads: DEFAULT_MAX_THREADS)
      @url = url
      @output_root = output_root
      @max_threads = max_threads
    end

    # コメントを取得してMarkdownとJSONを書き出す
    def archive
      validate_url!
      cleanup_old_archives!

      api_key = Settings.youtube_api.key
      raise "YOUTUBE_API_KEY が設定されていません" if api_key.to_s.strip.empty?

      fetcher = Fetcher.new(api_key: api_key)
      video_id = fetcher.extract_video_id(@url)
      raise "video_id を抽出できませんでした: #{@url}" if video_id.nil?

      video = fetcher.fetch_video(video_id)
      threads = fetcher.fetch_threads(video_id:, max_threads: @max_threads, order: "time")
      payload = Formatter.build_payload(
        video:,
        source: { input: @url, video_id:, url: "https://www.youtube.com/watch?v=#{video_id}" },
        threads:
      )

      output_dir = build_output_dir(video_id)
      safe_title = FilenameHelper.sanitize_filename(video[:title])
      json_path = File.join(output_dir, "#{safe_title}.json")
      markdown_path = File.join(output_dir, "#{safe_title}.md")

      File.write(json_path, Formatter.to_pretty_json(payload))
      File.write(markdown_path, Formatter.to_markdown(payload))

      { path: markdown_path, filename: "#{safe_title}.md" }
    end

    private

    def validate_url!
      raise "YouTubeのURLを入力してください" if @url.blank?
    end

    def build_output_dir(video_id)
      dir = File.join(@output_root, "#{video_id}_#{Time.current.strftime('%Y%m%d%H%M%S')}_#{SecureRandom.hex(4)}")
      FileUtils.mkdir_p(dir)
      dir
    end

    # /tmp配下に溜まり続けないよう古い一時ディレクトリを削除する
    def cleanup_old_archives!
      FileUtils.mkdir_p(@output_root)

      Dir.glob(File.join(@output_root, "*")).each do |path|
        next unless File.directory?(path)
        next if File.mtime(path) >= CLEANUP_THRESHOLD.ago

        FileUtils.rm_rf(path)
      end
    end
  end
end

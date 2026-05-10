# frozen_string_literal: true

require "fileutils"
require "securerandom"
require_relative "downloader"
require_relative "fetcher"

module YoutubeArchiver
  class AudioArchiver
    DEFAULT_OUTPUT_ROOT = "/tmp/habit_machine/youtube_archives"
    CLEANUP_THRESHOLD = 1.day

    def initialize(url:, output_root: DEFAULT_OUTPUT_ROOT)
      @url = url
      @output_root = output_root
    end

    # 動画から音声を抽出して返却用パスを返す
    def download
      validate_url!
      cleanup_old_archives!

      video_id = Fetcher.extract_video_id(@url)
      raise "video_id を抽出できませんでした: #{@url}" if video_id.nil?

      output_dir = build_output_dir(video_id)
      path = Downloader.new(executable: ENV.fetch("YT_DLP_PATH", "yt-dlp")).download(
        url: "https://www.youtube.com/watch?v=#{video_id}",
        output_dir:,
        mode: Downloader::MODE_AUDIO
      )

      { path:, filename: File.basename(path) }
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

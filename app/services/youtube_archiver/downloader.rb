# frozen_string_literal: true

require "fileutils"
require "open3"
require_relative "filename_helper"

module YoutubeArchiver
  class Downloader
    MODE_VIDEO = :video
    MODE_AUDIO = :audio

    def initialize(executable: "yt-dlp")
      @executable = executable
    end

    def download(url:, output_dir:, mode: MODE_VIDEO)
      ensure_executable!

      temp_template = File.join(output_dir, "__download__.%(ext)s")
      FileUtils.rm_f(Dir.glob(File.join(output_dir, "__download__.*")))

      stdout, stderr, status = Open3.capture3(*build_command(url, temp_template, mode))
      raise build_error(stderr, stdout, mode) unless status.success?

      lines = stdout.lines.map(&:strip).reject(&:empty?)
      title = lines.first
      downloaded_path = lines.last
      raise "動画ファイルの保存先を特定できませんでした" if downloaded_path.to_s.empty?

      ext = File.extname(downloaded_path)
      basename = FilenameHelper.sanitize_filename(title)
      final_path = File.join(output_dir, "#{basename}#{ext}")
      FileUtils.mv(downloaded_path, final_path)
      final_path
    end

    private

    def build_command(url, output_template, mode)
      command = [
        @executable,
        "--no-progress",
        "--no-warnings",
        "-o", output_template,
        "--print", "title",
        "--print", "after_move:filepath"
      ]

      command.concat(mode_options(mode))
      command << url
      command
    end

    # 動画は高画質優先、音声は抽出専用の指定にする
    def mode_options(mode)
      case mode
      when MODE_VIDEO
        [
          "-f", "bv*+ba/b"
        ]
      when MODE_AUDIO
        [
          "-x",
          "--audio-format", "mp3",
          "--audio-quality", "0"
        ]
      else
        []
      end
    end

    def ensure_executable!
      return if executable_available?

      raise "yt-dlp が見つかりません。`yt-dlp` をインストールするか、YT_DLP_PATH を設定してください"
    end

    def executable_available?
      return File.executable?(@executable) if @executable.include?(File::SEPARATOR)

      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
        File.executable?(File.join(dir, @executable))
      end
    end

    def build_error(stderr, stdout, mode)
      detail = [stderr, stdout].map(&:to_s).find { |text| !text.strip.empty? }
      action = mode == MODE_AUDIO ? "音声抽出" : "動画ダウンロード"
      return "yt-dlp による#{action}に失敗しました" if detail.nil?

      "yt-dlp による#{action}に失敗しました: #{detail.lines.last.to_s.strip}"
    end
  end
end

# frozen_string_literal: true

require "fileutils"
require "open3"
require "securerandom"
require_relative "filename_helper"

module YoutubeArchiver
  class Downloader
    class DownloadError < StandardError
      attr_reader :error_id

      def initialize(message, error_id:)
        @error_id = error_id
        super("#{message}（エラーID: #{error_id}）")
      end
    end

    MODE_VIDEO = :video
    MODE_AUDIO = :audio

    def initialize(executable: "yt-dlp", logger: Rails.logger)
      @executable = executable
      @logger = logger
    end

    # yt-dlpを実行し、失敗時は追跡可能な診断情報をログへ残す
    def download(url:, output_dir:, mode: MODE_VIDEO)
      ensure_executable!

      temp_template = File.join(output_dir, "__download__.%(ext)s")
      FileUtils.rm_f(Dir.glob(File.join(output_dir, "__download__.*")))
      command = build_command(url, temp_template, mode)
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      stdout, stderr, status = Open3.capture3(*command)
      unless status.success?
        error_id = SecureRandom.hex(6)
        log_failure(
          error_id:,
          mode:,
          command:,
          stdout:,
          stderr:,
          exit_status: status.exitstatus,
          elapsed_seconds: elapsed_seconds_since(started_at)
        )
        raise DownloadError.new(build_error(stderr, stdout, mode), error_id:)
      end

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

    # 認証情報を含み得るURLを除外して実行失敗の詳細を記録する
    def log_failure(error_id:, mode:, command:, stdout:, stderr:, exit_status:, elapsed_seconds:)
      safe_command = command[0...-1]
      @logger.error(<<~LOG)
        [YoutubeArchiver::Downloader] yt-dlp failed
        error_id=#{error_id}
        mode=#{mode}
        executable=#{resolved_executable_path}
        version=#{executable_version}
        exit_status=#{exit_status}
        elapsed_seconds=#{format('%.3f', elapsed_seconds)}
        command_without_url=#{safe_command.inspect}
        stdout:
        #{stdout.to_s.rstrip}
        stderr:
        #{stderr.to_s.rstrip}
      LOG
    rescue StandardError => logging_error
      @logger.error("[YoutubeArchiver::Downloader] 診断ログの記録に失敗しました: #{logging_error.class}: #{logging_error.message}")
    end

    # yt-dlp実行開始からの経過秒数を返す
    def elapsed_seconds_since(started_at)
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    end

    # PATH指定の場合も実際に利用される実行ファイルを特定する
    def resolved_executable_path
      return File.expand_path(@executable) if @executable.include?(File::SEPARATOR)

      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).each do |dir|
        path = File.join(dir, @executable)
        return path if File.executable?(path)
      end
      @executable
    end

    # Webプロセスが利用しているyt-dlpのバージョンを取得する
    def executable_version
      stdout, = Open3.capture3(resolved_executable_path, "--version")
      version = stdout.to_s.strip
      version.empty? ? "unknown" : version
    rescue StandardError
      "unknown"
    end

    def build_command(url, output_template, mode)
      command = [
        @executable,
        "--no-progress",
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

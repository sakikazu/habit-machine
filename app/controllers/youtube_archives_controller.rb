class YoutubeArchivesController < ApplicationController
  before_action :authenticate_user!

  def show
    @page_title = "YouTubeアーカイブ"
  end

  def download_video
    result = YoutubeArchiver::VideoArchiver.new(url: archive_url).download
    send_file result[:path], filename: result[:filename], disposition: :attachment
  rescue StandardError => e
    handle_error(e)
  end

  def download_audio
    result = YoutubeArchiver::AudioArchiver.new(url: archive_url).download
    send_file result[:path], filename: result[:filename], disposition: :attachment
  rescue StandardError => e
    handle_error(e)
  end

  def download_comments
    result = YoutubeArchiver::CommentsArchiver.new(url: archive_url).archive
    send_file result[:path], filename: result[:filename], disposition: :attachment
  rescue StandardError => e
    handle_error(e)
  end

  private

  # URL入力欄の値を取り出す
  def archive_url
    params[:url].to_s.strip
  end

  def handle_error(error)
    error_id = error.respond_to?(:error_id) ? error.error_id : SecureRandom.hex(6)
    Rails.logger.error(<<~LOG)
      [YoutubeArchivesController] YouTubeアーカイブ処理に失敗しました
      error_id=#{error_id}
      error_class=#{error.class}
      message=#{error.message}
      backtrace:
      #{Array(error.backtrace).join("\n")}
    LOG

    message = error.message.include?("エラーID:") ? error.message : "#{error.message}（エラーID: #{error_id}）"
    if request.xhr?
      render json: { error: message, error_id: }, status: :unprocessable_entity
      return
    end

    flash.now[:alert] = message
    @page_title = "YouTubeアーカイブ"
    render :show, status: :unprocessable_entity
  end
end

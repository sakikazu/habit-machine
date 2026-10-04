# frozen_string_literal: true

require 'image_processing/mini_magick'

# 日記画像を保存前に縮小し、Active Storageへ渡せる形式に変換する
class DiaryImageOptimizer
  MAX_UPLOAD_SIZE = 20.megabytes
  MAX_DIMENSION = 2048
  QUALITY = 80

  class Error < StandardError; end

  def self.call(uploaded_file)
    new(uploaded_file).call
  end

  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def call
    validate!

    optimized_file = ImageProcessing::MiniMagick
      .source(uploaded_file.tempfile)
      .auto_orient
      .resize_to_limit(MAX_DIMENSION, MAX_DIMENSION)
      .saver(quality: QUALITY)
      .call

    {
      io: optimized_file,
      filename: uploaded_file.original_filename,
      content_type: uploaded_file.content_type
    }
  rescue ImageProcessing::Error, MiniMagick::Error
    raise Error, '画像を処理できませんでした。JPEG、PNG、WebPなどの画像を選択してください'
  end

  private

  attr_reader :uploaded_file

  def validate!
    if uploaded_file.size > MAX_UPLOAD_SIZE
      raise Error, "画像サイズは#{MAX_UPLOAD_SIZE / 1.megabyte}MB以下にしてください"
    end

    return if uploaded_file.content_type.to_s.start_with?('image/')

    raise Error, '画像ファイルを選択してください'
  end
end

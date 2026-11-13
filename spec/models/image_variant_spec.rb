require 'rails_helper'

RSpec.describe '画像variant', type: :model do
  let(:source_file) do
    Tempfile.new(['image-variant', '.jpg']).tap do |file|
      MiniMagick::Tool::Convert.new do |convert|
        convert.size '800x400'
        convert << 'xc:white'
        convert << file.path
      end
    end
  end

  after do
    source_file.close!
  end

  it 'Historyのアイキャッチ画像をMiniMagickで縮小できる' do
    author = create(:user)
    history = create(:history, author: author, family: author.family)
    attach_image(history)

    image = processed_image(history.eyecatch_image_small)

    expect(Rails.application.config.active_storage.variant_processor).to eq(:mini_magick)
    expect([image.width, image.height]).to eq([350, 175])
  ensure
    history&.eyecatch_image&.purge
  end

  it 'Diaryのアイキャッチ画像をMiniMagickで縮小できる' do
    diary = create(:diary)
    attach_image(diary)

    image = processed_image(diary.eyecatch_image_small)

    expect(Rails.application.config.active_storage.variant_processor).to eq(:mini_magick)
    expect([image.width, image.height]).to eq([180, 90])
  ensure
    diary&.eyecatch_image&.purge
  end

  private

  # テスト対象へ画像を添付する
  def attach_image(record)
    File.open(source_file.path) do |io|
      record.eyecatch_image.attach(
        io: io,
        filename: 'eyecatch.jpg',
        content_type: 'image/jpeg'
      )
    end
  end

  # variantを実際に生成して画像として読み込む
  def processed_image(variant)
    MiniMagick::Image.read(variant.processed.download)
  end
end

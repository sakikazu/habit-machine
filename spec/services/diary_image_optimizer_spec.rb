require 'rails_helper'

RSpec.describe DiaryImageOptimizer do
  describe '.call' do
    let(:source_file) do
      Tempfile.new(['diary-image', '.jpg']).tap do |file|
        MiniMagick::Tool::Convert.new do |convert|
          convert.size '2400x1200'
          convert << 'xc:white'
          convert << file.path
        end
      end
    end
    let(:uploaded_file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: source_file,
        filename: 'large.jpg',
        type: 'image/jpeg'
      )
    end

    after do
      source_file.close!
    end

    it '長辺を上限まで縮小した画像を返す' do
      result = described_class.call(uploaded_file)
      image = MiniMagick::Image.open(result[:io].path)

      expect([image.width, image.height]).to eq([2048, 1024])
      expect(result).to include(filename: 'large.jpg', content_type: 'image/jpeg')
    ensure
      result&.dig(:io)&.close!
    end

    it '上限を超えるファイルを拒否する' do
      allow(uploaded_file).to receive(:size).and_return(20.megabytes + 1)

      expect { described_class.call(uploaded_file) }
        .to raise_error(described_class::Error, '画像サイズは20MB以下にしてください')
    end
  end
end

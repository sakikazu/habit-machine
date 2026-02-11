require 'rails_helper'
require 'base64'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#markdown' do
    let(:png_data) do
      Base64.decode64(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=='
      )
    end

    # テスト用画像を添付する
    def attach_image(diary)
      diary.images.attach(io: StringIO.new(png_data), filename: 'test.png', content_type: 'image/png')
      diary.images.last
    end

    it '自分の日記の画像はプレースホルダをURLに置換する' do
      diary = create(:diary)
      attachment = attach_image(diary)

      content = "![image-#{attachment.id}](#{Diary::ACTIVE_STORAGE_URL_PLACEHOLDER})"
      html = helper.markdown(content, diary: diary)

      expect(html).to include(helper.diary_image_url_for(attachment))
      expect(html).not_to include(Diary::ACTIVE_STORAGE_URL_PLACEHOLDER)
    end

    it '他の日記の画像はプレースホルダを置換しない' do
      diary = create(:diary)
      other_diary = create(:diary)
      other_attachment = attach_image(other_diary)

      content = "![image-#{other_attachment.id}](#{Diary::ACTIVE_STORAGE_URL_PLACEHOLDER})"
      html = helper.markdown(content, diary: diary)

      expect(html).not_to include(helper.diary_image_url_for(other_attachment))
      expect(html).to include(Diary::ACTIVE_STORAGE_URL_PLACEHOLDER)
    end
  end
end

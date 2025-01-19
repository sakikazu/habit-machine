require 'rails_helper'

RSpec.describe UrlToMarkdownLinkConverter, type: :model do
  include Rails.application.routes.url_helpers

  describe '#convert' do
    subject(:result) { described_class.new(Diary).convert(target_text) }

    let(:user) { create(:user) }
    let(:diary) { create(:diary, user:) }

    def diary_url(diary)
      diary_with_date_url(diary.record_at, diary)
    end

    context '存在する日記のURLを含む場合' do
      let(:target_text) do
        "aaa #{diary_url(diary)} zzz"
      end

      it 'URLがmarkdownのリンクに変換されること' do
        expect(result).to match(/aaa \[.*#{diary.title}.*\]\(#{diary_url(diary)}\) zzz/)
      end
    end

    context '存在しない日記のURLを含む場合' do
      let(:target_text) { 'aaa http://example.com/day/2025-01-18/diaries/0 zzz' }

      it '何も変更されないこと' do
        expect(result).to eq target_text
      end
    end

    context '既にmarkdownのリンクが存在する場合' do
      let(:target_text) do
        "aaa [日記です](#{diary_url(diary)}) zzz"
      end

      it '日記のタイトルが更新されること' do
        expect(result).to match(/aaa \[.*#{diary.title}.*\]\(#{diary_url(diary)}\) zzz/)
      end
    end

    context 'markdownのリンクぽいものが含まれる場合' do
      let(:target_text) do
        "- [15:00] aaa [日記です](#{diary_url(diary)}) [zz](xxx)"
      end

      it 'markdownリンク以外の箇所は更新されないこと' do
        expect(result).to match(
          /- \[15:00\] aaa \[.*#{diary.title}.*\]\(#{diary_url(diary)}\) \[zz\]\(xxx\)/
        )
      end
    end

    context '複数の日記のURLを含む場合' do
      let(:diary2) { create(:diary, user:) }
      let(:target_text) do
        "aaa #{diary_url(diary)} zzz #{diary_url(diary2)}"
      end

      it 'すべてのURLがmarkdownのリンクに変換されること' do
        expect(result).to match(
          /aaa \[.*#{diary.title}.*\]\(#{diary_url(diary)}\) zzz \[.*#{diary2.title}.*\]\(#{diary_url(diary2)}\)/
        )
      end
    end
  end
end

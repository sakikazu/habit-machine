require 'rails_helper'

RSpec.describe "Diaries", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get diaries_path
      expect(response).to have_http_status(:success)
    end

    context 'no login' do
      before do
        sign_out user
      end

      it 'リダイレクトされる' do
        get diaries_path
        expect(response).to have_http_status(:found) # 302
      end
    end
  end

  # showアクション
  describe "GET /:id" do
    let(:diary) { create(:diary, user:) }

    it "works!" do
      get diary_with_date_path(diary.record_at, diary)
      expect(response).to have_http_status(:success)
    end

    context '日記の所有者ではないユーザー' do
      let(:unknown_user) { create(:user, email: 'test2@example.com') }

      before do
        sign_out user
        sign_in unknown_user
      end

      it 'ActiveRecord::RecordNotFoundが発生すること' do
        get diary_with_date_path(diary.record_at, diary)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

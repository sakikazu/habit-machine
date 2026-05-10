require 'rails_helper'

RSpec.describe "YoutubeArchives", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /youtube_archive" do
    it "returns http success" do
      get youtube_archive_path
      expect(response).to have_http_status(:success)
    end

    context 'no login' do
      before do
        sign_out user
      end

      it 'リダイレクトされる' do
        get youtube_archive_path
        expect(response).to have_http_status(:found)
      end
    end
  end
end

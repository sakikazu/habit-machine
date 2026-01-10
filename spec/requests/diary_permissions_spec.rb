require 'rails_helper'

RSpec.describe 'Diary permissions', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:family) { create(:family) }
  let(:owner) { create(:user, family:) }
  let(:member) { create(:user, family:, email: 'member@example.com') }
  let(:outsider) { create(:user, family: create(:family), email: 'outsider@example.com') }
  let(:diary) { create(:diary, user: owner) }

  describe 'GET /day/:date/diaries/:id' do
    it '所有者は閲覧できる' do
      sign_in owner
      get diary_with_date_path(diary.record_at, diary)
      expect(response).to have_http_status(:success)
    end

    context '家族共有のカテゴリが紐づく場合' do
      before do
        shared_category = create(:category, source: family)
        create(:category_diary, category: shared_category, diary:)
      end

      it '同じ家族のユーザーは閲覧できる' do
        sign_in member
        get diary_with_date_path(diary.record_at, diary)
        expect(response).to have_http_status(:success)
      end

      it '別家族のユーザーは閲覧できない' do
        sign_in outsider
        get diary_with_date_path(diary.record_at, diary)
        expect(response).to have_http_status(:not_found)
      end
    end

    context '共有されていない日記の場合' do
      it '同じ家族でも閲覧できない' do
        sign_in member
        get diary_with_date_path(diary.record_at, diary)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/diaries/:id' do
    before do
      shared_category = create(:category, source: family)
      create(:category_diary, category: shared_category, diary:)
    end

    it '同じ家族のユーザーは閲覧できる' do
      member.regenerate_auth_token
      get "/api/v1/diaries/#{diary.id}", headers: { 'Authorization' => "Token #{member.auth_token}" }
      expect(response).to have_http_status(:success)
    end

    it '別家族のユーザーは閲覧できない' do
      outsider.regenerate_auth_token
      get "/api/v1/diaries/#{diary.id}", headers: { 'Authorization' => "Token #{outsider.auth_token}" }
      expect(response).to have_http_status(:not_found)
    end
  end
end

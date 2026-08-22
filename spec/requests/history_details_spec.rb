require 'rails_helper'

RSpec.describe 'History details', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:family) { create(:family) }
  let(:user) { create(:user, family:) }
  let(:history) do
    create(
      :history,
      family:,
      author: user,
      title: '家族旅行',
      content: '**楽しかった**',
      target_date: Date.new(2026, 8, 22)
    )
  end

  describe 'GET /histories/:id.json' do
    it '閲覧モーダル用の詳細を返す' do
      sign_in user

      get history_path(history, format: :json)

      expect(response).to have_http_status(:success)
      body = response.parsed_body.fetch('history')
      expect(body).to include(
        'id' => history.id,
        'title' => '家族旅行',
        'target_date' => '2026-08-22'
      )
      expect(body.fetch('content_html')).to include('<strong>楽しかった</strong>')
    end

    it '別家族の記録は取得できない' do
      outsider = create(:user, family: create(:family))
      sign_in outsider

      get history_path(history, format: :json)

      expect(response).to have_http_status(:not_found)
    end
  end
end

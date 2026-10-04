require 'rails_helper'

RSpec.describe 'Records', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'DELETE /records/:id' do
    let(:habit) { create(:habit, source: user) }
    let!(:record) { Record.create!(habit:, record_at: Date.current, value: 1) }

    it '記録を削除すること' do
      expect do
        delete record_path(record, format: :json)
      end.to change(Record, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end

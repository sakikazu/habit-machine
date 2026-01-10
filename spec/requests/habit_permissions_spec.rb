require 'rails_helper'

RSpec.describe 'Habit permissions', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:family) { create(:family) }
  let(:owner) { create(:user, family:) }
  let(:member) { create(:user, family:, email: 'member@example.com') }
  let(:outsider) { create(:user, family: create(:family), email: 'outsider@example.com') }

  describe 'GET /habits/:id' do
    it '所有者は閲覧できる' do
      habit = create(:habit, source: owner)
      sign_in owner
      get habit_path(habit)
      expect(response).to have_http_status(:success)
    end

    it '同じ家族でも個人の習慣は閲覧できない' do
      habit = create(:habit, source: owner)
      sign_in member
      get habit_path(habit)
      expect(response).to have_http_status(:not_found)
    end

    it '家族共有の習慣は同じ家族が閲覧できる' do
      habit = create(:habit, source: family)
      sign_in member
      get habit_path(habit)
      expect(response).to have_http_status(:success)
    end

    it '家族共有の習慣でも別家族は閲覧できない' do
      habit = create(:habit, source: family)
      sign_in outsider
      get habit_path(habit)
      expect(response).to have_http_status(:not_found)
    end
  end
end

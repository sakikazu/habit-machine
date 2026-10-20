require 'rails_helper'

RSpec.describe 'Habit permissions', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:family) { create(:family) }
  let(:owner) { create(:user, family:) }
  let(:member) { create(:user, family:, email: 'member@example.com') }
  let(:outsider) { create(:user, family: create(:family), email: 'outsider@example.com') }

  describe 'GET /habits' do
    it '有効な習慣だけを個人用と家族用に分けて表示する' do
      personal_habit = create(:habit, source: owner, title: '個人の有効習慣')
      family_habit = create(:habit, source: family, title: '家族の有効習慣')
      create(:habit, source: owner, title: '無効な習慣', status: :disabled)
      create(:habit, source: outsider, title: '他人の習慣')
      sign_in owner

      get habits_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(
        personal_habit.title, family_habit.title, '個人用', '家族用'
      )
      expect(response.body).to include(
        edit_habit_path(personal_habit), edit_habit_path(family_habit)
      )
      expect(response.body).not_to include('無効な習慣', '他人の習慣')
    end
  end

  describe 'GET /habits/archive' do
    it '利用者が参照できる無効・完了の習慣だけを表示する' do
      disabled_habit = create(:habit, source: owner, title: '休止した習慣', status: :disabled)
      done_habit = create(:habit, source: family, title: '達成した習慣', status: :done)
      create(:habit, source: owner, title: '現在の習慣')
      create(:habit, source: outsider, title: '他人の過去習慣', status: :done)
      sign_in owner

      get archive_habits_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(disabled_habit.title, done_habit.title)
      expect(response.body).not_to include('現在の習慣', '他人の過去習慣')
    end
  end

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

  describe 'PATCH /habits/:id' do
    it '参照できる習慣をピン留めできる' do
      habit = create(:habit, source: owner)
      sign_in owner

      patch habit_path(habit, format: :json), params: { habit: { pinned: true } }

      expect(response).to have_http_status(:no_content)
      expect(habit.reload).to be_pinned
    end

    it '参照できない習慣はピン留めできない' do
      habit = create(:habit, source: owner)
      sign_in outsider

      patch habit_path(habit, format: :json), params: { habit: { pinned: true } }

      expect(response).to have_http_status(:not_found)
      expect(habit.reload).not_to be_pinned
    end
  end
end

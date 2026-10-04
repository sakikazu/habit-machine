require 'rails_helper'

RSpec.describe 'Records', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:family) { create(:family) }
  let(:user) { create(:user, family:) }
  let(:outsider) { create(:user, family: create(:family)) }

  before do
    sign_in user
  end

  describe 'POST /records' do
    let(:record_params) { { record_at: Date.current, value: 1 } }

    it '自分の習慣には記録を作成できること' do
      habit = create(:habit, source: user)

      expect do
        post records_path(format: :json), params: { record: record_params.merge(habit_id: habit.id) }
      end.to change(Record, :count).by(1)

      expect(response).to have_http_status(:success)
    end

    it '家族共有の習慣には記録を作成できること' do
      habit = create(:habit, source: family)

      expect do
        post records_path(format: :json), params: { record: record_params.merge(habit_id: habit.id) }
      end.to change(Record, :count).by(1)

      expect(response).to have_http_status(:success)
    end

    it '他人の習慣には記録を作成できないこと' do
      habit = create(:habit, source: outsider)

      expect do
        post records_path(format: :json), params: { record: record_params.merge(habit_id: habit.id) }
      end.not_to change(Record, :count)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /records/:id' do
    it '記録を他人の習慣へ付け替えられないこと' do
      own_habit = create(:habit, source: user)
      record = Record.create!(habit: own_habit, record_at: Date.current, value: 1)
      other_habit = create(:habit, source: outsider)

      patch record_path(record, format: :json), params: { record: { habit_id: other_habit.id, value: 2 } }

      expect(response).to have_http_status(:success)
      expect(record.reload).to have_attributes(habit_id: own_habit.id, value: 2)
    end

    it '他人の記録を更新できないこと' do
      habit = create(:habit, source: outsider)
      record = Record.create!(habit:, record_at: Date.current, value: 1)

      patch record_path(record, format: :json), params: { record: { value: 2 } }

      expect(response).to have_http_status(:not_found)
      expect(record.reload.value).to eq(1)
    end
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

    it '他人の記録を削除できないこと' do
      habit = create(:habit, source: outsider)
      other_record = Record.create!(habit:, record_at: Date.current, value: 1)

      expect do
        delete record_path(other_record, format: :json)
      end.not_to change(Record, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end

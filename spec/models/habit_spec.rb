require 'rails_helper'

RSpec.describe Habit, type: :model do
  it '入力例記法を変換せずテンプレートへ保存する' do
    template = "### 睡眠\n- 睡眠：[[7時間10分 / 79点]]"
    habit = create(:habit, template:)

    expect(habit.reload.template).to eq(template)
  end
end

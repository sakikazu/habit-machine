require 'rails_helper'

RSpec.describe Habit, type: :model do
  it '入力例記法を変換せずテンプレートへ保存する' do
    template = "### 睡眠\n- 睡眠：[[7時間10分 / 79点]]"
    habit = create(:habit, template:)

    expect(habit.reload.template).to eq(template)
  end

  describe '.with_record_at_date' do
    it '個人用を家族用より先に並べ、それぞれ記録済みを優先する' do
      user = create(:user)
      family = user.family
      personal_without_record = create(:habit, source: user, title: '個人・未記録')
      personal_with_record = create(:habit, source: user, title: '個人・記録済み')
      family_without_record = create(:habit, source: family, title: '家族・未記録')
      family_with_record = create(:habit, source: family, title: '家族・記録済み')
      date = Date.current
      Record.create!(habit: personal_with_record, record_at: date, value: 1)
      Record.create!(habit: family_with_record, record_at: date, value: 1)

      habits = described_class.with_record_at_date(
        [family_without_record, personal_without_record, family_with_record, personal_with_record],
        date
      )
      expected_habits = [
        personal_with_record,
        personal_without_record,
        family_with_record,
        family_without_record
      ]

      expect(habits).to eq(expected_habits)
    end
  end
end

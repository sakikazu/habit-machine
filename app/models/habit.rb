# == Schema Information
#
# Table name: habits
#
#  id          :integer          not null, primary key
#  status      :integer
#  title       :string(255)
#  user_id     :integer
#  result_type :integer
#  value_type  :integer
#  value_unit  :string(255)
#  reminder    :boolean
#  goal        :text(65535)
#  memo        :text(65535)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Habit < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  has_many :records

  validates_presence_of :title, :status, :result_type, :value_type
  attr_accessor :search_word, :records_in_date_term, :record_at_date

  scope :enable, lambda{ where(status: 1) }
  scope :disable, lambda{ where(status: 2) }
  scope :close, lambda{ where(status: 3) }

  # todo 非公開の設定はまた今後人に見せる機能を追加したときに対応しよう
  STATUS_TYPE = [["有効", 1], ["無効", 2], ["完了", 3]]

  VALUE_TYPE_COLLECTION = 1
  VALUE_TYPE_INT = 2
  VALUE_TYPE_FLOAT = 3
  VALUE_TYPE = [["1/2/3/4/5", VALUE_TYPE_COLLECTION], ["整数", VALUE_TYPE_INT], ["小数込", VALUE_TYPE_FLOAT]]

  RESULT_TYPE_TABLE = 1
  RESULT_TYPE_ORESEN = 2
  RESULT_TYPE_BOU = 3
  RESULT_TYPE = [["テーブル表示", RESULT_TYPE_TABLE], ["折れ線グラフ", RESULT_TYPE_ORESEN], ["棒グラフ", RESULT_TYPE_BOU]]


  GRAPH_TYPE_ORESEN = 'spline'
  GRAPH_TYPE_BOU = 'column'

  # TODO: enumを使って良い感じにやりたい
  def enabled?
    self.status == 1
  end

  def status_name
    Hash[*STATUS_TYPE.flatten.reverse][self.status]
  end

  def value_name
    Hash[*VALUE_TYPE.flatten.reverse][self.value_type]
  end

  def result_name
    Hash[*RESULT_TYPE.flatten.reverse][self.result_type]
  end

  # 対象期間分の習慣データを取得
  def self.with_records_in_date_term(habits, date_term)
    records = Record.where(habit_id: habits.map {|h| h.id }, record_at: date_term).order(:record_at)
    records_grouped_by_habit = records.group_by {|r| r.habit_id }

    habits.each do |habit|
      habit.records_in_date_term = []
      records_by_habit = records_grouped_by_habit[habit.id]
      date_term.each do |date|
        found_record = records_by_habit.blank? ? nil : records_by_habit.detect{|r| r.record_at == date}
        habit.records_in_date_term << (found_record || Record.new(habit_id: habit.id, record_at: date))
      end
    end
    habits

    # NOTE: これはシンプルだが、Recordが日付範囲にない場合、LEFT OUTER JOINでもhabitsさえ取得できなくなる
    # これはwhereでrecordsを絞ってそれがHabitにも影響しているためで、うまくやるにはOUTER JOINのONにこのwhereの条件を追加する必要がある
    # まあ、上のようにテーブルごとに取得して処理するやり方で良いだろう
    # habits = user.habits.enable.includes(:records).where("records.record_at" => date_term)
    # habits.each do |habit|
      # records_included_new_instance = []
      # date_term.each do |date|
        # found_record = habit.records.detect{|r| r.record_at == date}
        # records_included_new_instance << (found_record.present? ? found_record : Record.new(habit_id: habit.id, record_at: date))
      # end
      # habit.records_included_new_instance = records_included_new_instance
    # end
  end

  # 特定の1日分用の習慣データ
  # Recordは登録されていればそのHabitが有効かを問わずに対象とし、
  # Recordが登録されているかを問わず、有効なHabitを対象とする
  def self.with_record_at_date(habits, date)
    registered_records = Record.where(habit: habits).where(record_at: date)
    records_grouped_by_habit = registered_records.group_by { |r| r.habit_id }
    habits = habits.map do |habit|
      habit.record_at_date = if records_grouped_by_habit[habit.id].present?
                               records_grouped_by_habit[habit.id].first
                             else
                               Record.new(habit_id: habit.id, record_at: date)
                             end
      habit
    end
    # Habitが有効でなく、そのRecordも未登録なら除外する
    habits = habits.delete_if { |h| !h.enabled? && h.record_at_date.new_record? }
    # Recordが登録されているHabitを前方に持ってくる
    habits.partition { |h| !h.record_at_date.new_record? }.flatten
  end
end


# == Schema Information
#
# Table name: habits
#
#  id          :integer          not null, primary key
#  deleted_at  :datetime
#  goal        :text(65535)
#  memo        :text(65535)
#  reminder    :boolean
#  result_type :integer
#  source_type :string(255)      not null
#  status      :integer
#  template    :text(65535)
#  title       :string(255)
#  value_type  :integer
#  value_unit  :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          not null
#
# Indexes
#
#  index_habits_on_source_id_and_source_type  (source_id,source_type)
#

class Habit < ApplicationRecord
  acts_as_paranoid

  belongs_to :source, polymorphic: true
  has_many :records

  scope :available_by_user, lambda { |user| joins("LEFT JOIN users ON habits.source_id = users.id AND habits.source_type = 'User' LEFT JOIN families ON habits.source_id = families.id AND habits.source_type = 'Family'").where("users.id = ? OR families.id = ?", user.id, user.family&.id) }

  validates_presence_of :title, :status, :result_type, :value_type
  attr_accessor :search_word, :records_in_date_term, :record_at_date

  # todo 非公開の設定はまた今後人に見せる機能を追加したときに対応しよう
  enum status: { enabled: 1, disabled: 2, done: 3 }, _prefix: true
  enum value_type: { collection: 1, integer: 2, float: 3 }, _prefix: true
  enum result_type: { table: 1, line_graph: 2, bar_graph: 3 }, _prefix: true

  GRAPH_TYPE_ORESEN = 'spline'
  GRAPH_TYPE_BOU = 'column'

  # NOTE: valueはFloat型のためフォームには小数点を含む値がセットされており、optionsの値も合わせておかないと正しく表示されない
  # NOTE: 空の選択肢の値がnilだと0がポストされてしまうので、空文字列にする必要がある
  SYMBOLIC_VALUE = [['', ''], [1.0, "1"], [2.0, "2"], [3.0, "3"], [4.0, "4"], [5.0, "5"]]

  def value_select_options
    value_type_collection? ? SYMBOLIC_VALUE : nil
  end

  def for_family?
    source_type == 'Family'
  end

  # 対象期間分の習慣データを取得
  def self.with_records_in_date_term(habits, date_term)
    records = Record.includes(:habit).where(habit_id: habits.map {|h| h.id }, record_at: date_term).order(:record_at)
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
    habits = habits.delete_if { |h| !h.status_enabled? && h.record_at_date.new_record? }
    # Recordが登録されているHabitを前方に持ってくる
    habits.partition { |h| !h.record_at_date.new_record? }.flatten
  end
end

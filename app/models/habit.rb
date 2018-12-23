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

  scope :enable, lambda{ where(status: 1) }
  scope :disable, lambda{ where(status: 2) }
  scope :close, lambda{ where(status: 3) }

  scope :by_user, lambda {|user| where(user_id: user.id)}

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


  def status_name
    Hash[*STATUS_TYPE.flatten.reverse][self.status]
  end

  def value_name
    Hash[*VALUE_TYPE.flatten.reverse][self.value_type]
  end

  def result_name
    Hash[*RESULT_TYPE.flatten.reverse][self.result_type]
  end

end

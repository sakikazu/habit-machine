# -*- coding: utf-8 -*-
class Habit < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :value_type, :value_unit, :result_type, :reminder, :title, :user_id, :goal, :status, :memo

  belongs_to :user
  has_many :records

  validates_presence_of :title, :status, :result_type, :value_type

  scope :enable, where(status: 1)
  scope :disable, where(status: 2)
  scope :close, where(status: 3)

  # todo 非公開の設定はまた今後人に見せる機能を追加したときに対応しよう
  STATUS_TYPE = [["有効", 1], ["無効", 2], ["完了", 3]]
  VALUE_TYPE = [["1/2/3/4/5", 1], ["整数", 2], ["小数込", 1]]
  RESULT_TYPE = [["テーブル表示", 1], ["折れ線グラフ", 2], ["棒グラフ", 3]]

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

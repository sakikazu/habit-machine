# -*- coding: utf-8 -*-
module HabitsHelper

  #
  # 入力テーブルでインライン編集
  #
  def input_value_for_inline_edit(record)
    if record.habit.value_type == 1
      best_in_place record, :value, nil: "未入力", display_as: :formatted_value, type: :select, collection: Record::SYMBOLIC_VALUE, path: url_for(controller: :records, action: :update_or_create, habit_id: record.habit_id, record_at: record.record_at)
      # todo ちゃんとヘルパーはimage_tagを出力しているのに画像が表示されない
      # best_in_place record, :value, nil: "未入力", display_with: lambda{|v| result_icon2(v).html_safe}, type: :select, collection: Record::SYMBOLIC_VALUE
    else
      best_in_place record, :value, nil: "未入力", display_as: :formatted_value, path: url_for(controller: :records, action: :update_or_create, habit_id: record.habit_id, record_at: record.record_at)
    end
  end

  #
  # 結果テーブルに表示するアイコン
  #
  def result_icon(record)
    if record.habit.value_type == 1
      icon_set = ["Sun.png", "db1s.png", "db3s.png", "db5s.png", "db7s.png"]
      image_tag("result_table/#{icon_set[record.value.to_i - 1]}")
    else
      record.formatted_value
    end
  end

  # todo display_withのお試し用
  # def result_icon2(value)
      # icon_set = ["Sun.png", "db1s.png", "db3s.png", "db5s.png", "db7s.png"]
      # image_tag("result_table/#{icon_set[value.to_i - 1]}")
  # end
end

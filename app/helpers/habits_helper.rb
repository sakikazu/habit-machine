module HabitsHelper

  #
  # best_in_placeでインライン編集
  #
  def input_value_for_inline_edit(record, habit_value_type)
    action_url = url_for(controller: :records, action: :update_or_create, habit_id: record.habit_id, record_at: record.record_at)

    # セレクトボックス形式
    if habit_value_type == Habit::VALUE_TYPE_COLLECTION
      best_in_place record, :value, place_holder: "未入力", as: :select, collection: Record::SYMBOLIC_VALUE, url: action_url
      # todo ちゃんとヘルパーはimage_tagを出力しているのに画像が表示されない
      # best_in_place record, :value, place_holder: "未入力", display_with: lambda{|v| result_icon2(v).html_safe}, as: :select, collection: Record::SYMBOLIC_VALUE

    # 自由入力形式
    else
      best_in_place record, :value, place_holder: "未入力", display_with: lambda {|v| habit_value_type == Habit::VALUE_TYPE_INT ? v.to_i : v}, url: action_url
    end
  end

  #
  # 記録データのメモ表示(best_in_place用)
  #
  def link_including_icon_for_bip(memo)
    return "" if memo.blank?
    icon = fa_icon 'comment'
    link_to icon.html_safe, "#", data: {
      toggle: 'popover',
      trigger: 'hover',
      html: true,
      content: nl2br(memo).html_safe
    }
  end

  #
  # 結果テーブルに表示するアイコン
  #
  def result_icon(record)
    record.habit_value_type = record.habit.value_type
    if record.habit.value_type == 1
      icon_set = ["Sun.png", "db1s.png", "db3s.png", "db5s.png", "db7s.png"]
      image_tag("result_table/#{icon_set[record.value.to_i - 1]}")
    else
      record.record_formatted_value
    end
  end

  # todo display_withのお試し用
  # def result_icon2(value)
      # icon_set = ["Sun.png", "db1s.png", "db3s.png", "db5s.png", "db7s.png"]
      # image_tag("result_table/#{icon_set[value.to_i - 1]}")
  # end
end

module HabitsHelper

  #
  # best_in_placeでインライン編集
  #
  def best_in_place_wrapper(record, habit_value_type)
    action_url = url_for(controller: :records, action: :update_or_create, habit_id: record.habit_id, record_at: record.record_at)
    options = { place_holder: "未入力", url: action_url, class: 'text-danger' }

    # セレクトボックス形式
    if habit_value_type == Habit::VALUE_TYPE_COLLECTION
      options.merge!(as: :select, collection: Record::SYMBOLIC_VALUE)
      # todo ちゃんとヘルパーはimage_tagを出力しているのに画像が表示されない
      # display_with: lambda{|v| result_icon2(v).html_safe}, as: :select, collection: Record::SYMBOLIC_VALUE

    # 自由入力形式
    else
      options.merge!(display_with: lambda {|v| habit_value_type == Habit::VALUE_TYPE_INT ? v.to_i : v})
    end

    best_in_place record, :value, options
  end

  def best_in_place_textarea_content(val)
    if val.present?
      content_tag('span', fa_icon('comment'), data: { content: val })
    else
      fa_icon('comment-o')
    end
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

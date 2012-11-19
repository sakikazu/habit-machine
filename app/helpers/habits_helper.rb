# -*- coding: utf-8 -*-
module HabitsHelper
  def input_value_for_inline_edit(record)
    if record.habit.data_type == 3
      best_in_place record, :value, nil: "未入力", display_as: :formatted_value, type: :select, collection: Record::SYMBOLIC_VALUE
    else
      best_in_place record, :value, nil: "未入力", display_as: :formatted_value
    end
  end
end

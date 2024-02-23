module HistoriesHelper
  def each_user_history_path(history)
    if history.source.is_a?(Child)
      month_child_child_histories_path(history.source, history.target_date.year, history.target_date.month)
    elsif history.source.is_a?(User)
      month_user_user_histories_path(history.source, history.target_date.year, history.target_date.month)
    elsif history.source.is_a?(Family)
      # familyはfamilyを特定する必要がないので、その引数は不要
      month_family_family_histories_path(history.target_date.year, history.target_date.month)
    end
  end
end

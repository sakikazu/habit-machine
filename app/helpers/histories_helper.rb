module HistoriesHelper
  def each_user_history_path(history)
    if history.member_names.size == 1
      member = history.primary_member
      if member.is_a?(Child)
        return month_child_child_histories_path(member, history.target_date.year, history.target_date.month)
      end
      if member.is_a?(User)
        return history_path(history)
      end
    end

    history_path(history)
  end
end

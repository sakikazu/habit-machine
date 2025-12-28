module HistoriesHelper
  def each_user_history_path(history)
    if history.member_names.size == 1
      member = history.primary_member
      if member.is_a?(Child)
        return month_child_child_histories_path(member, history.target_date.year, history.target_date.month)
      end
      if member.is_a?(User)
        return month_user_user_histories_path(member, history.target_date.year, history.target_date.month)
      end
    end

    # familyはfamilyを特定する必要がないので、その引数は不要
    month_family_family_histories_path(history.target_date.year, history.target_date.month)
  end
end

# db/migrate/20251228000001_backfill_member_histories.rb histories.sourceからmember_historiesをバックフィル
class BackfillMemberHistories < ActiveRecord::Migration[7.2]
  def up
    say_with_time 'Backfill member_histories from histories.source' do
      MemberHistory.reset_column_information
      History.reset_column_information

      History.where(source_type: %w[User Child]).where.not(source_id: nil).find_each do |history|
        MemberHistory.find_or_create_by!(
          history_id: history.id,
          member_type: history.source_type,
          member_id: history.source_id
        )
      end
    end
  end

  def down
    MemberHistory.where(member_type: %w[User Child]).delete_all
  end
end

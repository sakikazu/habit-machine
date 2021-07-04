class GeneralController < ApplicationController
  before_action :authenticate_user!

  # 一日分のデータを表示
  def day
    if params[:date].blank?
      @date = Date.today
    else
      begin
        @date = Date.parse(params[:date])
      rescue
        raise NotFound
      end
    end

    @page_title = "#{@date.to_s(:normal)}の記録"
    @no_header_margin = true
  end

  def day_data
    date = Date.parse(params[:date]) rescue nil
    return head :bad_request if date.blank?
    @habits = Habit.with_record_at_date(current_user.habits, date)
    @diaries = current_user.diaries.where(record_at: date)
    # TODO: DB変更前に、POCでeverydayタグを対象とする
    @everyday_diaries = current_user.diaries.tagged_with('everyday').order(id: :desc).limit(10)
  end
end

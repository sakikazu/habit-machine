class GeneralController < ApplicationController
  before_action :authenticate_user!

  # TOPページ
  def top
    # 起点（ページの中心日）の前後＊日分のデータが対象
    @one_day = if params[:one_day].present?
                 Date.strptime(params[:one_day])
               elsif params[:record_at].present? # from Date Form
                 Date.new(
                   params[:record_at]["one_day(1i)"].to_i,
                   params[:record_at]["one_day(2i)"].to_i,
                   params[:record_at]["one_day(3i)"].to_i
                 )
               else
                 Date.today
               end
    # 開始曜日を月曜固定にしない理由は、特定日に飛んだ際に、その日を画面の中心にしたいため
    @date_term = (@one_day - 3)..(@one_day + 3)

    @page_title = "#{@one_day.to_s(:normal)}を含む週"

    @habits = Habit.with_records_in_date_term(current_user.habits.enable, @date_term)
    @diaries = Diary.group_by_record_at(current_user, @date_term)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @habits }
    end
  end

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
    @habits = Habit.with_record_at_date(current_user.habits, @date)
    @diaries = current_user.diaries.where(record_at: @date)
  end

  def search
    @g_search_word = params[:q]
    @turbolinks_off = true
    @page_title = 'サイト内検索'
  end

end
